# API CI/CD Pipeline

## Overview

This example demonstrates how to create a comprehensive CI/CD pipeline for building and deploying API applications using the `terraform-aws-arc-cicd` module. This pipeline combines application building with infrastructure deployment in a single automated workflow.

Key features:
- **Multi-repository support**: Pulls from both application and infrastructure repositories
- **API build and deploy**: CodeBuild project for building and pushing Docker images to ECR
- **Terraform integration**: Separate CodeBuild project for deploying infrastructure changes
- **Manual approval gate**: Review changes before deployment
- **Slack notifications**: AWS Chatbot integration for pipeline status updates
- **Cross-account deployment**: Support for assuming roles in different AWS accounts
- **ECS deployment**: Automated task updates and service deployments

This is useful for:
- Deploying containerized API applications to ECS
- Managing both application code and infrastructure in a unified pipeline
- Implementing multi-stage deployment workflows with approvals
- Coordinating deployments across multiple AWS accounts

## Usage

### Prerequisites

Before using this example, ensure you have:
- An existing CodeStar connection to GitHub (configured in `locals.tf`)
- S3 bucket for pipeline artifacts
- IAM roles in target AWS accounts for cross-account deployment
- ECR repository for Docker images
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
  - API build project with Docker support and ECR push permissions
  - Terraform apply project with state management
- **1 CodePipeline** with multiple stages:
  - Source stage (pulls from API and Terraform repositories)
  - Approval stage (manual review)
  - API build stage (builds Docker image, pushes to ECR)
  - Terraform deploy stage (applies infrastructure changes)
- **3 IAM Roles**:
  - CodePipeline execution role
  - CodeBuild role for API with ECR, Parameter Store, and Secrets Manager access
  - CodeBuild role for Terraform with state bucket and cross-account permissions
- **1 AWS Chatbot** configuration for Slack notifications
- **Pipeline notifications** for all pipeline events

## Pipeline Workflow

1. Pipeline triggers from GitHub repository changes
2. Source code is retrieved from both API and infrastructure repositories
3. Manual approval stage allows review before deployment
4. API build stage:
   - Builds Docker image from application code
   - Pushes image to ECR
   - Updates ECS task definition
   - Deploys to ECS service
5. Terraform deploy stage:
   - Applies infrastructure changes
   - Updates supporting AWS resources

## Customization

### Buildspec Files

The pipeline uses custom buildspec files located in the `buildspec/` directory:
- `buildspec-api.yaml`: Defines API build, test, and deployment steps
- Buildspec for Terraform is generated automatically by the module

### Environment Variables

Modify environment variables in `locals.tf` to customize:
- Target AWS accounts and roles
- Application names and namespaces
- ECS task and service names
- Terraform workspace and backend configuration
- Working directories for Terraform

### Multiple Environments

The `branch_map` in `locals.tf` allows mapping different Git branches to different environments:
```hcl
branch_map = {
  dev = {
    api       = "dev"
    terraform = "dev"
  }
  poc = {
    api       = "staging"
    terraform = "stg"
  }
}
```

### Slack Notifications

Configure Slack integration by updating the `chatbot_data` in `locals.tf` with your:
- Slack channel ID
- Slack workspace ID
- Desired notification event types

## Key Features Demonstrated

- Complete CI/CD workflow for containerized applications
- Multi-repository pipeline configuration
- Cross-account IAM role assumption
- ECR integration for Docker images
- ECS deployment automation
- Terraform infrastructure management
- Manual approval gates
- AWS Chatbot integration for notifications
- Parameter Store and Secrets Manager integration
- S3-based artifact storage

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
| [aws_iam_policy_document.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secret_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

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
