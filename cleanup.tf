###############################################################################
# CLEANUP
###############################################################################

resource "aws_ssm_maintenance_window" "cleanup" {
  name        = "patching-cleanup"
  description = "patching-cleanup window"

  schedule          = var.cleanup_cron
  schedule_timezone = var.maintenance_window_timezone

  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
  enabled  = var.cleanup_enabled
 
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "cleanup" {
  window_id     = aws_ssm_maintenance_window.cleanup.id
  name          = "ssm-patching-cleanup-target"
  description   = "Targets for SSM patching cleanup"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:${var.cleanup_target_group_tag_key}"
    values = var.cleanup_target_group_tag_values
  }
}

resource "aws_cloudwatch_log_group" "cleanup" {
  count = var.cleanup_log_group_create ? 1 : 0

  name = var.cleanup_log_group_name

  retention_in_days = var.cleanup_log_retention_days
}

resource "aws_cloudwatch_query_definition" "cleanup_stderr" {
  name = "ssm-patching-cleanup-stderr-errors"

  log_group_names = [
     var.cleanup_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stderr' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_cloudwatch_query_definition" "cleanup_stdout" {
  name = "ssm-patching-cleanup-stdout-errors"

  log_group_names = [
     var.cleanup_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stdout' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_ssm_maintenance_window_task" "cleanup" {
  window_id        = aws_ssm_maintenance_window.cleanup.id
  name             = "patching-cleanup"
  description      = "patching-cleanup"
  max_concurrency  = 999
  max_errors       = 999
  priority         = 1
  task_arn         = "AWS-RunShellScript"
  task_type        = "RUN_COMMAND"
  service_role_arn = data.aws_iam_role.ssm_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.cleanup.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "commands"
        values = var.cleanup_commands
      }

      cloudwatch_config {
        cloudwatch_log_group_name = var.cleanup_log_group_name
        cloudwatch_output_enabled = true
      }
    }
  }
}