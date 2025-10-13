# Simple CodeBuild

## Overview

This example demonstrates how to create a simple, standalone AWS CodeBuild project using the `terraform-aws-arc-cicd` module with the following characteristics:

- **NO_SOURCE**: The CodeBuild project doesn't require any source code repository
- **NO_ARTIFACTS**: No artifacts are stored after build completion
- **No CodePipeline**: Standalone CodeBuild project without pipeline integration
- **No Slack/Chatbot**: No notification integration
- **No CodeStar Connection**: No GitHub/Bitbucket integration needed

This is useful for:
- Manual build triggers
- Running administrative tasks
- Testing build environments
- Custom automation scripts

## Usage

### Initialize Terraform
```shell
terraform init
```

### Apply with tfvars file
```shell
terraform apply -var-file=dev.tfvars
```

### Start a Build Manually

After the CodeBuild project is created, you can trigger a build manually via:

**AWS Console:**
1. Navigate to AWS CodeBuild
2. Select your project: `{namespace}-{environment}-simple-build`
3. Click "Start build"

**AWS CLI:**
```bash
aws codebuild start-build --project-name <namespace>-<environment>-simple-build
```

## What Gets Created

This example creates:
- **1 IAM Role** for CodeBuild with minimal permissions
- **1 CodeBuild Project** with:
  - Source type: `NO_SOURCE`
  - Artifacts type: `NO_ARTIFACTS`
  - Custom inline buildspec
  - Basic CloudWatch Logs integration

## Customization

### Custom Buildspec

The buildspec is defined inline in `locals.tf`. You can modify it to:
- Run custom scripts
- Install packages
- Execute tests
- Perform deployments
- Run maintenance tasks

Example: Add AWS CLI commands, install dependencies, or run Docker commands.

### Environment Variables

Add environment variables in the buildspec `env.variables` section or pass them when starting the build.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 5.0, < 7.0 |

## Key Features Demonstrated

- Standalone CodeBuild without source repository
- No S3 bucket required for artifacts
- Optional chatbot/Slack integration (disabled)
- Optional CodeStar connection (not used)
- Minimal IAM permissions
- Custom inline buildspec

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_simple_codebuild"></a> [simple\_codebuild](#module\_simple\_codebuild) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
