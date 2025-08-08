# Terraform Module Guide for AI Agents

This guide emphasizes creating simple, composable Terraform modules that are easy to understand, use, and maintain.

## Module Design Philosophy

### Single Responsibility Principle
Each module should have **one reason to change**:

```hcl
# Good - VPC module handles only networking concerns
module "vpc" {
  source = "./modules/vpc"
  
  name       = var.network_name
  cidr_block = var.vpc_cidr
  
  availability_zones = var.azs
}

# Good - Separate module for compute concerns  
module "web_servers" {
  source = "./modules/ec2-asg"
  
  name     = var.app_name
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.private_subnet_ids
  
  min_size = var.instance_count
}

# Avoid - Module that handles everything
module "entire_application" {
  # Creates VPC, subnets, security groups, load balancers,
  # EC2 instances, RDS databases, S3 buckets, etc.
  # Too many responsibilities, hard to understand and reuse
}
```

### Composition Over Configuration
Design modules to **compose well together** rather than trying to handle every possible scenario:

```hcl
# Good - Focused modules that compose
module "database" {
  source = "./modules/rds"
  
  name     = "${var.app_name}-db"
  engine   = "postgres"
  subnets  = module.vpc.database_subnet_ids
  
  # Module focuses on database concerns only
}

module "app_servers" {
  source = "./modules/ec2-asg"
  
  name            = var.app_name
  subnets         = module.vpc.private_subnet_ids
  database_endpoint = module.database.endpoint
  
  # Module focuses on compute concerns only
}

# Avoid - Overly configurable single module
module "application_stack" {
  create_database    = var.needs_database
  create_cache       = var.needs_cache
  create_load_balancer = var.needs_lb
  database_engine    = var.db_engine
  # ... 50+ configuration options
  # Module tries to be everything to everyone
}
```

### Interface Clarity
Module interfaces should be **predictable and minimal**:

```hcl
# Good - Clear, essential inputs
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for resource placement"
  type        = list(string)
}

# Good - Essential outputs
output "security_group_id" {
  description = "Security group ID for additional rules"
  value       = aws_security_group.main.id
}

output "instance_ids" {
  description = "EC2 instance IDs for monitoring"
  value       = aws_instance.main[*].id
}
```

## Interface Design Patterns

### Input Variables
Focus on **essential configuration** and provide sensible defaults:

```hcl
# Required inputs - things the module cannot decide
variable "name" {
  description = "Unique name for this instance of the module"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name))
    error_message = "Name must be 2-24 characters, lowercase, start with letter."
  }
}

variable "vpc_id" {
  description = "VPC where resources will be created"
  type        = string
}

# Optional inputs with sensible defaults
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = bool
  default     = true
}

# Complex configurations - use objects for related settings
variable "scaling_config" {
  description = "Auto scaling configuration"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  default = {
    min_size         = 1
    max_size         = 3
    desired_capacity = 2
  }
}
```

### Feature Flags
Use **boolean flags** for optional functionality:

```hcl
variable "create_load_balancer" {
  description = "Create an Application Load Balancer"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

# Use feature flags in resource creation
resource "aws_lb" "main" {
  count = var.create_load_balancer ? 1 : 0
  
  name     = var.name
  subnets  = var.public_subnet_ids
  
  tags = local.common_tags
}
```

### Output Values
Provide outputs that **enable composition**:

```hcl
# Identity outputs - for referencing resources
output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Security group identifier for additional rules"
  value       = aws_security_group.main.id
}

# Connection outputs - for dependent resources
output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "subnet_ids" {
  description = "Subnet IDs for resource placement"
  value       = aws_subnet.main[*].id
}

# Avoid outputs that expose implementation details
# output "internal_resource_arn" { ... }  # Not useful for composition
```

## Implementation Patterns

### Resource Naming
Create **consistent, predictable names**:

```hcl
locals {
  # Common naming prefix
  name_prefix = var.name
  
  # Consistent tagging
  common_tags = {
    Name          = var.name
    Environment   = var.environment
    Module        = "vpc"
    ManagedBy     = "terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.key}"
    Type = "private"
  })
}
```

### Version Management
**Pin versions** for reliability:

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Track module version for debugging
locals {
  module_version = "1.2.3"  # Updated by CI/CD
}
```

### Data Source Patterns
**Centralize external dependencies** and make them explicit:

```hcl
# dependencies.tf - All external data in one place
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# Use locals to make data available throughout module
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  azs        = data.aws_availability_zones.available.names
}

# Pass to submodules rather than having them call data sources
module "subnets" {
  source = "./modules/subnets"
  
