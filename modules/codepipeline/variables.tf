variable "name" {
  type        = string
  description = "Name of the pipeline"
}

variable "github_repository" {
  type        = string
  description = "Github repository used for source"
}

variable "github_branch" {
  type        = string
  description = "Github repo Branch used for source"
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

variable "auto_trigger" {
  type        = bool
  default     = true
  description = "Whether to start the pipeline after source change"
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

variable "event_type_ids" {
  type        = list(string)
  description = "A list of event types associated with this notification rule."
  default = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-superseded",
    "codedeploy-application-deployment-failed",
    "codedeploy-application-deployment-succeeded",
    "codedeploy-application-deployment-started",
    "codepipeline-pipeline-manual-approval-failed",
    "codepipeline-pipeline-manual-approval-needed"
  ]
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
      "codedeploy-application-deployment-failed",
      "codedeploy-application-deployment-succeeded",
      "codedeploy-application-deployment-started",
      "codepipeline-pipeline-manual-approval-failed",
      "codepipeline-pipeline-manual-approval-needed"
    ])
    target = object({
      address = string                  // eg SNS arn
      type    = optional(string, "SNS") // Type can be "SNS" , AWSChatbotSlack etc
    })
  }))
  description = ""
  default     = null
}
