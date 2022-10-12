variable "patching_cron" {
  default = "cron(0 7 ? * TUE *)"
}

variable "patching_enabled" {
  default = true
}

variable "patching_log_group_create" {
  default = true
}

variable "patching_log_group_name" {
  default = "/ssm/patching"
}

variable "patching_log_retention_days" {
  default = 90
}

variable "patching_allow_reboot" {
  default = true
}

variable "patching_target_group_tag_key" {
  default = "Patch Group"
}

variable "patching_target_group_tag_values" {
  type    = list(string)
  default = ["default"]
}

variable "scanning_cron" {
  default = "cron(0 8 ? * * *)"
}

variable "scanning_enabled" {
  default = true
}

variable "scanning_target_group_tag_key" {
  default = "Patch Group"
}

variable "scanning_target_group_tag_values" {
  type    = list(string)
  default = ["default"]
}

variable "scanning_log_group_create" {
  default = true
}

variable "scanning_log_group_name" {
  default = "/ssm/scanning"
}

variable "scanning_log_retention_days" {
  default = 60
}

variable "maintenance_window_timezone" {
  default = "America/New_York"
}

variable "maintenance_window_duration" {
  default = 2
}

variable "maintenance_window_cutoff" {
  default = 1
}
