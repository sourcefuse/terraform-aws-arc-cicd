# We also can have env specific channels
resource "awscc_chatbot_slack_channel_configuration" "this" {
  count = var.enable_slack_integration ? 1 : 0

  configuration_name = var.name
  iam_role_arn       = aws_iam_role.this.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  guardrail_policies = var.guardrail_policies
  sns_topic_arns     = [module.sns_topic.sns_topic_arn]

}

# resource "awscc_iam_role" "this" { --> donot use this to create role, it getting timeout


resource "aws_iam_role" "this" {
  name = "${local.prefix}-chatbot-channel-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = var.managed_policy_arns

  dynamic "inline_policy" {
    for_each = var.role_polices

    content {
      name   = inline_policy.value.policy_name
      policy = inline_policy.value.policy_document
    }

  }

  tags = var.tags
}

data "aws_iam_policy_document" "sns_kms_key_policy" {

  policy_id = "${local.prefix}-ChatbotMessageEncryptUsingKey"

  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${one(data.aws_partition.current[*].partition)}:iam::${one(data.aws_caller_identity.current[*].account_id)}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

module "kms" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  name                = "${local.prefix}-pipeline-sns"
  description         = "KMS key for SNS topic"
  enable_key_rotation = true
  alias               = "alias/${local.prefix}/pipeline-sns"
  policy              = data.aws_iam_policy_document.sns_kms_key_policy.json
  tags                = var.tags

}

module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.21.0"

  attributes                             = ["${local.prefix}-aws-chatbot"]
  kms_master_key_id                      = module.kms.alias_name
  allowed_aws_services_for_sns_published = ["chatbot.amazonaws.com"]
  tags                                   = var.tags
}
