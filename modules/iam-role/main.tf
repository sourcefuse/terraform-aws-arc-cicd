data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [data.aws_codestarconnections_connection.this.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]

  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"]
  }

  dynamic "statement" {
    for_each = length(var.assume_role_arns) > 0 ? [1] : []
    content {

      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = var.assume_role_arns
    }
  }

}

resource "aws_iam_role" "this" {
  name = var.name
  path = local.role_path
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "${var.pipeline_service}.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = var.pipeline_service == "codebuild" ? data.aws_iam_policy_document.codebuild.json : data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "github_secret" {
  count = var.github_secret_arn == null ? 0 : 1

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [var.github_secret_arn]

  }
}

resource "aws_iam_role_policy" "github_secret" {
  count  = var.github_secret_arn == null ? 0 : 1
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.github_secret[0].json
}

data "aws_iam_policy_document" "terraform_state" {
  count = var.terraform_state_s3_bucket == null ? 0 : 1

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = ["arn:aws:s3:::${var.terraform_state_s3_bucket}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::${var.terraform_state_s3_bucket}/*"]
  }
}

resource "aws_iam_role_policy" "terraform_state" {
  count  = var.terraform_state_s3_bucket == null ? 0 : 1
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.terraform_state[0].json
}

data "aws_iam_policy_document" "dynamodb_lock" {
  count = var.dynamodb_lock_table == null ? 0 : 1

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/${var.dynamodb_lock_table}"]
  }
}

resource "aws_iam_role_policy" "dynamodb_lock" {
  count  = var.dynamodb_lock_table == null ? 0 : 1
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.dynamodb_lock[0].json
}

resource "aws_iam_role_policy" "additional_policies" {
  count  = length(var.additional_iam_policy_doc_json_list)
  role   = aws_iam_role.this.name
  policy = var.additional_iam_policy_doc_json_list[count.index]
}
