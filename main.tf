data "aws_iam_role" "ssm_service_role" {
  name = "AWSServiceRoleForAmazonSSM"
}

###############################################################################
# PATCHING
###############################################################################

resource "aws_ssm_maintenance_window" "patching" {
  count = var.patching_enabled ? 1 : 0

  name        = "${var.base_name}-patching"
  description = "patching window for ${var.base_name}"

  schedule          = var.patching_cron
  schedule_timezone = var.maintenance_window_timezone

  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
  enabled  = var.patching_enabled
 
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "patching" {
  count = var.patching_enabled ? 1 : 0

  window_id     = aws_ssm_maintenance_window.patching[0].id
  name          = "${var.base_name}-ssm-patching-target"
  description   = "Targets for SSM patching for ${var.base_name}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:${var.patching_target_group_tag_key}"
    values = var.patching_target_group_tag_values
  }
}

resource "aws_cloudwatch_log_group" "patching" {
  count = var.patching_log_group_create && var.patching_enabled ? 1 : 0

  name = var.patching_log_group_name

  retention_in_days = var.patching_log_retention_days
}

resource "aws_cloudwatch_query_definition" "patching_stderr" {
  count = var.patching_log_group_create && var.patching_enabled ? 1 : 0

  name = "${var.base_name}-patching-stderr-errors"

  log_group_names = [
     var.patching_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stderr' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_cloudwatch_query_definition" "patching_stdout" {
  count = var.patching_log_group_create && var.patching_enabled ? 1 : 0

  name = "${var.base_name}-patching-stdout-errors"

  log_group_names = [
     var.patching_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stdout' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_ssm_maintenance_window_task" "patching" {
  count = var.patching_enabled ? 1 : 0

  window_id        = aws_ssm_maintenance_window.patching[0].id
  name             = "${var.base_name}-patching"
  description      = "patching for ${var.base_name}"
  max_concurrency  = 999
  max_errors       = 999
  priority         = 1
  task_arn         = "AWS-RunPatchBaseline"
  task_type        = "RUN_COMMAND"
  service_role_arn = data.aws_iam_role.ssm_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patching[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "Operation"
        values = ["Install"]
      }

      parameter {
        name   = "RebootOption"
        values = [
            var.patching_allow_reboot ? "RebootIfNeeded" : "NoReboot"
        ]
      }

      cloudwatch_config {
        cloudwatch_log_group_name = var.patching_log_group_name
        cloudwatch_output_enabled = true
      }
    }
  }
}

###############################################################################
# SCANNING
###############################################################################

resource "aws_ssm_maintenance_window" "scanning" {
  count = var.scanning_enabled ? 1 : 0

  name        = "${var.base_name}-scanning"
  description = "scanning window for ${var.base_name}"

  schedule          = var.scanning_cron
  schedule_timezone = var.maintenance_window_timezone

  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
  enabled  = var.scanning_enabled
 
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "scanning" {
  count = var.scanning_enabled ? 1 : 0

  window_id     = aws_ssm_maintenance_window.scanning[0].id
  name          = "${var.base_name}-ssm-scanning-target"
  description   = "Targets for SSM scanning for ${var.base_name}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:${var.scanning_target_group_tag_key}"
    values = var.scanning_target_group_tag_values
  }
}

resource "aws_cloudwatch_log_group" "scanning" {
  count = var.scanning_log_group_create && var.scanning_enabled ? 1 : 0

  name = var.scanning_log_group_name

  retention_in_days = var.scanning_log_retention_days
}

resource "aws_cloudwatch_query_definition" "scanning_stderr" {
  count = var.scanning_log_group_create && var.scanning_enabled ? 1 : 0

  name = "${var.base_name}-scanning-stderr-errors"

  log_group_names = [
     var.scanning_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stderr' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_cloudwatch_query_definition" "scanning_stdout" {
  count = var.scanning_log_group_create && var.scanning_enabled ? 1 : 0

  name = "${var.base_name}-scanning-stdout-errors"

  log_group_names = [
     var.scanning_log_group_name,
  ]

  query_string = <<-EOF
    filter @logStream like 'stdout' and @message like /(?i)Error/
    | fields @timestamp, @message
    | sort @timestamp desc
  EOF
}

resource "aws_ssm_maintenance_window_task" "scanning" {
  count = var.scanning_enabled ? 1 : 0

  window_id        = aws_ssm_maintenance_window.scanning[0].id
  name             = "${var.base_name}-scanning"
  description      = "scanning for ${var.base_name}"
  max_concurrency  = 999
  max_errors       = 999
  priority         = 1
  task_arn         = "AWS-RunPatchBaseline"
  task_type        = "RUN_COMMAND"
  service_role_arn = data.aws_iam_role.ssm_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.scanning[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "Operation"
        values = ["Scan"]
      }

      parameter {
        name   = "RebootOption"
        values = ["NoReboot"]
      }

      cloudwatch_config {
        cloudwatch_log_group_name = var.scanning_log_group_name
        cloudwatch_output_enabled = true
      }
    }
  }
}
