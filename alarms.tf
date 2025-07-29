# SNS Topic for alarm notifications (only created if no external topic provided)
resource "aws_sns_topic" "alarms" {
  count = local.create_sns_topic ? 1 : 0

  name = "${local.name_prefix}-alarms"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alarms"
  })
}

