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