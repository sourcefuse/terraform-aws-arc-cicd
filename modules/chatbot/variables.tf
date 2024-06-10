variable "name" {
  type        = string
  description = "Chatbot name"
}

variable "slack_channel_id" {
  type        = string
  description = "Slack Channel ID"
}

variable "slack_workspace_id" {
  type        = string
  description = "Slack Workspace ID"
}


variable "guardrail_policies" {
  type        = list(string)
  description = "List of Guardrail Policies"
  default     = ["arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSCodePipelineApproverAccess"]
}

variable "tags" {
  type        = map(string)
  description = "Tags for AWS resources"
  default     = {}
}

variable "enable_slack_integration" {
  type        = bool
  description = "Whether to enable chatbot for Slack"
  default     = false
}

variable "role_polices" {
  type = list(object({
    policy_document = any
    policy_name     = string
  }))
  description = <<-EOT
  IAM polices for the role eg.

   policies = [{
    policy_document = data.aws_iam_policy_document.sample_inline_1.json
    policy_name     = "first_inline_policy"
    },
    {
      policy_document = data.aws_iam_policy_document.sample_inline_2.json
      policy_name     = "second_inline_policy"
  }]

  Note:- Guardrail polcies act as upper limit for the policies
  EOT
  default     = []
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "(optional) A list of Amazon Resource Names (ARNs) of the IAM managed policies that you want to attach to the role."
  default     = ["arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSCodePipelineApproverAccess"]
}