  availability_zones = local.azs
  account_id        = local.account_id
}
```

### Environment Configuration
**Simplify environment handling** with sensible categories:

```hcl
variable "environment" {
  description = "Environment type for resource sizing"
  type        = string
  default     = "development"
  
  validation {
    condition = contains([
      "development", "staging", "production"
    ], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

# Use environment to set appropriate defaults
locals {
  instance_configs = {
    development = {
      instance_type = "t3.micro"
      min_size     = 1
      max_size     = 2
    }
    staging = {
      instance_type = "t3.small"
      min_size     = 2
      max_size     = 4
    }
    production = {
      instance_type = "t3.medium"
      min_size     = 3
      max_size     = 10
    }
  }
  
  config = local.instance_configs[var.environment]
}

resource "aws_launch_template" "main" {
  instance_type = local.config.instance_type
  # ...
}
```

## Repository Organization

### File Structure
**Separate concerns** into focused files:

```
terraform-aws-vpc/
├── main.tf              # Core VPC resources
├── subnets.tf           # Subnet resources
├── routing.tf           # Route tables and routes
├── security.tf          # Security groups and NACLs
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── locals.tf            # Local computations
├── versions.tf          # Version constraints
├── dependencies.tf      # External data sources
├── README.md            # Usage documentation
├── CHANGELOG.md         # Version history
├── examples/
│   ├── simple/          # Minimal configuration
│   └── complete/        # Full feature demo
├── modules/
│   └── nat-gateway/     # Optional submodules
└── test/
    ├── simple_test.go
    └── complete_test.go
```

### Example Organization
Provide **clear usage examples**:

**examples/simple/** - Minimal Configuration
```hcl
module "vpc" {
  source = "../../"
  
  name       = var.name
  cidr_block = "10.0.0.0/16"
  
  # Use all defaults for everything else
}
```

**examples/complete/** - Full Configuration
```hcl
module "vpc" {
  source = "../../"
  
  name       = var.name
  cidr_block = var.cidr_block
  
  availability_zones = var.availability_zones
  
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
  
  tags = var.tags
}
```

### Branching Strategy
Keep it **simple and predictable**:

- **main** - Production-ready releases
- **feature/feature-name** - New features
- **fix/issue-description** - Bug fixes

Use **semantic versioning** (v1.0.0, v1.1.0, v1.1.1) and tag releases on main.

## Provider-Specific Patterns

### AWS Best Practices

#### IAM Policies
Use **policy documents** for maintainability:

```hcl
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
```

#### Encryption
**Default to encryption** with customer-managed keys:

```hcl
variable "kms_key_id" {
  description = "KMS key for encryption (creates new key if not provided)"
  type        = string
  default     = null
}

resource "aws_kms_key" "main" {
  count = var.kms_key_id == null ? 1 : 0
  
  description = "Key for ${var.name}"
  tags        = local.common_tags
}

locals {
  kms_key_id = var.kms_key_id != null ? var.kms_key_id : aws_kms_key.main[0].arn
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
```

#### Monitoring
**Create log groups explicitly**:

```hcl
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
  
  tags = local.common_tags
}

resource "aws_lambda_function" "main" {
  # ... other configuration
  
  depends_on = [aws_cloudwatch_log_group.main]
}
```

## Avoiding Complexity Traps

### Over-Configuration
```hcl
# Trap - Too many options
variable "database_config" {
  type = object({
    engine                = optional(string, "postgres")
    engine_version        = optional(string, "13.7")
    instance_class        = optional(string, "db.t3.micro")
    allocated_storage     = optional(number, 20)
    max_allocated_storage = optional(number, 100)
    storage_type          = optional(string, "gp2")
    storage_encrypted     = optional(bool, true)
    # ... 20+ more options
  })
}

# Better - Essential options with environment-based defaults
variable "database_size" {
  description = "Database size category"
  type        = string
  default     = "small"
  
  validation {
    condition     = contains(["small", "medium", "large"], var.database_size)
    error_message = "Size must be small, medium, or large."
  }
}

locals {
  db_configs = {
    small  = { instance_class = "db.t3.micro", storage = 20 }
    medium = { instance_class = "db.t3.small", storage = 100 }
    large  = { instance_class = "db.t3.medium", storage = 500 }
  }
}
```

### Implicit Dependencies
```hcl
# Trap - Hidden dependencies
data "aws_security_group" "existing" {
  name = "${var.environment}-web-sg"  # Assumes naming convention
}

# Better - Explicit inputs
variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}
```

### Tight Coupling
```hcl
# Trap - Module knows too much about its environment
resource "aws_instance" "web" {
  # Assumes specific VPC structure
  subnet_id = data.aws_subnet.web.id
  
  # Assumes specific security group naming
  vpc_security_group_ids = [data.aws_security_group.web.id]
}

# Better - Accept dependencies as inputs
variable "subnet_id" {
  description = "Subnet for instance placement"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups for the instance"
  type        = list(string)
}
```

## AI Agent Guidelines

### Module Boundary Analysis
When designing a module, ask:

1. **Single Purpose**: What is the **one thing** this module should do well?
2. **Change Triggers**: What would cause this module to need modification?
3. **Composition**: How will this module work with others?
4. **Interface Clarity**: Can users predict what this module will create?

```hcl
# Good module boundary - focused on VPC networking
module "vpc" {
  # Creates: VPC, subnets, route tables, internet gateway
  # Purpose: Provide network foundation
  # Interface: CIDR blocks in, subnet IDs out
}

# Good module boundary - focused on compute cluster  
module "web_cluster" {
  # Creates: Launch template, auto scaling group, load balancer
  # Purpose: Provide scalable web application hosting
  # Interface: VPC details in, endpoints out
}

# Poor module boundary - does everything
module "web_application" {
  # Creates: VPC, subnets, security groups, load balancer,
  #          auto scaling group, RDS, S3, CloudFront, Route53
  # Too many responsibilities, hard to understand and reuse
}
```

### Interface Design Process

1. **Start with Outputs**: What do consumers need from this module?
2. **Work Backwards to Inputs**: What information is required to produce those outputs?
3. **Minimize Surface Area**: Remove any inputs that aren't essential
4. **Group Related Settings**: Use objects for cohesive configuration

```hcl
# Step 1: Define what consumers need
output "cluster_endpoint" {
  description = "Load balancer endpoint for the application"
  value       = aws_lb.main.dns_name
}

output "security_group_id" {
  description = "Security group for additional rules"
  value       = aws_security_group.main.id
}

# Step 2: Work backwards to required inputs
variable "name" {
  description = "Name for the cluster resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC where cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for load balancer and instances"
  type        = list(string)
}

# Step 3: Group related optional settings
variable "scaling" {
  description = "Auto scaling configuration"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  default = {
    min_size         = 2
    max_size         = 6
    desired_capacity = 3
  }
}
```

### Code Generation Patterns

#### Start Simple, Add Complexity Gradually
```hcl
# Phase 1: Core functionality
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = var.name
  }
}

