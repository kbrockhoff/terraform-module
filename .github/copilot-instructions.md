---
Source: .ruler/instructions.md
---
# CLOUD XXX Terraform Module Guide for AI Agents

What the goal of this module is.

## Components

### Component 1
- Requirement
- Requirement

### Component 2
- Requirement
- Requirement

---
Source: .ruler/terraform-git.md
---
# AI Agent Git Operations for Terraform Repositories

## Core Principles

**Simplicity First**: Each operation should have a single, clear purpose. Avoid complecting git operations with unrelated concerns.

**Composable Workflow**: Each stage builds independently on the previous, allowing for easy debugging and iteration.

## Branch Management

### Creating Branches
- **Format**: `feature/descriptive-name` or `fix/issue-description`
- **Source**: Always branch from `main`
- **Naming**: Use kebab-case, be specific about the change

```bash
git checkout main
git pull origin main
git checkout -b feature/add-vpc-module
```

### Keeping Branches Current
- **Method**: Rebase only (preserve linear history)
- **Frequency**: Daily, or before any major work session
- **Conflict Resolution**: Address conflicts immediately

```bash
git fetch origin
git rebase origin/main
```

## Pre-Commit Standards

### Code Formatting (Required)
```bash
terraform fmt -recursive
```

### Documentation Generation (Required)
```bash
# Run only at repository root - configured for recursive documentation
terraform-docs .
```

### Validation Pipeline (Required)
Execute in sequence - each step depends on the previous:

1. **Syntax Check**
   ```bash
   terraform init && terraform validate
   ```

2. **Linting**
   ```bash
   tflint --recursive
   ```

3. **Example Validation**
   ```bash
   # Run in each example directory
   for dir in examples/*/; do
     (cd "$dir" && terraform init && terraform validate)
   done
   ```

4. **Test Execution**
   ```bash
   cd test && go test -v ./...
   ```

## Commit Standards

### Message Format
Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Examples
```
feat(vpc): add multi-az subnet configuration
fix(security-group): resolve circular dependency issue
docs(readme): update module usage examples
test(vpc): add integration test for NAT gateway
```

### Commit Scope
- **Atomic Changes**: One logical change per commit
- **Complete Units**: Each commit should leave the repository in a working state
- **Clear Intent**: Commit message should explain *why*, not just *what*

## Pull Request Workflow

### Pre-PR Validation
Ensure all pre-commit checks pass:
```bash
# Complete validation pipeline
make validate  # or equivalent command sequence
```

### PR Requirements
1. **Title**: Must follow Conventional Commits format
2. **Description**: Complete all GitHub template sections
3. **Scope**: Single concern per PR (avoid complecting multiple features)
4. **Size**: Prefer smaller, focused PRs over large, complex ones

### PR Template Sections (All Required)
- [ ] **Summary**: What does this PR accomplish?
- [ ] **Changes**: Specific modifications made
- [ ] **Testing**: How was this validated?
- [ ] **Breaking Changes**: Any backwards compatibility concerns?
- [ ] **Documentation**: What docs were updated?

## Quality Gates

### Automated Checks (Must Pass)
- Terraform formatting
- Terraform validation
- TFLint compliance
- All tests passing
- Documentation generation

### Manual Review Focus
- **Simplicity**: Is the solution as simple as possible?
- **Composition**: Are components properly decoupled?
- **Clarity**: Is the intent obvious from the code?
- **Testability**: Can changes be easily validated?

## Troubleshooting

### Common Issues
1. **Rebase Conflicts**: Resolve immediately, don't accumulate
2. **Test Failures**: Fix root cause, don't mask symptoms
3. **Lint Errors**: Address policy violations, don't suppress

### Recovery Patterns
```bash
# Reset to clean state if needed
git reset --hard origin/main

# Clean workspace
git clean -fd

```

## Notes for AI Agents

- **Fail Fast**: Stop pipeline on first error
- **Context Preservation**: Maintain clear audit trail of operations
- **Rollback Strategy**: Always know how to undo changes
- **Validation Order**: Run cheap checks first (fmt, lint) before expensive ones (tests)

---
Source: .ruler/terraform-module.md
---
# Terraform Module Guide for AI Agents

## Repository Organization

