# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/pricing"

  providers = {
    aws = aws.pricing
  }

  enabled        = var.enabled && var.cost_estimation_config.enabled
  region         = local.region
  create_kms_key = var.enabled && var.encryption_config.create_kms_key
}
