data "aws_iam_role" "ssm_service_role" {
  name = "AWSServiceRoleForAmazonSSM"
}

###############################################################################
# PATCHING
###############################################################################

resource "aws_ssm_maintenance_window" "patching" {
  name        = "patching"
  description = "patching window"

  schedule          = var.patching_cron
  schedule_timezone = var.maintenance_window_timezone

  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
  enabled  = var.patching_enabled
 
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "patching" {
  window_id     = aws_ssm_maintenance_window.patching.id
  name          = "ssm-patching-target"
  description   = "Targets for SSM patching"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:${var.patching_target_group_tag_key}"
    values = var.patching_target_group_tag_values
  }
}

resource "aws_cloudwatch_log_group" "patching" {
  count = var.patching_log_group_create ? 1 : 0

  name = var.patching_log_group_name

  retention_in_days = var.patching_log_retention_days
}

resource "aws_ssm_maintenance_window_task" "patching" {
  window_id        = aws_ssm_maintenance_window.patching.id
  name             = "patching"
  description      = "patching"
  max_concurrency  = 999
  max_errors       = 999
  priority         = 1
  task_arn         = "AWS-RunPatchBaseline"
  task_type        = "RUN_COMMAND"
  service_role_arn = data.aws_iam_role.ssm_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patching.id]
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
  name        = "scanning"
  description = "scanning window"

  schedule          = var.scanning_cron
  schedule_timezone = var.maintenance_window_timezone

  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
  enabled  = var.patching_enabled
 
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "scanning" {
  window_id     = aws_ssm_maintenance_window.scanning.id
  name          = "ssm-scanning-target"
  description   = "Targets for SSM scanning"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:${var.scanning_target_group_tag_key}"
    values = var.scanning_target_group_tag_values
  }
}

resource "aws_cloudwatch_log_group" "scanning" {
  count = var.scanning_log_group_create ? 1 : 0

  name = var.scanning_log_group_name

  retention_in_days = var.scanning_log_retention_days
}

resource "aws_ssm_maintenance_window_task" "scanning" {
  window_id        = aws_ssm_maintenance_window.scanning.id
  name             = "scanning"
  description      = "scanning"
  max_concurrency  = 999
  max_errors       = 999
  priority         = 1
  task_arn         = "AWS-RunPatchBaseline"
  task_type        = "RUN_COMMAND"
  service_role_arn = data.aws_iam_role.ssm_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.scanning.id]
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