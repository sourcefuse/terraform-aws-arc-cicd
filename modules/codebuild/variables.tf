variable "project_name" {
  type        = string
  description = "project name used for code build project"
}

variable "description" {
  type        = string
  description = "Description of Code Build Project"
}

variable "build_timeout" {
  type        = string
  description = "Build timeout of Code Build Project"
  default     = "15"
}

variable "queued_timeout" {
  type        = string
  description = "Queued timeout of Code Build Project"
  default     = "15"
}

variable "create_role" {
  type        = bool
  description = "Whether to create IAM role"
  default     = false
}

variable "compute_type" {
  type        = string
  description = "compute type of container used"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "compute_image" {
  type        = string
  description = "compute image for container"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "compute_type_container" {
  type        = string
  description = "compute type for container used"
  default     = "LINUX_CONTAINER"

}

variable "image_pull_credentials_type" {
  type        = string
  description = "image pull credentials from container using"
  default     = "CODEBUILD"
}

variable "build_type" {
  type        = string
  description = "Type of the build, it can be for Terraform, React, Angular etc, Valid values = 'Terraform', 'UI' , 'APP' "
}

variable "buildspec_file_name" {
  type        = string
  description = "File name used for buildspec file"
}

variable "buildspec_file" {
  type        = string
  description = "Buildspec file"
}

variable "terraform_version" {
  type        = string
  description = "terraform version to be installed on container"
  default     = "terraform-1.5.0-1.x86_64"
}

variable "privileged_mode" {
  type        = bool
  description = "Whether to enable running the Docker daemon inside a Docker container. Defaults to false"
  default     = false
}

variable "role_data" {
  type = object({
    name                                = string
    pipeline_service                    = optional(string)
    assume_role_arns                    = optional(list(string))
    codestar_connection                 = optional(string, null)
    github_secret_arn                   = optional(string, null)
    terraform_state_s3_bucket           = optional(string, null)
    dynamodb_lock_table                 = optional(string, null)
    additional_iam_policy_doc_json_list = optional(list(any), [])
  })
  description = "Data required for creating IAM role"
  default     = null
}

variable "artifacts_bucket" {
  type        = string
  description = "s3 bucket used for codepipeline artifacts"
}

variable "tags" {
  type        = map(string)
  description = "Tags for AWS resources"
}
