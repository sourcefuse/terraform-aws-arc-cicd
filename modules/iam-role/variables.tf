variable "name" {
  type        = string
  description = "IAM role name"
}

variable "pipeline_service" {
  type        = string
  description = "AWS Codepipeline service , valid values : codepipeline, codebuild"
}

variable "assume_role_arns" {
  type        = list(string)
  description = "Assume roles for codebuild"
  default     = []
}

variable "artifact_bucket_arn" {
  type        = string
  description = "s3 buckets access for code pipeline and codebuild"
}

variable "codestar_connection" {
  type        = string
  description = "Code star connection arn"
  default     = ""
}

variable "github_secret_arn" {
  type        = string
  description = "AWS secret having Github Token"
  default     = null
}

variable "terraform_state_s3_bucket" {
  type        = string
  description = "S3 bucket where Terraform state is stored"
  default     = null
}

variable "dynamodb_lock_table" {
  type        = string
  description = "DynamoDb table for state lock"
  default     = null
}

variable "additional_iam_policy_doc_json_list" {
  type        = list(any)
  description = "List of IAM Policy documents"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags for IAM role"
  default     = {}
}
