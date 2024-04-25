# [terraform-aws-arc-security](https://github.com/sourcefuse/terraform-aws-arc-security)

[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=sourcefuse_terraform-aws-arc-security)](https://sonarcloud.io/summary/new_code?id=sourcefuse_terraform-aws-arc-security)

[![Known Vulnerabilities](https://github.com/sourcefuse/terraform-aws-arc-security/actions/workflows/snyk.yaml/badge.svg)](https://github.com/sourcefuse/terraform-aws-arc-security/actions/workflows/snyk.yaml)
## Overview

The SourceFuse AWS Reference Architecture (ARC) Terraform module streamlines the management of Security Hub components, enhancing security posture and compliance for AWS environments. This module offers simplified configuration and deployment for Security Hub, optimizing resource allocation and threat detection capabilities.

For more information about this repository and its usage, please see [Terraform AWS ARC GitHub SECURITY Module Usage Guide](https://github.com/sourcefuse/terraform-aws-arc-security/blob/main/docs/module-usage-guide/README.md).

## Usage

To see a full example, check out the [main.tf](./example/main.tf) file in the example folder.  

```hcl
module "cloud_security" {
  source      = "sourcefuse/arc-security/aws"
  version     = "1.0.2"
  region      = var.region
  environment = var.environment
  namespace   = var.namespace

  enable_inspector    = true
  enable_aws_config   = true
  enable_guard_duty   = true
  enable_security_hub = false

  create_config_iam_role = true

  aws_config_sns_subscribers   = local.aws_config_sns_subscribers
  guard_duty_sns_subscribers   = local.guard_duty_sns_subscribers
  security_hub_sns_subscribers = local.security_hub_sns_subscribers

  aws_config_managed_rules       = var.aws_config_managed_rules
  enabled_security_hub_standards = local.security_hub_standards

  create_inspector_iam_role               = var.create_inspector_iam_role
  inspector_enabled_rules                 = var.inspector_enabled_rules
  inspector_schedule_expression           = var.inspector_schedule_expression
  inspector_assessment_event_subscription = var.inspector_assessment_event_subscription

  tags = module.tags.tags
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ./modules/codebuild | n/a |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ./modules/codepipeline | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_projects"></a> [codebuild\_projects](#input\_codebuild\_projects) | Values to create Codebuild project | <pre>map(object({<br>    description                 = optional(string, "")<br>    build_timeout               = optional(number, 15)<br>    queued_timeout              = optional(number, 15)<br>    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")<br>    compute_image               = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")<br>    compute_type_container      = optional(string, "LINUX_CONTAINER")<br>    image_pull_credentials_type = optional(string, "CODEBUILD")<br>    artifacts_bucket            = string<br>    build_type                  = string<br>    buildspec_file_name         = optional(string, null)<br>    buildspec_file              = optional(string, null)<br>    terraform_version           = optional(string, null)<br>    create_role                 = optional(bool, false)<br>    role_data = object({<br>      name                                = string<br>      pipeline_service                    = optional(string, null)<br>      assume_role_arns                    = optional(list(string), null)<br>      codestar_connection                 = optional(string, null)<br>      github_secret_arn                   = optional(string, null)<br>      terraform_state_s3_bucket           = optional(string, null)<br>      dynamodb_lock_table                 = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>    })<br>  }))</pre> | `null` | no |
| <a name="input_codepipeline_data"></a> [codepipeline\_data](#input\_codepipeline\_data) | Codepipeline data to create pipeline and stages | <pre>object({<br>    name                      = string<br>    github_repository         = string<br>    github_branch             = string<br>    codestar_connection       = string<br>    artifacts_bucket          = string<br>    artifact_store_s3_kms_arn = string<br>    pipeline_stages = list(object({<br>      stage_name       = string<br>      name             = string<br>      category         = optional(string, "Build")<br>      provider         = optional(string, "CodeBuild")<br>      input_artifacts  = optional(list(string), [])<br>      output_artifacts = optional(list(string), [])<br>      version          = string<br>      project_name     = optional(string, null)<br>      environment_variables = optional(list(object({<br>        name  = string<br>        value = string<br>        type  = string<br>        })),<br>        []<br>      )<br>    }))<br>    auto_trigger = optional(bool, true)<br>    create_role  = optional(bool, false)<br>    role_data = object({<br>      name                                = string<br>      codestar_connection                 = optional(string, null)<br>      github_secret_arn                   = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for AWS resources | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

### Git commits

while Contributing or doing git commit please specify the breaking change in your commit message whether its major,minor or patch

For Example

```sh
git commit -m "your commit message #major"
```
By specifying this , it will bump the version and if you dont specify this in your commit message then by default it will consider patch and will bump that accordingly


## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
  ```sh
  pre-commit install
  ```

### Tests
- Tests are available in `test` directory
- Configure the dependencies
  ```sh
  cd test/
  go mod init github.com/sourcefuse/terraform-aws-refarch-<module_name>
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test  
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:
- SourceFuse
