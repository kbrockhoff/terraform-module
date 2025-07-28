# Brockhoff Cloud Terraform Module

Terraform module which creates XXX resources on CLOUD. It takes an opinionated 
approach to resource placement, naming, tagging, and well-architected best 
practices.

## Features

- Feature 1
- Feature 2
- Feature 3
- Monthly cost estimate submodule
- Deployment pipeline least privilege IAM role submodule

## Usage

### Basic Example

```hcl
module "example" {
  source = "path/to/terraform-module"

  # ... other required arguments ...
}
```

### Complete Example

```hcl
module "example" {
  source = "path/to/terraform-module"

  # ... all available arguments ...
}
```

## Environment Type Configuration

The `environment_type` variable provides a standardized way to configure resource defaults based on environment 
characteristics. This follows cloud well-architected framework recommendations for different deployment stages. 
Resiliency settings comply with the recovery point objective (RPO) and recovery time objective (RTO) values in
the table below. Cost optimization settings focus on shutting down resources during off-hours.

### Available Environment Types

| Type | Use Case | Configuration Focus | RPO | RTO |
|------|----------|---------------------|-----|-----|
| `None` | Custom configuration | No defaults applied, use individual config values | N/A | N/A |
| `Ephemeral` | Temporary environments | Cost-optimized, minimal durability requirements | N/A | 48h |
| `Development` | Developer workspaces | Balanced cost and functionality for active development | 24h | 48h |
| `Testing` | Automated testing | Consistent, repeatable configurations | 24h | 48h |
| `UAT` | User acceptance testing | Production-like settings with some cost optimization | 12h | 24h |
| `Production` | Live systems | High availability, durability, and performance | 1h  | 4h  |
| `MissionCritical` | Critical production | Maximum reliability, redundancy, and monitoring | 5m  | 1h  |

### Usage Examples

#### Development Environment
```hcl
module "dev_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "dev-usw2"
  environment_type = "Development"
  
  tags = {
    Environment = "development"
    Team        = "platform"
  }
}
```

#### Production Environment
```hcl
module "prod_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "prod-usw2"
  environment_type = "Production"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    Backup      = "required"
  }
}
```

#### Custom Configuration (None)
```hcl
module "custom_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "custom-usw2"
  environment_type = "None"
  
  # Specify all individual configuration values
  # when environment_type is "None"
}
```
## Network Tags Configuration

Resources deployed to subnets use lookup by `NetworkTags` values to determine which subnets to deploy to. 
This eliminates the need to manage different subnet IDs variable values for each environment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pricing"></a> [pricing](#module\_pricing) | ./modules/pricing | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2' | `string` | n/a | yes |
| <a name="input_cost_estimation_enabled"></a> [cost\_estimation\_enabled](#input\_cost\_estimation\_enabled) | Set to false to disable estimation of monthly costs for provisioned resources | `bool` | `true` | no |
| <a name="input_data_tags"></a> [data\_tags](#input\_data\_tags) | Tags/labels to apply to all resources with data-at-rest | `map(string)` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type for resource configuration defaults. Select 'None' to use individual config values. | `string` | `"Development"` | no |
| <a name="input_networktags_name"></a> [networktags\_name](#input\_networktags\_name) | Name of the network tags key used for subnet classification | `string` | `"NetworkTags"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->    

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
