locals {
  # Environment type configuration maps
  environment_defaults = {
    None = {
      rpo_hours          = null
      rto_hours          = null
      monitoring_enabled = var.monitoring_enabled
      alarms_enabled     = var.alarms_enabled
    }
    Ephemeral = {
      rpo_hours          = null
      rto_hours          = 48
      monitoring_enabled = false
      alarms_enabled     = false
    }
    Development = {
      rpo_hours          = 24
      rto_hours          = 48
      monitoring_enabled = false
      alarms_enabled     = false
    }
    Testing = {
      rpo_hours          = 24
      rto_hours          = 48
      monitoring_enabled = false
      alarms_enabled     = false
    }
    UAT = {
      rpo_hours          = 12
      rto_hours          = 24
      monitoring_enabled = false
      alarms_enabled     = false
    }
    Production = {
      rpo_hours          = 1
      rto_hours          = 4
      monitoring_enabled = true
      alarms_enabled     = true
    }
    MissionCritical = {
      rpo_hours          = 0.083 # 5 minutes
      rto_hours          = 1
      monitoring_enabled = true
      alarms_enabled     = true
    }
  }

  # Apply environment defaults when environment_type is not "None"
  effective_config = var.environment_type == "None" ? (
    local.environment_defaults.None
    ) : (
    local.environment_defaults[var.environment_type]
  )

  # AWS account, partition, and region info
  account_id         = data.aws_caller_identity.current.account_id
  partition          = data.aws_partition.current.partition
  region             = data.aws_region.current.region
  dns_suffix         = data.aws_partition.current.dns_suffix
  reverse_dns_prefix = data.aws_partition.current.reverse_dns_prefix

  common_tags = merge(var.tags, {
    ModuleName    = "terraform-replace-me"
    ModuleVersion = local.module_version
    ModuleEnvType = var.environment_type
  })
  common_data_tags = merge(var.data_tags, local.common_tags)

  name_prefix = var.name_prefix

  # SNS topic logic - use provided topic ARN or create new one
  create_sns_topic = var.enabled && local.effective_config.alarms_enabled && var.alarm_sns_topic_arn == ""
  alarm_sns_topic_arn = var.enabled && local.effective_config.alarms_enabled ? (
    var.alarm_sns_topic_arn != "" ? var.alarm_sns_topic_arn : aws_sns_topic.alarms[0].arn
  ) : ""

}