# Phase 2: Add essential features
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = var.name
  })
}

# Phase 3: Add operational features (when needed)
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}
```

#### Use Locals for Complex Logic
```hcl
# Extract complex expressions to locals
locals {
  # Calculate subnet configurations
  subnet_configs = {
    for az_idx, az in var.availability_zones : az => {
      private_cidr = cidrsubnet(var.cidr_block, 8, az_idx)
      public_cidr  = cidrsubnet(var.cidr_block, 8, az_idx + 100)
    }
  }
  
  # Determine if NAT gateways are needed
  needs_nat_gateway = var.enable_nat_gateway && length(var.private_subnets) > 0
}

resource "aws_subnet" "private" {
  for_each = var.create_private_subnets ? local.subnet_configs : {}
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.key
}
```

### Refactoring Strategies

#### Extract Submodules When Needed
```hcl
# Before - Everything in one module
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "private" { ... }
resource "aws_subnet" "public" { ... }
resource "aws_route_table" "private" { ... }
resource "aws_route_table" "public" { ... }
resource "aws_nat_gateway" "main" { ... }
resource "aws_internet_gateway" "main" { ... }
# 50+ more resources...

# After - Extracted submodules
module "subnets" {
  source = "./modules/subnets"
  
  vpc_id             = aws_vpc.main.id
  availability_zones = var.availability_zones
  private_cidrs      = var.private_subnet_cidrs
  public_cidrs       = var.public_subnet_cidrs
}

module "routing" {
  source = "./modules/routing"
  
  vpc_id           = aws_vpc.main.id
  private_subnets  = module.subnets.private_subnet_ids
  public_subnets   = module.subnets.public_subnet_ids
  enable_nat       = var.enable_nat_gateway
}
```

#### Simplify Variable Structures
```hcl
# Before - Complex nested structure
variable "subnets" {
  type = map(object({
    cidr              = string
    availability_zone = string
    type             = string
    route_table_id   = optional(string)
    nat_gateway_id   = optional(string)
    # ... many more optional fields
  }))
}

# After - Simplified with sensible defaults
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}
```

### Testing Integration
Design modules to be **easily testable**:

```hcl
# Include test-friendly outputs
output "resource_count" {
  description = "Number of resources created (for testing)"
  value = {
    subnets         = length(aws_subnet.private) + length(aws_subnet.public)
    route_tables    = length(aws_route_table.private) + length(aws_route_table.public)
    nat_gateways    = length(aws_nat_gateway.main)
  }
}

