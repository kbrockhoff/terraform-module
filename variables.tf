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
    condition     = can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name_prefix))
    error_message = "The name_prefix value must start with a lowercase letter, followed by 0 to 22 alphanumeric or hyphen characters, ending with alphanumeric, for a total length of 2 to 24 characters."
  }
}

variable "tags" {
  description = "Tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Additional tags to apply specifically to data storage resources (e.g., S3, RDS, EBS) beyond the common tags."
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
# Encryption
# ----

variable "encryption_config" {
  description = "Configuration object for encryption settings and KMS key management"
  type = object({
    create_kms_key               = bool
    kms_key_id                   = string
    kms_key_deletion_window_days = number
  })
  default = {
    create_kms_key               = true
    kms_key_id                   = ""
    kms_key_deletion_window_days = 14
  }

  validation {
    condition = (
      (var.encryption_config.create_kms_key && var.encryption_config.kms_key_id == "") ||
      (!var.encryption_config.create_kms_key && var.encryption_config.kms_key_id != "")
    )
    error_message = "kms_key_id must be empty when create_kms_key is true, or provided when create_kms_key is false."
  }

  validation {
    condition     = var.encryption_config.kms_key_deletion_window_days >= 7 && var.encryption_config.kms_key_deletion_window_days <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days when specified."
  }
}

# ----
# Monitoring
# ----

variable "monitoring_config" {
  description = "Configuration object for optional monitoring"
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "alarms_config" {
  description = "Configuration object for metric alarms and notifications"
  type = object({
    enabled          = bool
    create_sns_topic = bool
    sns_topic_arn    = string
  })
  default = {
    enabled          = false
    create_sns_topic = true
    sns_topic_arn    = ""
  }

  validation {
    condition = (
      (var.alarms_config.create_sns_topic && var.alarms_config.sns_topic_arn == "") ||
      (!var.alarms_config.create_sns_topic && var.alarms_config.sns_topic_arn != "")
    )
    error_message = "sns_topic_arn must be empty when create_sns_topic is true, or provided when create_sns_topic is false."
  }
}

# ----
# Cost Estimation
# ----

variable "cost_estimation_config" {
  description = "Configuration object for monthly cost estimation"
  type = object({
    enabled = bool
  })
  default = {
    enabled = true
  }
}
