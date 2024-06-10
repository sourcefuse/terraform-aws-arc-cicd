data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "parameters" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.namespace}/${var.environment}/*"]
  }
}

data "aws_iam_policy_document" "secret_read" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.namespace}/${var.environment}/*"
    ]
  }
}


data "aws_iam_policy_document" "ecr_push" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution",
      "codepipeline:StopPipelineExecution"
    ]

    resources = [
      "*"
    ]
  }
}
