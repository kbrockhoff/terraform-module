package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCompleteExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name_prefix":      expectedName,
			"environment_type": "None",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors and shows expected resource creation
	assert.NotEmpty(t, planOutput)
	
	// Verify core KMS resources are planned for creation
	assert.Contains(t, planOutput, "module.main.aws_kms_key.main[0]")
	assert.Contains(t, planOutput, "module.main.aws_kms_alias.main[0]")
	assert.Contains(t, planOutput, "will be created")
	
	// Verify SNS topic IS created when alarms_config.enabled=true (set in complete example)
	assert.Contains(t, planOutput, "module.main.aws_sns_topic.alarms[0]")
	
	// Verify expected resource count (3 resources: KMS key + alias + SNS topic)
	assert.Contains(t, planOutput, "3 to add, 0 to change, 0 to destroy")

}

func TestEnabledFalse(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"enabled":          false,
			"name_prefix":      expectedName,
			"environment_type": "None",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors and shows expected output changes
	assert.NotEmpty(t, planOutput)
	assert.Contains(t, planOutput, "No changes.")

}
