# [terraform-aws-arc-cicd](https://github.com/sourcefuse/terraform-aws-arc-cicd)

<a href="https://github.com/sourcefuse/terraform-aws-arc-cicd/releases/latest"><img src="https://img.shields.io/github/release/sourcefuse/terraform-aws-arc-cicd.svg?style=for-the-badge" alt="Latest Release"/></a> <a href="https://github.com/sourcefuse/terraform-aws-arc-cicd/commits"><img src="https://img.shields.io/github/last-commit/sourcefuse/terraform-aws-arc-cicd.svg?style=for-the-badge" alt="Last Updated"/></a> ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)


[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=sourcefuse_terraform-aws-arc-cicd&token=b697edbb45222daad2f3184fdb06b908aec00460)](https://sonarcloud.io/summary/new_code?id=sourcefuse_terraform-aws-arc-cicd)

[![Known Vulnerabilities](https://github.com/sourcefuse/terraform-aws-arc-cicd/actions/workflows/snyk.yaml/badge.svg)](https://github.com/sourcefuse/terraform-aws-arc-cicd/actions/workflows/snyk.yaml)
## Overview

For more information about this repository and its usage, please see [Terraform AWS ARC GitHub CICD Module Usage Guide](https://github.com/sourcefuse/terraform-aws-arc-cicd/blob/main/docs/module-usage-guide/README.md).

## Introduction

SourceFuse's AWS Reference Architecture (ARC) Terraform module automates the creation of AWS CodePipeline and CodeBuild projects, facilitating the build and deployment of both application code and Terraform modules. By defining reusable CodeBuild projects, it ensures consistent and efficient build processes that can be shared across multiple CodePipelines. This approach promotes standardization and reduces redundancy in the CI/CD pipeline configuration.

### Prerequisites
Before using this module, ensure you have the following:

- AWS credentials configured.
- Terraform installed.
- A working knowledge of Terraform.

## Getting Started

1. **Define the Module**

Initially, it's essential to define a Terraform module, which is organized as a distinct directory encompassing Terraform configuration files. Within this module directory, input variables and output values must be defined in the variables.tf and outputs.tf files, respectively. The following illustrates an example directory structure:



```plaintext
billing/
|-- main.tf
|-- variables.tf
|-- outputs.tf
```


2. **Define Input Variables**

Inside the `variables.tf` or in `*.tfvars` file, you should define values for the variables that the module requires.

3. **Use the Module in Your Main Configuration**
In your main Terraform configuration file (e.g., main.tf), you can use the module. Specify the source of the module, and version, For Example

```hcl
module "pipelines" {
  source = "sourcefuse/arc-cicd/aws"

  artifacts_bucket    = local.artifacts_bucket
  codestar_connection = local.codestar_connection

  role_data          = local.role_data
  codebuild_projects = local.codebuild_projects
  codepipelines      = local.codepipeline_data
  chatbot_data       = local.chatbot_data

  tags = module.tags.tags
}
```

4. **Output Values**

Inside the `outputs.tf` file of the module, you can define output values that can be referenced in the main configuration. For example:

```hcl
output "chatbot_sns_arns" {
  description = "SNS topics created by AWS Chatbot"
  value       = module.example.chatbot_sns_arns
}


```

5. **.tfvars**

Inside the `.tfvars` file of the module, you can provide desired values that can be referenced in the main configuration. For example:

Edit the [locals.tf](./examples/application/locals.tf) file and provide desired values.  

`artifacts_bucket` -  S3 Bucket name where artifacts are stored

`codestar_connection` - Codestar connection for authenticating to Github

`role_data` - Details about Roles to be created for Codepipeline and Codebuild projects

`codebuild_projects` -  List of Codebuild projects to be created

`codepipelines` - Codepipelines to be created

`chatbot_data` - local.chatbot_data


```hcl
locals {
  prefix = "arc-dev"

  backup_plan_name = "${local.prefix}-backup-plan"
  backup_role_name = "${local.prefix}-backup-restore"
  vault_name       = "${local.prefix}-backup-vault-1"

  backup_vault_data = {
    name                            = local.vault_name
    enable_encryption               = true
    backup_role_name                = local.backup_role_name
    kms_key_deletion_window_in_days = 7
    kms_key_admin_arns              = []
  }


  backup_plan = {
    name = local.backup_plan_name

    rules = [{
      name                     = "backup-rule-1"
      target_vault_name        = local.vault_name
      schedule                 = "cron(0 12 * * ? *)"
      recovery_point_tags      = module.tags.tags
      enable_continuous_backup = true

      lifecycle = [{ // its mandatory if `enable_continuous_backup = true` , error: Lifecycle must be specified for backup rule enabled continuous backup
        cold_storage_after = 0
        delete_after       = 35
      }]
    }]
  }

  backup_selection_data = {
    name      = "${local.prefix}-backup-selection"
    plan_name = local.backup_plan_name
    resources = ["*"]
    selection_tags = [{
      type  = "string"
      key   = "enable_backup"
      value = "true"
      }
    ]
  }

  vault_lock_configuration = {
    changeable_for_days = 3 // it has to be atleast 3
    max_retention_days  = 2
    min_retention_days  = 1
  }

}
```

## First Time Usage
***uncomment the backend block in [main.tf](./example/main.tf)***
```shell
terraform init -backend-config=config.dev.hcl
```
***If testing locally, `terraform init` should be fine***

Create a `dev` workspace
```shell
terraform workspace new dev
```

Plan Terraform
```shell
terraform plan -var-file dev.tfvars
```

Apply Terraform
```shell
terraform apply -var-file dev.tfvars
```

## Production Setup
```shell
terraform init -backend-config=config.prod.hcl
```

Create a `prod` workspace
```shell
terraform workspace new prod
```

Plan Terraform
```shell
terraform plan -var-file prod.tfvars
```

Apply Terraform
```shell
terraform apply -var-file prod.tfvars  
```

## Cleanup  
Destroy Terraform
```shell
terraform destroy -var-file dev.tfvars
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
| <a name="module_chatbot"></a> [chatbot](#module\_chatbot) | ./modules/chatbot | n/a |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ./modules/codebuild | n/a |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ./modules/codepipeline | n/a |
| <a name="module_role"></a> [role](#module\_role) | ./modules/iam-role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.artifact](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket"></a> [artifacts\_bucket](#input\_artifacts\_bucket) | s3 bucket used for codepipeline artifacts | `string` | n/a | yes |
| <a name="input_chatbot_data"></a> [chatbot\_data](#input\_chatbot\_data) | (optional) Chatbot details to create integration | <pre>object({<br>    name                     = string<br>    slack_channel_id         = string<br>    slack_workspace_id       = string<br>    guardrail_policies       = optional(list(string), ["arn:aws:iam::aws:policy/AWSAccountManagementReadOnlyAccess"])<br>    enable_slack_integration = bool<br>    role_polices = optional(list(object({<br>      policy_document = any<br>      policy_name     = string<br><br>    })), [])<br>    managed_policy_arns = optional(list(string), ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"])<br>  })</pre> | `null` | no |
| <a name="input_codebuild_projects"></a> [codebuild\_projects](#input\_codebuild\_projects) | Values to create Codebuild project | <pre>map(object({<br>    description                 = optional(string, "")<br>    build_timeout               = optional(number, 15)<br>    queued_timeout              = optional(number, 15)<br>    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")<br>    compute_image               = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")<br>    compute_type_container      = optional(string, "LINUX_CONTAINER")<br>    image_pull_credentials_type = optional(string, "CODEBUILD")<br>    privileged_mode             = optional(bool, false)<br>    build_type                  = string<br>    buildspec_file_name         = optional(string, null)<br>    buildspec_file              = optional(string, null)<br>    terraform_version           = optional(string, "terraform-1.5.0-1.x86_64")<br>    create_role                 = optional(bool, false)<br>    role_data = optional(object({<br>      name                                = string<br>      pipeline_service                    = optional(string, null)<br>      assume_role_arns                    = optional(list(string), null)<br>      github_secret_arn                   = optional(string, null)<br>      terraform_state_s3_bucket           = optional(string, null)<br>      dynamodb_lock_table                 = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>    }), null)<br>  }))</pre> | `null` | no |
| <a name="input_codepipelines"></a> [codepipelines](#input\_codepipelines) | Codepipeline data to create pipeline and stages | <pre>map(object({<br>    artifact_store_s3_kms_arn = string<br><br>    source_repositories = list(object({<br>      name              = string<br>      output_artifacts  = optional(list(string), ["source_output"])<br>      github_repository = string<br>      github_branch     = string<br>      auto_trigger      = optional(bool, true)<br>    }))<br><br>    pipeline_stages = list(object({<br>      stage_name       = string<br>      name             = string<br>      category         = optional(string, "Build")<br>      provider         = optional(string, "CodeBuild")<br>      input_artifacts  = optional(list(string), [])<br>      output_artifacts = optional(list(string), [])<br>      version          = string<br>      project_name     = optional(string, null)<br>      environment_variables = optional(list(object({<br>        name  = string<br>        value = string<br>        type  = optional(string, "PLAINTEXT")<br>        })),<br>        []<br>      )<br>    }))<br>    create_role = optional(bool, false)<br>    role_data = optional(object({<br>      name                                = string<br>      github_secret_arn                   = optional(string, null)<br>      additional_iam_policy_doc_json_list = optional(list(any), [])<br>      }),<br>    null)<br><br>    trigger = optional(list(object({<br>      source_action_name = string<br><br>      push = list(object({<br>        branches = object({<br>          includes = list(string)<br>          excludes = list(string)<br>        })<br>        file_paths = object({<br>          includes = list(string)<br>          excludes = list(string)<br>        })<br>        })<br>      )<br><br>      pull_request = list(object({<br>        events = list(string)<br>        filter = list(object({<br>          branches = object({<br>            includes = list(string)<br>            excludes = list(string)<br>          })<br>          file_paths = object({<br>            includes = list(string)<br>            excludes = list(string)<br>          })<br>          })<br>      ) }))<br><br>    })), [])<br><br>    notification_data = optional(map(object({<br>      detail_type = optional(string, "FULL")<br>      event_type_ids = optional(list(string), [<br>        "codepipeline-pipeline-pipeline-execution-failed",<br>        "codepipeline-pipeline-pipeline-execution-canceled",<br>        "codepipeline-pipeline-pipeline-execution-started",<br>        "codepipeline-pipeline-pipeline-execution-resumed",<br>        "codepipeline-pipeline-pipeline-execution-succeeded",<br>        "codepipeline-pipeline-pipeline-execution-superseded",<br>        "codepipeline-pipeline-manual-approval-failed",<br>        "codepipeline-pipeline-manual-approval-needed"<br>      ])<br>      targets = list(object({<br>        address = string                  // eg SNS arn<br>        type    = optional(string, "SNS") // Type can be "SNS" , AWSChatbotSlack etc<br>      }))<br>    })), null)<br><br>  }))</pre> | `{}` | no |
| <a name="input_codestar_connection"></a> [codestar\_connection](#input\_codestar\_connection) | codestar connection arn for github repository | `string` | n/a | yes |
| <a name="input_role_data"></a> [role\_data](#input\_role\_data) | Roles to be created | <pre>map(object({<br>    pipeline_service                    = string<br>    assume_role_arns                    = optional(list(string), null)<br>    github_secret_arn                   = optional(string, null)<br>    terraform_state_s3_bucket           = optional(string, null)<br>    dynamodb_lock_table                 = optional(string, null)<br>    additional_iam_policy_doc_json_list = optional(list(any), [])<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for AWS resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chatbot_sns_arns"></a> [chatbot\_sns\_arns](#output\_chatbot\_sns\_arns) | SNS topic integrated to AWS Chatbot |
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