### Branching
- `main` - Production-ready code (default and protected branch)
- `feature/*` - New features or significant changes
- `bugfix/*` - Bug fixes and minor improvements
- `release/*` - Pre-release versions for testing. Merge into `main` after approval. Keep branch for backward compatible patches.

### Tagging
- Use semantic versioning: `v1.0.0`, `v1.1.0`, `v1.1.1`
- Tag releases on `main` branch. Tag patches on `release/*` branches.

### CI/CD
- Use GitHub Actions for CI/CD pipelines
- Run linting and tests on pull requests and branches
- Use Google's [release-please](https://github.com/googleapis/release-please) for automated releases

## File Organization

### Required Files
- `main.tf` - Core resource definitions
- `outputs.tf` - Output value definitions
- `variables.tf` - Input variable definitions
- `versions.tf` - Provider version constraints

### Optional Files
- `locals.tf` - Local value definitions
- `dependencies.tf` - Data source lookups and external data sources

### Directory Structure
```
.gitattributes
.gitignore
.release-please-manifest.json
.terraform-docs.yml
.tflint.hcl
alarms.tf
CHANGELOG.md
dependencies.tf
kms.tf
LICENSE
locals.tf
main.tf
outputs.tf
pricing.tf
README.md
variables.tf
versions.tf
examples/
   complete/
      main.tf
      README.md
      outputs.tf
      terraform.auto.tfvars
      variables.tf
      versions.tf
   defaults/
      main.tf
      README.md
      outputs.tf
      terraform.auto.tfvars
      variables.tf
      versions.tf
modules/
   bootstrap/
      main.tf
      README.md
      outputs.tf
      variables.tf
      versions.tf
   pricing/
      main.tf
      README.md
      outputs.tf
      variables.tf
      versions.tf
templates/
   kms-resource-policy.tpl
test/
   complete_test.go
   defaults_test.go
   go.mod
   go.sum
   main_test.go
```

## Module Resource Patterns

### Feature Flag Strategy:
```hcl
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Set to false to disable access logging."
  type        = bool
  default     = true
}

resource "aws_instance" "example" {
  count = var.enabled ? 1 : 0

  # other configuration
}
```

### Naming Strategy:
```hcl
variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "The name_prefix value must be between 2 and 16 characters."
  }
}

resource "aws_security_group" "web_server" {
  name = "${var.name_prefix}-web-server-sg"
}
```

### Tagging Strategy:
```hcl
variable "tags" {
  description = "Tags/labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Tags/labels to apply to all resources with data-at-rest."
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(var.tags, {
    ModuleName     = "<ModuleName>" # From registry.terraform.io or GitHub repo name
    ModuleVersion  = "<x.x.x>" # Semantic versioning
  })
  common_data_tags = merge(var.data_tags, local.common_tags)
}

resource "aws_security_group" "web_server" {
  name = "${var.name_prefix}-web-server-sg"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-web-server-sg"
  })
}

resource "aws_s3_bucket" "data_landing" {
  name = "${var.name_prefix}-data-landing"

  tags = merge(local.common_data_tags, {
    Name = "${var.name_prefix}-data-landing"
  })
}
```


## Well-Architected Framework Qualities

### Environment Type
- Provide environment type categories with appropriate default configuration options
- Calculate resource sizes based on these categories unless None selected
- Base configuration values on the specified RPO and RTO for each environment type
- Document underlying values used for each type in `README.md`

| Type            | Description                  | RPO | RTO |
|-----------------|------------------------------|-----|-----|
| None            | Use individual config values | N/A | N/A |
| Ephemeral       | Short-lived experimental/dev/test envs    | N/A | 48h |
| Development     | Shared development envs      | 24h | 48h |
| Testing         | Internal testing envs        | 24h | 48h |
| UAT             | User acceptance testing      | 12h | 24h |
| Production      | Non-essential production     | 1h  | 4h  |
| MissionCritical | Mission critical production  | 5m  | 1h  |

### Data Sizing
- Provide t-shirt sizing categories (e.g., Disabled, Small, Medium, Large, XLarge) for data storage and flow configuration options
- Calculate resource sizes based on these categories unless disabled
- Use `map` type for t-shirt sizing options
- Document underlying values used for each size in `README.md`

