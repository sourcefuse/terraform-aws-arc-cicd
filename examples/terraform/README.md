# Terraform Infrastructure Pipeline

## Overview

This example demonstrates how to create a CI/CD pipeline specifically for Terraform infrastructure deployments using the `terraform-aws-arc-cicd` module. This pipeline implements a production-ready Terraform workflow with plan, approval, and apply stages.

Key features:
- **Terraform-optimized pipeline**: Designed specifically for infrastructure as code
- **Plan and Apply workflow**: Separate CodeBuild projects for plan and apply
- **Manual approval gate**: Review Terraform plans before applying changes
- **State management**: Integration with S3 backend and DynamoDB locking
- **Cross-account deployment**: Deploy infrastructure across multiple AWS accounts
- **Slack notifications**: AWS Chatbot integration for deployment status updates
- **Workspace support**: Terraform workspace management per environment

This is useful for:
- Managing infrastructure as code deployments
- Implementing GitOps workflows for Terraform
- Enforcing review and approval processes for infrastructure changes
- Deploying infrastructure across multiple AWS accounts
- Managing multiple environments with Terraform workspaces
- Centralizing infrastructure deployment from a shared CI/CD account

## Usage

### Prerequisites

Before using this example, ensure you have:
- An existing CodeStar connection to GitHub (configured in `locals.tf`)
- S3 bucket for pipeline artifacts
- S3 bucket for Terraform state with versioning enabled
- DynamoDB table for Terraform state locking
- IAM roles in target AWS accounts with appropriate permissions
- Slack workspace and channel IDs for notifications (if using Chatbot)

### Initialize Terraform
```shell
terraform init
```

### Apply with tfvars file
```shell
terraform apply -var-file=dev.tfvars
```

## What Gets Created

This example creates:
- **2 CodeBuild Projects**:
  - Terraform plan project (runs `terraform plan`)
  - Terraform apply project (runs `terraform apply`)
- **1 CodePipeline** with stages:
  - Source stage (pulls from Terraform repository)
  - Terraform plan stage (generates and displays plan)
  - Approval stage (manual review of plan)
  - Terraform apply stage (applies approved changes)
- **2 IAM Roles**:
  - CodePipeline execution role
  - CodeBuild role with Terraform state access and cross-account permissions
- **1 AWS Chatbot** configuration for Slack notifications
- **Pipeline notifications** for all pipeline events

## Pipeline Workflow

1. Pipeline triggers from GitHub repository changes
2. Source code is retrieved from the Terraform repository
3. Terraform plan stage:
   - Initializes Terraform with remote backend
   - Selects or creates workspace
   - Runs `terraform plan`
   - Outputs plan for review
4. Manual approval stage allows team to review plan
5. Terraform apply stage:
   - Re-initializes Terraform
   - Runs `terraform apply` with approved plan
   - Updates infrastructure

## Customization

### Terraform Configuration

Modify the Terraform configuration in `locals.tf`:

```hcl
environment_variables = [
  {
    name  = "TF_VAR_FILE",
    value = "tfvars/${var.environment}.tfvars"
  },
  {
    name  = "WORKING_DIR",
    value = "terraform/example-module"
  },
  {
    name  = "BACKEND_CONFIG_FILE",
    value = "backend/config.shared-services.hcl"
  },
  {
    name  = "WORKSPACE",
    value = var.environment
  }
]
```

### Terraform Version

Specify the Terraform version in `locals.tf`:
```hcl
terraform_version = "terraform-1.8.3-1.x86_64"
```

### State Management

Configure S3 backend and DynamoDB locking in the IAM role configuration:
```hcl
terraform_state_s3_bucket = "example-shared-services-terraform-state"
dynamodb_lock_table       = "example-shared-services-terraform-state-lock"
```

### Cross-Account Deployment

Add multiple role ARNs for cross-account deployments:
```hcl
assume_role_arns = [
  local.environment_role[var.environment],
  "arn:aws:iam::account-id:role/management-role"
]
```

### Multiple Environments

The `branch_map` in `locals.tf` allows mapping different Git branches to different environments:
```hcl
branch_map = {
  dev = {
    terraform = "dev"
  }
  poc = {
    terraform = "stg"
  }
}
```

### Buildspec Customization

The module automatically generates buildspec files for Terraform, but you can customize:
- Pre-plan validation steps
- Post-apply verification
- Custom Terraform commands
- Additional security scanning

## Best Practices Demonstrated

This example implements several Terraform CI/CD best practices:

1. **Separation of Plan and Apply**: Dedicated CodeBuild projects ensure clear separation
2. **State Locking**: DynamoDB table prevents concurrent modifications
3. **Remote State**: S3 backend ensures consistent state across team
4. **Workspace Management**: Environment isolation using Terraform workspaces
5. **Manual Approval**: Human review before infrastructure changes
6. **Audit Trail**: CloudWatch Logs and pipeline history for compliance
7. **Cross-Account Access**: Secure role assumption for multi-account deployments

## Key Features Demonstrated

- Complete Terraform CI/CD workflow
- Plan before apply pattern
- Manual approval gates for infrastructure changes
- S3 backend and DynamoDB state locking
- Terraform workspace management
- Cross-account infrastructure deployment
- AWS Chatbot integration for notifications
- Environment-based branch mapping
- Custom Terraform version support
- Backend configuration management
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pipelines"></a> [pipelines](#module\_pipelines) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chatbot_sns_arns"></a> [chatbot\_sns\_arns](#output\_chatbot\_sns\_arns) | SNS topics created by AWS Chatbot |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
