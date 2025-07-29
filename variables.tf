# ----
# Common
# ----

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "The name_prefix value must start with a lowercase letter, followed by 1 to 15 alphanumeric or hyphen characters, for a total length of 2 to 16 characters."
  }
}

variable "tags" {
  description = "Tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Tags/labels to apply to all resources with data-at-rest"
  type        = map(string)
  default     = {}
}

variable "environment_type" {
  description = "Environment type for resource configuration defaults. Select 'None' to use individual config values."
  type        = string
  default     = "Development"

  validation {
    condition = contains([
      "None", "Ephemeral", "Development", "Testing", "UAT", "Production", "MissionCritical"
    ], var.environment_type)
    error_message = "Environment type must be one of: None, Ephemeral, Development, Testing, UAT, Production, MissionCritical."
  }
}

variable "cost_estimation_enabled" {
  description = "Set to false to disable estimation of monthly costs for provisioned resources"
  type        = bool
  default     = true
}

variable "networktags_name" {
  description = "Name of the network tags key used for subnet classification"
  type        = string
  default     = "NetworkTags"

  validation {
    condition     = var.networktags_name != null && var.networktags_name != ""
    error_message = "Network tags name cannot be null or blank."
  }
}

# ----
# Monitoring
# ----

variable "monitoring_enabled" {
  description = "Launched EC2 instance will have detailed monitoring enabled."
  type        = bool
  default     = false
}

variable "alarms_enabled" {
  description = "Enable CloudWatch alarms for monitoring autoscaling group health"
  type        = bool
  default     = false
}

variable "alarm_sns_topic_arn" {
  description = "ARN of existing SNS topic to use for alarm notifications. If not provided, a new topic will be created."
  type        = string
  default     = ""
}
