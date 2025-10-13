# Multi-Account UI Deployment Pipeline

## Overview

This example demonstrates how to create a CI/CD pipeline for building and deploying UI applications across multiple AWS accounts using the `terraform-aws-arc-cicd` module. This pipeline is specifically designed for frontend applications that need to be deployed to different environments in separate AWS accounts.

Key features:
- **UI-focused pipeline**: Optimized for building and deploying frontend applications
- **Cross-account deployment**: Deploy to different AWS accounts based on environment
- **Manual approval gate**: Review changes before deployment to target accounts
- **Slack notifications**: AWS Chatbot integration for deployment status updates
- **GitHub integration**: CodeStar connection for source code management
- **Environment-based branching**: Map different Git branches to different environments

This is useful for:
- Deploying React, Angular, Vue, or other frontend applications
- Managing UI deployments across dev, staging, and production accounts
- Building static assets and deploying to S3 or CloudFront
- Implementing controlled release processes with approvals
- Centralizing UI deployment from a shared CI/CD account

## Usage

### Prerequisites

Before using this example, ensure you have:
- An existing CodeStar connection to GitHub (configured in `locals.tf`)
- S3 bucket for pipeline artifacts
- IAM roles in target AWS accounts with appropriate permissions for UI deployment
- Slack workspace and channel IDs for notifications (if using Chatbot)
- Target infrastructure (S3 buckets, CloudFront distributions, etc.) for UI deployment

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
- **1 CodeBuild Project** for UI:
  - Configured for building frontend applications
  - Custom buildspec from `buildspec/buildspec-ui.yaml`
  - Cross-account role assumption capability
- **1 CodePipeline** with stages:
  - Source stage (pulls from GitHub repository)
  - Approval stage (manual review)
  - UI build stage (builds and deploys frontend application)
- **2 IAM Roles**:
  - CodePipeline execution role
  - CodeBuild role with cross-account deployment permissions
- **1 AWS Chatbot** configuration for Slack notifications
- **Pipeline notifications** for all pipeline events

## Pipeline Workflow

1. Pipeline triggers from GitHub repository changes
2. Source code is retrieved from the UI repository
3. Manual approval stage allows review before deployment
4. UI build stage:
   - Installs dependencies (npm, yarn, etc.)
   - Builds frontend application
   - Assumes role in target AWS account
   - Deploys built assets to target infrastructure
   - Invalidates CloudFront cache (if applicable)

## Customization

### Buildspec File

The pipeline uses a custom buildspec file at `buildspec/buildspec-ui.yaml`. Customize it to:
- Use different package managers (npm, yarn, pnpm)
- Configure build commands
- Set environment variables for the build
- Define deployment steps
- Add testing phases

### Environment Variables

Modify environment variables in `locals.tf` to customize:
- Target AWS accounts and roles to assume
- Application name and namespace
- Deployment destinations
- Build configuration

### Multiple Environments

The `branch_map` in `locals.tf` allows mapping different Git branches to different environments:
```hcl
branch_map = {
  dev = {
    ui = "dev"
  }
  poc = {
    ui = "staging"
  }
}
```

### Slack Notifications

Configure Slack integration by updating the `chatbot_data` in `locals.tf` with your:
- Slack channel ID
- Slack workspace ID
- Desired notification event types

## Deployment Strategies

This example supports various UI deployment strategies:

### S3 + CloudFront
- Build static assets
- Upload to S3 bucket
- Invalidate CloudFront distribution

### Containerized UI
- Build Docker image with static assets
- Push to ECR
- Deploy to ECS or EKS

### Multi-Region Deployment
- Assume roles in different regions
- Deploy to multiple S3 buckets
- Update multiple CloudFront distributions

## Key Features Demonstrated

- UI-specific CI/CD workflow
- Cross-account deployment pattern
- GitHub integration via CodeStar connections
- Manual approval gates
- AWS Chatbot integration for notifications
- Environment-based branch mapping
- Flexible buildspec configuration
- IAM role assumption across accounts

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
