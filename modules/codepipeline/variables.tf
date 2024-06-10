variable "name" {
  type        = string
  description = "Name of the pipeline"
}

variable "codestar_connection" {
  type        = string
  description = "codestar connection arn for github repository"
}

variable "artifacts_bucket" {
  type        = string
  description = "s3 bucket used for codepipeline artifacts"
}

variable "artifact_store_s3_kms_arn" {
  type        = string
  description = "KMS arn used to encrypy S3 objects"
}

variable "source_repositories" {
  type = list(object({
    name              = string
    output_artifacts  = optional(list(string), ["source_output"])
    github_repository = string
    github_branch     = string
    auto_trigger      = optional(bool, true)
  }))
  description = "List of Repositories to be cloned"
}

variable "pipeline_stages" {
  type = list(object({
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
  description = <<-EOT
  	List of pipeline stages.
	eg.  environment_variables = [
		{
			name  = "WORKING_DIR",
      		value = "terraform/bootstrap",
      		type  = "PLAINTEXT"
		}
	]
  EOT
}

variable "create_role" {
  type        = bool
  description = "Whether to create IAM role"
  default     = false
}

variable "role_data" {
  type = object({
    name                                = string
    github_secret_arn                   = optional(string, null)
    additional_iam_policy_doc_json_list = optional(list(any), [])
  })
  description = "Data required for creating IAM role"
  default     = null
}


variable "tags" {
  type        = map(string)
  description = "tags for Codepipelein"
  default     = {}
}

// Check the Formate here --> https://github.com/hashicorp/terraform-provider-aws/issues/35475#issuecomment-1961565715
variable "trigger" {
  type = list(object({
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

  }))
  default     = []
  description = "A trigger block. Valid only when pipeline_type is V2"
}

variable "notification_data" {
  type = map(object({
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
  }))
  description = ""
  default     = null
}
