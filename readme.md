# [terraform-aws-arc-cicd](https://github.com/sourcefuse/terraform-aws-arc-cicd)

[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=sourcefuse_terraform-aws-arc-cicd)](https://sonarcloud.io/summary/new_code?id=sourcefuse_terraform-aws-arc-cicd)

[![Known Vulnerabilities](https://github.com/sourcefuse/terraform-aws-arc-cicd/actions/workflows/snyk.yaml/badge.svg)](https://github.com/sourcefuse/terraform-aws-arc-cicd/actions/workflows/snyk.yaml)
## Overview

For more information about this repository and its usage, please see [Terraform AWS ARC GitHub cicd Module Usage Guide](https://github.com/sourcefuse/terraform-aws-arc-cicd/blob/main/docs/module-usage-guide/README.md).

## Usage

To see a full example, check out the [main.tf](./example/main.tf) file in the example folder.  

```hcl
module "pipeline" {
  source      = ""
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
| <a name="module_role"></a> [role](#module\_role) | ./modules/iam-role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.artifact](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket"></a> [artifacts\_bucket](#input\_artifacts\_bucket) | s3 bucket used for codepipeline artifacts | `string` | n/a | yes |
| <a name="input_codebuild_projects"></a> [codebuild\_projects](#input\_codebuild\_projects) | Values to create Codebuild project | <pre>map(object({<br>    description                 = optional(string, "")<br>    build_timeout               = optional(number, 15)<br>    queued_timeout              = optional(number, 15)<br>    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")<br>    compute_image               = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")<br>    compute_type_container      = optional(string, "LINUX_CONTAINER")<br>    image_pull_credentials_type = optional(string, "CODEBUILD")<br>    privileged_mode             = optional(bool, false)<br>    build_type                  = string<br>    buildspec_file_name         = optional(string, null)<br>    buildspec_file              = optional(string, null)<br>    terraform_version           = optional(string, "terraform-1.5.0-1.x86_64")<br>    create_role                 = optional(bool, false)<br>    role_data = optional(object({<br>      name                                = string<br>      pipeline_service                    = optional(string, null)<br>      assume_role_arns                    = optional(list(string), null)<br>      github_secret_arn                   = optional(string, null)<br>      terraform_state_s3_bucket           = optional(string, null)<br>      dynamodb_lock_table                 = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>    }), null)<br>  }))</pre> | `null` | no |
| <a name="input_codepipelines"></a> [codepipelines](#input\_codepipelines) | Codepipeline data to create pipeline and stages | <pre>map(object({<br>    github_repository         = string<br>    github_branch             = string<br>    artifact_store_s3_kms_arn = string<br><br>    source_repositories = list(object({<br>      name              = string<br>      output_artifacts  = optional(list(string), ["source_output"])<br>      github_repository = string<br>      github_branch     = string<br>      auto_trigger      = optional(bool, true)<br>    }))<br><br>    pipeline_stages = list(object({<br>      stage_name       = string<br>      name             = string<br>      category         = optional(string, "Build")<br>      provider         = optional(string, "CodeBuild")<br>      input_artifacts  = optional(list(string), [])<br>      output_artifacts = optional(list(string), [])<br>      version          = string<br>      project_name     = optional(string, null)<br>      environment_variables = optional(list(object({<br>        name  = string<br>        value = string<br>        type  = optional(string, "PLAINTEXT")<br>        })),<br>        []<br>      )<br>    }))<br>    auto_trigger = optional(bool, true)<br>    create_role  = optional(bool, false)<br>    role_data = optional(object({<br>      name                                = string<br>      github_secret_arn                   = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>      }),<br>    null)<br>  }))</pre> | `{}` | no |
| <a name="input_codestar_connection"></a> [codestar\_connection](#input\_codestar\_connection) | codestar connection arn for github repository | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_role_data"></a> [role\_data](#input\_role\_data) | Roles to be created | <pre>map(object({<br>    pipeline_service                    = string<br>    assume_role_arns                    = optional(list(string), null)<br>    github_secret_arn                   = optional(string, null)<br>    terraform_state_s3_bucket           = optional(string, null)<br>    dynamodb_lock_table                 = optional(string, null)<br>    additional_iam_policy_doc_json_list = optional(list(any), [])<br>  }))</pre> | `{}` | no |
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
