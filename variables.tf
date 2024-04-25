## shared
################################################################################
variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}

variable "environment" {
  type        = string
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Tags for AWS resources"
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
    artifacts_bucket            = string
    build_type                  = string
    buildspec_file_name         = optional(string, null)
    buildspec_file              = optional(string, null)
    terraform_version           = optional(string, null)
    create_role                 = optional(bool, false)
    role_data = object({
      name                                = string
      pipeline_service                    = optional(string, null)
      assume_role_arns                    = optional(list(string), null)
      codestar_connection                 = optional(string, null)
      github_secret_arn                   = optional(string, null)
      terraform_state_s3_bucket           = optional(string, null)
      dynamodb_lock_table                 = optional(string, null)
      additional_iam_policy_doc_json_list = optional(list(any), [])
    })
  }))
  description = "Values to create Codebuild project"
  default     = null // null  doesn't create codebuild project
}

variable "codepipeline_data" {
  type = object({
    name                      = string
    github_repository         = string
    github_branch             = string
    codestar_connection       = string
    artifacts_bucket          = string
    artifact_store_s3_kms_arn = string
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
        type  = string
        })),
        []
      )
    }))
    auto_trigger = optional(bool, true)
    create_role  = optional(bool, false)
    role_data = object({
      name                                = string
      codestar_connection                 = optional(string, null)
      github_secret_arn                   = optional(string, null)
      additional_iam_policy_doc_json_list = optional(list(any), [])
    })
  })
  description = "Codepipeline data to create pipeline and stages"
}