# Make resource creation predictable
locals {
  # Deterministic resource naming for tests
  expected_resources = [
    "aws_vpc.main",
    "aws_internet_gateway.main",
  ]
}
```

### Common Pitfalls to Avoid

1. **God Modules**: Modules that create too many different types of resources
2. **Configuration Overload**: Too many input variables that complect unrelated concerns
3. **Implicit Dependencies**: Modules that assume specific naming conventions or external resources
4. **Premature Optimization**: Adding complexity for hypothetical future needs
5. **Implementation Exposure**: Outputs that reveal internal implementation details

```hcl
# Avoid - God module
module "entire_app" {
  source = "./modules/everything"
  
  # Creates VPC, EC2, RDS, S3, Lambda, API Gateway, CloudFront...
  # Too many responsibilities
}

# Better - Focused modules
module "network" {
  source = "./modules/vpc"
  # Only network resources
}

module "compute" {
  source = "./modules/ec2-cluster"
  # Only compute resources
}

module "storage" {
  source = "./modules/rds"
  # Only database resources
}
```

### Documentation Standards

Generate clear documentation that explains **intent**, not just syntax:

```markdown
# VPC Module

Creates a VPC with public and private subnets across multiple availability zones.

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
}
```

## Design Decisions

- **Public subnets** have routes to the Internet Gateway for outbound internet access
- **Private subnets** route through NAT Gateways in public subnets  
- **One NAT Gateway per AZ** when `enable_nat_gateway = true` for high availability
- **DNS resolution enabled** by default for service discovery

## Composition

This module outputs subnet IDs and security group references for use by:
- Compute modules (EC2, ECS, EKS)
- Database modules (RDS, ElastiCache)  
- Load balancer modules (ALB, NLB)
```

### CI/CD Integration

Keep automation **simple and reliable**:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0
          
      - name: Terraform Format
        run: terraform fmt -check -recursive
        
      - name: Terraform Validate
        run: |
          terraform init
          terraform validate
          
      - name: Run Tests
        run: |
          cd test
          go test -v -timeout 30m

  release:
    if: github.ref == 'refs/heads/main'
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/release-please-action@v4
        with:
          release-type: terraform-module
```

## AI Agent Implementation Checklist

### Module Analysis Phase
- [ ] **Identify Core Purpose**: What is the single responsibility of this module?
- [ ] **Map Dependencies**: What external resources does this module require?
- [ ] **Define Boundaries**: What should this module NOT do?
- [ ] **Consider Composition**: How will this module work with others?

### Interface Design Phase  
- [ ] **Essential Inputs Only**: Remove any variables that aren't absolutely required
- [ ] **Predictable Outputs**: Ensure outputs enable composition with other modules
- [ ] **Sensible Defaults**: Provide defaults that work for common use cases
- [ ] **Input Validation**: Add validation rules for critical inputs

### Implementation Phase
- [ ] **Single File Focus**: Keep related resources in the same file
- [ ] **Consistent Naming**: Use predictable naming patterns throughout
- [ ] **Error Handling**: Fail fast with clear error messages
- [ ] **Resource Tags**: Apply consistent tagging strategy

### Documentation Phase
- [ ] **Usage Examples**: Provide both simple and complete examples
- [ ] **Design Rationale**: Explain key design decisions
- [ ] **Composition Guide**: Show how to use with other modules
- [ ] **Generated Docs**: Run `terraform-docs` to create reference documentation

### Testing Phase
- [ ] **Plan Validation**: Ensure `terraform plan` succeeds with examples
- [ ] **Resource Verification**: Verify expected resources are planned for creation
- [ ] **Edge Case Testing**: Test with boundary conditions and invalid inputs
- [ ] **Integration Testing**: Test composition with other modules

### Deployment Readiness
- [ ] **Version Constraints**: Pin Terraform and provider versions
- [ ] **Changelog**: Document changes for each version
- [ ] **Examples Work**: Verify all examples can be deployed successfully
- [ ] **Backwards Compatibility**: Ensure changes don't break existing consumers

## Key Principles Summary

1. **One Responsibility**: Each module should do one thing well
2. **Clear Interfaces**: Make inputs and outputs predictable and minimal  
3. **Compose Don't Configure**: Design modules to work together rather than trying to handle every scenario
4. **Simple Over Easy**: Choose clarity and maintainability over convenience features
5. **Fail Fast**: Validate inputs and fail with clear messages rather than creating broken infrastructure
6. **Document Intent**: Explain design decisions, not just usage syntax

Remember: The goal is not feature completeness, but **composable simplicity**. A set of focused, well-designed modules that work together is far more valuable than a single complex module that tries to do everything.