### Pricing Calculator
- Provide a pricing calculator submodule
- Use pricing calculator to estimate  costs based actual configuration values
- Provide total monthly cost estimate as an output named `monthly_cost_estimate`

## Cloud Provider Specific Guidelines

### AWS:
- Use `aws_iam_policy_document` for IAM policies
- Implement least privilege access
- Prefer use of customer-managed keys for encryption
- Give users option of having the module create keys or using their own
- Place metadata data sources in `dependencies.tf` file and assign values from them to local variables
- Always parameterize partition, region, and account id
- Pass metadata values to submodules instead of having submodules call data sources
- Always create CloudWatch log groups before resources that write to them

## AI Agent Specific Guidelines

### When Writing Code:
1. Favor convention over configuration
2. Simply user configution options by providing t-shirt sizes (e.g., small, medium, large)
3. Generate supporting resources such as encryption keys and IAM roles by default, but give users option to supply their own
4. Always use customer managed encryption keys
5. Provide ids and names of main resources as outputs
6. Include usage section in README.md by copying from examples directory
7. Execute `terraform-docs .` to generate documentation

---
Source: .ruler/terraform-style.md
---
# Terraform Style Guide for AI Agents

This guide builds upon the [Gruntwork Terraform Style Guide](https://docs.gruntwork.io/guides/style/terraform-style-guide/) and [HashiCorp's official conventions](https://developer.hashicorp.com/terraform/language/style), with emphasis on creating simple, reasoning-friendly infrastructure code.

## Core Philosophy

### Simple vs Easy
- **Simple** means "one fold" - each component has a single, clear responsibility
- **Easy** means familiar or close at hand - but familiarity doesn't guarantee maintainability
- **Choose simple over easy**: Prefer explicit, verbose code over clever shortcuts
- **Complexity is complecting**: Avoid braiding together unrelated concerns

### Reasoning-First Design
- **Code should be obvious**: A reader should be able to predict what infrastructure will be created
- **Dependencies should be explicit**: Make resource relationships clear and traceable
- **Changes should be local**: Modifications in one area shouldn't require understanding distant code

### Composition Over Configuration
- **Independent components**: Modules should work in isolation
- **Clear interfaces**: Use variables and outputs to define contracts
- **Minimal assumptions**: Don't embed knowledge about other parts of the system

## Understanding Terraform Behavior

### Mental Model
When reading Terraform code, you should be able to answer:
1. **What resources will be created?** 
2. **In what order will they be created?**
3. **What happens if this variable changes?**
4. **What external dependencies exist?**

### Dependency Reasoning
```hcl
# Good - Dependencies are explicit and traceable
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id  # Clear dependency
  cidr_block = var.private_cidr
}

# Avoid - Hidden dependencies through data sources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]  # Implicit dependency on naming convention
  }
}
```

### Change Impact Analysis
```hcl
# Good - Changing var.environment only affects tags
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = local.common_tags
}

# Avoid - Changing var.environment affects resource names and references
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "${var.environment}-web-server"
  }
}
```

## Composable Design Patterns

### Module Boundaries
A module should have **one reason to change**:

```hcl
# Good - VPC module handles only networking concerns
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = local.common_tags
}

# Good - Separate module for compute concerns
module "web_servers" {
  source = "./modules/ec2-cluster"
  
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  instance_count = var.web_server_count
  instance_type  = var.instance_type
}
```

### Interface Design
```hcl
# Good - Clear, minimal interface
variable "vpc_config" {
  description = "VPC networking configuration"
  type = object({
    cidr_block         = string
    availability_zones = list(string)
    enable_nat_gateway = bool
  })
}

output "vpc_id" {
  description = "VPC identifier for dependent resources"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for compute resources"
  value       = aws_subnet.private[*].id
}
```

### Data Flow Clarity
```hcl
# Good - Data flows in one direction
locals {
  # Derived values are calculated once
  subnet_configs = {
    for az in var.availability_zones : az => {
      private_cidr = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, az))
      public_cidr  = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, az) + 100)
    }
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnet_configs
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.key
}
```

## Syntax and Style Standards

### Formatting (Enforced by `terraform fmt`)
- **2 spaces** for indentation
- **120 character** line limit
- **Blank lines** between resource blocks
- **Trailing newline** at end of file

### Naming Conventions
- **snake_case** for all identifiers: `vpc_main`, `web_server_sg`, `database_subnet_group`
- **Descriptive names**: `user_data_bucket` not `bucket1`
- **Consistent prefixes**: `aws_instance.web_server`, `aws_instance.api_server`

### Comments
```hcl
# Use # for comments, not //
# Use ---- for section delimiters

# ---------------------------------------------------------------------------------------------------------------------
# VPC CONFIGURATION
# Creates the main VPC and associated networking components
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  # Core VPC settings
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}
```

### Variable Definitions
```hcl
# Always include description, type, and validation when appropriate
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}

# Prefer explicit object types over free-form maps
variable "database_config" {
  description = "RDS database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })
}
```

## Avoiding Complexity Traps

### 1. Implicit Dependencies
```hcl
# Trap - Resource depends on naming convention
data "aws_security_group" "web" {
  name = "${var.environment}-web-sg"  # Breaks if naming changes
}

# Better - Explicit reference
variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}
```

### 2. Conditional Complexity
```hcl
# Trap - Nested conditionals
count = var.create_database && var.environment == "prod" && length(var.subnets) > 1 ? 1 : 0

# Better - Use locals for clarity
locals {
  create_production_database = (
    var.create_database && 
    var.environment == "prod" && 
    length(var.subnets) > 1
  )
}

resource "aws_db_instance" "main" {
  count = local.create_production_database ? 1 : 0
  # ...
}
```

### 3. Hardcoded Values
```hcl
# Trap - Magic numbers and strings
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" > /var/www/html/index.html
  EOF
}

# Better - Explicit configuration
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  user_data     = templatefile("${path.module}/user-data.sh", var.user_data_vars)
}
```

### 4. Overly Generic Modules
```hcl
# Trap - One module tries to handle everything
variable "create_vpc" { type = bool }
variable "create_subnets" { type = bool }
variable "create_nat_gateway" { type = bool }
variable "create_internet_gateway" { type = bool }
# ... 20 more boolean flags

# Better - Focused, single-purpose modules
module "vpc" {
  source = "./modules/vpc"
  # Only VPC-related configuration
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
  # Only subnet-related configuration
}
```

## AI Agent Guidelines

### Code Analysis Priority
1. **Reasoning clarity**: Can you predict what infrastructure this creates?
2. **Change impact**: Are modifications localized and predictable?
3. **Dependency clarity**: Are resource relationships explicit?
4. **Interface quality**: Are module boundaries clean and minimal?
5. **Syntax compliance**: Does it follow formatting and naming rules?

### Code Generation Principles
```hcl
# Generate code that explains itself
resource "aws_vpc" "main" {
  # VPC CIDR must not overlap with existing networks
  cidr_block = var.vpc_cidr
  
  # DNS settings required for EKS clusters
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}
```

### When Refactoring
1. **Preserve behavior**: Ensure no unintended infrastructure changes
2. **Extract complexity**: Move complex expressions to locals with descriptive names
3. **Explicit dependencies**: Replace implicit references with explicit variable passing
4. **Simplify conditionals**: Use locals to break down complex boolean logic
5. **Add context**: Include comments explaining non-obvious decisions

### Common Refactoring Patterns
```hcl
# Before - Complex inline expression
resource "aws_subnet" "private" {
  count = var.environment == "prod" ? length(var.availability_zones) : min(2, length(var.availability_zones))
  
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + (var.environment == "prod" ? 0 : 10))
}

# After - Clear intent with locals
locals {
  subnet_count = var.environment == "prod" ? length(var.availability_zones) : min(2, length(var.availability_zones))
  
  # Production subnets start at .0.0, non-prod at .10.0 to avoid conflicts
  cidr_offset = var.environment == "prod" ? 0 : 10
}

resource "aws_subnet" "private" {
  count = local.subnet_count
  
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + local.cidr_offset)
  availability_zone = var.availability_zones[count.index]
}
```

### Testing Guidance
Focus on **behavior verification** over syntax checking:
- Does the plan show expected resource changes?
- Are dependencies resolved in the correct order?
- Do variable changes produce predictable plan diffs?
- Can modules be composed without conflicts?

Remember: Simple is not always easy, but it is always better for long-term maintainability.

---
Source: .ruler/terraform-test.md
---
# Terraform Test Guide for AI Agents

This guide emphasizes creating simple, maintainable tests that validate essential Terraform module behavior using Terratest.

## Testing Philosophy

### What We're Actually Testing
Terraform tests validate the **contract** of your module, not AWS services:
- **Configuration validity**: Does the module accept inputs correctly?
- **Resource planning**: Does Terraform generate the expected plan?
- **Output correctness**: Do outputs match expected values?
- **Edge case handling**: How does the module behave with unusual inputs?

### Simple vs Comprehensive
- **Simple**: Tests focus on one concern and have clear pass/fail criteria
- **Comprehensive**: Tests try to cover every possible scenario and become brittle
- **Choose simple**: Write tests that are easy to understand and maintain

### Plan-Only Testing Philosophy
```go
// Good - Tests the contract without infrastructure costs
planOutput := terraform.Plan(t, terraformOptions)
assert.Contains(t, planOutput, "aws_vpc.main")

// Avoid - Tests AWS service behavior, not module logic
terraform.Apply(t, terraformOptions)
vpcId := terraform.Output(t, terraformOptions, "vpc_id")
// This tests AWS, not your module
```

## Test Design Principles

### Single Responsibility
Each test should validate **one aspect** of module behavior:

```go
// Good - Tests default behavior
func TestVPCDefaults(t *testing.T) {
    // Test that module works with minimal configuration
}

// Good - Tests feature flag
func TestVPCWithNATGateway(t *testing.T) {
    // Test that nat_gateway flag works correctly
}

// Avoid - Tests multiple unrelated features
func TestVPCEverything(t *testing.T) {
    // Tests defaults AND NAT gateway AND custom CIDR AND...
}
```

### Predictable Failure
Test failures should clearly indicate what went wrong:

```go
// Good - Clear assertion with context
assert.Contains(t, planOutput, "aws_nat_gateway.main", 
    "NAT gateway should be created when nat_gateway_enabled=true")

// Avoid - Unclear assertion
assert.NotEmpty(t, planOutput)
```

### Test Independence
Tests should not depend on each other or external state:

```go
// Good - Each test uses unique names
func TestVPCDefaults(t *testing.T) {
    uniqueName := fmt.Sprintf("test-vpc-%d", time.Now().Unix())
    terraformOptions := &terraform.Options{
        Vars: map[string]interface{}{
            "name": uniqueName,
        },
    }
}
```

### Essential vs Incidental Testing
Focus on **essential complexity** (what the module should do) rather than **incidental complexity** (implementation details):

```go
// Essential - Tests the module's contract
assert.Contains(t, planOutput, "cidr_block = \"10.0.0.0/16\"")

// Incidental - Tests implementation details
assert.Contains(t, planOutput, "depends_on = [aws_internet_gateway.main]")
```

## Repository Organization

### Structure Purpose
Each directory serves a single, clear purpose:

```
project/
├── modules/                 # The actual Terraform modules
├── examples/               # Demonstration of module usage
│   ├── defaults/          # Minimal viable configuration
│   └── complete/          # Full feature demonstration
└── test/                  # Validation of examples
    ├── go.mod
    ├── shared_test.go     # Common utilities
    ├── defaults_test.go   # Tests for defaults example
    └── complete_test.go   # Tests for complete example
```

### Example Directory Design
Each example should demonstrate **one usage pattern**:

**defaults/** - Minimal Configuration
```hcl
# Demonstrates basic functionality with sensible defaults
module "vpc" {
  source = "../../modules/vpc"
  
  name = var.name
  # All other values use module defaults
}
```

**complete/** - Full Configuration
```hcl
# Demonstrates all available options
module "vpc" {
  source = "../../modules/vpc"
  
  name                   = var.name
  cidr_block            = var.cidr_block
  enable_nat_gateway    = var.enable_nat_gateway
  availability_zones    = var.availability_zones
  # ... all other options
}
```

### Required Files Per Example
- **main.tf**: Module instantiation and providers
- **variables.tf**: Input definitions with validation
- **outputs.tf**: Output definitions (may be empty)
- **versions.tf**: Version constraints
- **terraform.auto.tfvars**: Values for required variables
- **README.md**: Usage documentation

## Implementation Patterns

### Test Structure Template
```go
func TestModuleExample(t *testing.T) {
    t.Parallel()
    
    // Generate unique test identifier
    testID := fmt.Sprintf("test-%d", time.Now().Unix())
    
    // Configure Terraform options
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/defaults",
        Vars: map[string]interface{}{
            "name": testID,
        },
        RetryableTerraformErrors: getRetryableErrors(),
        MaxRetries: 3,
        TimeBetweenRetries: 5 * time.Second,
    }
    
    // Ensure cleanup
    defer terraform.Destroy(t, terraformOptions)
    
    // Execute test
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Validate results
    assert.NotEmpty(t, planOutput)
    assert.Contains(t, planOutput, "Changes to Outputs")
}
```

### Shared Utilities (test/shared_test.go)
```go
package test

import (
    "fmt"
    "time"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

// generateTestName creates unique, AWS-compatible names
func generateTestName(prefix string) string {
    timestamp := time.Now().Unix()
    return fmt.Sprintf("%s-%d", prefix, timestamp)
}

// getBaseTerraformOptions provides common configuration
func getBaseTerraformOptions(terraformDir string) *terraform.Options {
    return &terraform.Options{
        TerraformDir:             terraformDir,
        RetryableTerraformErrors: getRetryableErrors(),
        MaxRetries:               3,
        TimeBetweenRetries:       5 * time.Second,
    }
}

// getRetryableErrors defines which errors should trigger retries
func getRetryableErrors() map[string]string {
    return map[string]string{
        // Network issues
        ".*timeout.*":                        "Network timeout",
        ".*connection reset.*":               "Connection reset",
        ".*no such host.*":                   "DNS resolution failure",
        
        // AWS throttling
        ".*Throttling.*":                     "AWS API throttling",
        ".*RequestLimitExceeded.*":           "Request limit exceeded",
        ".*TooManyRequestsException.*":       "Too many requests",
        
        // Temporary resource issues
        ".*ResourceNotReady.*":               "Resource not ready",
        ".*InvalidParameterValue.*subnet.*": "Subnet not yet available",
    }
}
```

### Test Categories

#### Configuration Validation Tests
```go
func TestValidConfiguration(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    terraformOptions.Vars = map[string]interface{}{
        "name": generateTestName("valid"),
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify plan succeeds and creates expected resources
    assert.Contains(t, planOutput, "Plan: 3 to add, 0 to change, 0 to destroy")
}
```

#### Feature Flag Tests
```go
func TestFeatureDisabled(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/complete")
    terraformOptions.Vars = map[string]interface{}{
        "name":                generateTestName("disabled"),
        "enable_nat_gateway": false,
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify NAT gateway is not created when disabled
    assert.NotContains(t, planOutput, "aws_nat_gateway")
}
```

#### Input Validation Tests
```go
func TestInvalidInput(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    terraformOptions.Vars = map[string]interface{}{
        "name":       generateTestName("invalid"),
        "cidr_block": "invalid-cidr", // This should cause validation failure
    }
    
    terraform.Init(t, terraformOptions)
    
    // Expect plan to fail with validation error
    _, err := terraform.PlanE(t, terraformOptions)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "invalid CIDR")
}
```

## Error Handling Strategy

### Retry Logic
Only retry **transient** errors, fail fast on **permanent** errors:

```go
// Transient - Should retry
".*Throttling.*"                    // AWS rate limiting
".*timeout.*"                       // Network issues
".*connection reset.*"              // Temporary connectivity

// Permanent - Should fail immediately  
".*InvalidParameterValue.*"         // Configuration error
".*UnauthorizedOperation.*"         // Permission issue
".*ValidationException.*"           // Input validation error
```

### Error Categories
1. **Network/Connectivity**: Temporary infrastructure issues
2. **AWS Throttling**: Rate limiting that resolves automatically
3. **Resource Dependencies**: Resources not yet available
4. **Configuration Errors**: Should fail immediately without retry

## CI/CD Integration

### Environment Setup
```yaml
# GitHub Actions example
env:
  AWS_DEFAULT_REGION: us-west-2
  TF_VAR_name_prefix: "ci-test"
  TF_VAR_environment: "ci"
```

### Test Execution
```bash
cd test
go mod tidy
go test -v -timeout 30m -parallel 4
```

### Cost Management
- Use plan-only testing to avoid AWS charges
- Set timeouts to prevent runaway tests
- Use unique naming to avoid resource conflicts

## AI Agent Guidelines

### Test Analysis
When examining existing tests, evaluate:

1. **Purpose Clarity**: Can you understand what each test validates?
2. **Failure Scenarios**: Will test failures clearly indicate the problem?
3. **Independence**: Can tests run in any order without conflicts?
4. **Essential Focus**: Do tests validate module contracts, not implementation details?

### Test Generation Principles

#### Start with Module Contract
```go
// Good - Tests what the module promises to do
func TestVPCCreatesSubnets(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    // ... setup
    
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify the module creates the promised subnets
    assert.Contains(t, planOutput, "aws_subnet.private")
    assert.Contains(t, planOutput, "aws_subnet.public")
}
```

#### Test Edge Cases Systematically
```go
// Test boundary conditions
func TestVPCWithMinimalCIDR(t *testing.T) {
    // Test with /28 CIDR (smallest practical)
}

func TestVPCWithLargeCIDR(t *testing.T) {
    // Test with /16 CIDR (largest common)
}

func TestVPCWithAllAZs(t *testing.T) {
    // Test with maximum availability zones
}
```

#### Generate Meaningful Test Names
```go
// Good - Name describes the scenario and expected outcome
func TestVPCWithNATGatewayCreatesInternetAccess(t *testing.T) {}
func TestVPCWithoutNATGatewayBlocksPrivateInternet(t *testing.T) {}

// Avoid - Generic names that don't explain the test
func TestVPCNAT(t *testing.T) {}
func TestVPCComplete(t *testing.T) {}
```

### Test Maintenance
When updating tests:

1. **Preserve Intent**: Understand what the original test was validating
2. **Update Assertions**: Ensure assertions still test the right behavior  
3. **Check Dependencies**: Verify test utilities still work correctly
4. **Validate Isolation**: Ensure tests don't interfere with each other

### Debugging Test Failures
Systematic approach to test failures:

1. **Read the Error**: What specific assertion failed?
2. **Check the Plan**: What did Terraform actually try to create?
3. **Verify Inputs**: Are test variables correct?
4. **Isolate the Issue**: Can you reproduce with `terraform plan` manually?
5. **Check Dependencies**: Are required resources/permissions available?

### Common Anti-Patterns to Avoid

#### Over-Testing
```go
// Avoid - Testing every possible input combination
func TestAllPossibleConfigurations(t *testing.T) {
    // This becomes unwieldy and doesn't add value
}

// Better - Test representative scenarios
func TestCommonConfigurations(t *testing.T) {
    // Test the most important use cases
}
```

#### Implementation Testing
```go
// Avoid - Testing Terraform internals
assert.Contains(t, planOutput, "depends_on")

// Better - Testing module behavior
assert.Contains(t, planOutput, "aws_vpc.main")
```

#### Complex Test Logic
```go
// Avoid - Tests that are hard to understand
func TestComplexScenario(t *testing.T) {
    if condition1 && condition2 {
        // Test scenario A
    } else if condition3 {
        // Test scenario B  
    } else {
        // Test scenario C
    }
}

// Better - Separate tests for each scenario
func TestScenarioA(t *testing.T) { /* Clear test logic */ }
func TestScenarioB(t *testing.T) { /* Clear test logic */ }
func TestScenarioC(t *testing.T) { /* Clear test logic */ }
```

## Key Takeaways

1. **Test the Contract**: Focus on what your module promises to do
2. **Keep It Simple**: Each test should have a single, clear purpose
3. **Make Failures Clear**: Test failures should immediately indicate the problem
4. **Plan-Only When Possible**: Avoid unnecessary AWS costs and complexity
5. **Design for Independence**: Tests should not depend on each other
6. **Focus on Essential Behavior**: Test what matters, not implementation details

Remember: The goal is not comprehensive coverage, but confidence in essential functionality.
