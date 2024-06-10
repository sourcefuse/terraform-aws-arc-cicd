variable "tags" {
  type        = map(string)
  description = "Tags for AWS resources"
}

variable "artifacts_bucket" {
  type        = string
  description = "s3 bucket used for codepipeline artifacts"
}

variable "codestar_connection" {
  type        = string
  description = "codestar connection arn for github repository"
}

variable "codebuild_projects" {
  type = map(object({
    description                 = optional(string, "")
    build_timeout               = optional(number, 15)
    queued_timeout              = optional(number, 15)
    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")
    compute_image               = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")
    compute_type_container      = optional(string, "LINUX_CONTAINER")
    image_pull_credentials_type = optional(string, "CODEBUILD")
    privileged_mode             = optional(bool, false)
    build_type                  = string
    buildspec_file_name         = optional(string, null)
    buildspec_file              = optional(string, null)
    terraform_version           = optional(string, "terraform-1.5.0-1.x86_64")
    create_role                 = optional(bool, false)
    role_data = optional(object({
      name                                = string
      pipeline_service                    = optional(string, null)
      assume_role_arns                    = optional(list(string), null)
      github_secret_arn                   = optional(string, null)
      terraform_state_s3_bucket           = optional(string, null)
      dynamodb_lock_table                 = optional(string, null)
      additional_iam_policy_doc_json_list = optional(list(any), [])
    }), null)
  }))
  description = "Values to create Codebuild project"
  default     = null // null  doesn't create codebuild project
}

variable "codepipelines" {
  type = map(object({
    artifact_store_s3_kms_arn = string

    source_repositories = list(object({
      name              = string
      output_artifacts  = optional(list(string), ["source_output"])
      github_repository = string
      github_branch     = string
      auto_trigger      = optional(bool, true)
    }))

    pipeline_stages = list(object({
      stage_name       = string
      name             = string
      category         = optional(string, "Build")
      provider         = optional(string, "CodeBuild")
      input_artifacts  = optional(list(string), [])
      output_artifacts = optional(list(string), [])
      version          = string
      project_name     = optional(string, null)
      environment_variables = optional(list(object({
        name  = string
        value = string
        type  = optional(string, "PLAINTEXT")
        })),
        []
      )
    }))
    create_role = optional(bool, false)
    role_data = optional(object({
      name                                = string
      github_secret_arn                   = optional(string, null)
      additional_iam_policy_doc_json_list = optional(list(any), [])
      }),
    null)

    trigger = optional(list(object({
      source_action_name = string

      push = list(object({
        branches = object({
          includes = list(string)
          excludes = list(string)
        })
        file_paths = object({
          includes = list(string)
          excludes = list(string)
        })
        })
      )

      pull_request = list(object({
        events = list(string)
        filter = list(object({
          branches = object({
            includes = list(string)
            excludes = list(string)
          })
          file_paths = object({
            includes = list(string)
            excludes = list(string)
          })
          })
      ) }))

    })), [])

    notification_data = optional(map(object({
      detail_type = optional(string, "FULL")
      event_type_ids = optional(list(string), [
        "codepipeline-pipeline-pipeline-execution-failed",
        "codepipeline-pipeline-pipeline-execution-canceled",
        "codepipeline-pipeline-pipeline-execution-started",
        "codepipeline-pipeline-pipeline-execution-resumed",
        "codepipeline-pipeline-pipeline-execution-succeeded",
        "codepipeline-pipeline-pipeline-execution-superseded",
        "codepipeline-pipeline-manual-approval-failed",
        "codepipeline-pipeline-manual-approval-needed"
      ])
      targets = list(object({
        address = string                  // eg SNS arn
        type    = optional(string, "SNS") // Type can be "SNS" , AWSChatbotSlack etc
      }))
    })), null)

  }))

  description = "Codepipeline data to create pipeline and stages"
  default     = {}
}

variable "role_data" {
  type = map(object({
    pipeline_service                    = string
    assume_role_arns                    = optional(list(string), null)
    github_secret_arn                   = optional(string, null)
    terraform_state_s3_bucket           = optional(string, null)
    dynamodb_lock_table                 = optional(string, null)
    additional_iam_policy_doc_json_list = optional(list(any), [])
  }))
  description = "Roles to be created"
  default     = {}
}


variable "chatbot_data" {
  type = object({
    name                     = string
    slack_channel_id         = string
    slack_workspace_id       = string
    guardrail_policies       = optional(list(string), ["arn:aws:iam::aws:policy/AWSAccountManagementReadOnlyAccess"])
    enable_slack_integration = bool
    role_polices = optional(list(object({
      policy_document = any
      policy_name     = string

    })), [])
    managed_policy_arns = optional(list(string), ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"])
  })
  description = "(optional) Chatbot details to create integration"
  default     = null
}
