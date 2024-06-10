data "aws_caller_identity" "current" {}

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
