# Terraform Style Guide for AI Agents

This guide follows the [Gruntwork Terraform Style Guide](https://docs.gruntwork.io/guides/style/terraform-style-guide/) and [HashiCorp's official style conventions](https://developer.hashicorp.com/terraform/language/style).

## Core Principles

1. **Always run `terraform fmt`** before committing code
2. Follow HashiCorp's official style conventions
3. Prioritize readability and maintainability
4. Use consistent naming and organization patterns

## Formatting Rules

### Indentation and Spacing
- Use **2 spaces** for indentation (never tabs)
- Maximum **120 characters** per line
- Use blank lines to separate logical sections

### Comments
- Use `#` for comments (not `//`)
- Use `# ----` for section delimiters
- Include descriptions for complex logic

## Naming Conventions

### Use snake_case for:
- Resource names: `aws_instance.web_server`
- Variable names: `vpc_cidr_block`
- Output names: `instance_public_ip`
- Local values: `common_tags`
- Module names: `vpc_module`

### Examples:
```hcl
# Good
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

# Bad
resource "aws_instance" "WebServer" {
  ami           = var.AmiId
  instance_type = var.instanceType
}
```

## Variable and Output Definitions

### Always Include:
- `description` - Clear explanation of purpose
- `type` - Explicit type constraint
- `default` (when appropriate) - Default value

### Variable Best Practices:
```hcl
# Good - Explicit object type
variable "vpc_config" {
  description = "VPC configuration settings"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
  })
}

# Avoid - Free-form map
variable "vpc_config" {
  description = "VPC configuration"
  type        = map(any)
}
```

### Output Best Practices:
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
```

## Conditional Logic

### Multi-line Conditionals:
```hcl
locals {
  instance_type = (
    var.environment == "production"
    ? "t3.large"
    : "t3.micro"
  )
}
```

## Resource Patterns

### Count vs for_each:
- Use `for_each` when resources need unique names/identifiers
- Use `count` for simple repetition with numeric indexing

```hcl
# Good - for_each with map
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-${each.key}"
  })
}

# Good - count for simple cases
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
```

## Common Anti-Patterns to Avoid

### 1. Hardcoded Values:
```hcl
# Bad
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
}

# Good
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}
```

### 2. Overly Complex Expressions:
```hcl
# Bad - Hard to read
resource "aws_security_group_rule" "example" {
  count = var.enable_https && var.environment == "prod" ? length(var.allowed_cidrs) : 0
}

# Good - Use locals for clarity
locals {
  create_https_rules = var.enable_https && var.environment == "prod"
}

resource "aws_security_group_rule" "example" {
  count = local.create_https_rules ? length(var.allowed_cidrs) : 0
}
```

### 3. Missing Error Handling:
```hcl
# Good - Include validation
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## AI Agent Specific Guidelines

### When Analyzing Code:
1. Check for `terraform fmt` compliance first
2. Verify all variables have descriptions and types
3. Ensure consistent naming conventions
4. Look for hardcoded values that should be variables
5. Validate proper use of locals for complex expressions

### When Writing Code:
1. Start with `terraform fmt` compatible formatting
2. Use explicit types for all variables
3. Add meaningful descriptions to all variables and outputs
4. Follow the file organization patterns
5. Include appropriate tags and common tag patterns
6. Use validation blocks for input constraints when applicable

### When Refactoring:
1. Preserve existing functionality
2. Improve readability through better naming
3. Extract hardcoded values to variables
4. Consolidate duplicate code into locals or modules
5. Add missing descriptions and type constraints
