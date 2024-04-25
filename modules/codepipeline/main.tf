module "role" {
  source = "../iam-role"
  count  = var.create_role ? 1 : 0

  name                                = var.role_data.name
  pipeline_service                    = "codepipeline"
  artifact_bucket_arn                 = data.aws_s3_bucket.artifact.arn
  codestar_connection                 = var.codestar_connection
  github_secret_arn                   = var.role_data.github_secret_arn
  additional_iam_policy_doc_json_list = var.role_data.additional_iam_policy_doc_json_list

  tags = var.tags
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.name
  role_arn = local.role_arn

  artifact_store {
    location = var.artifacts_bucket
    type     = "S3"

    dynamic "encryption_key" {
      for_each = var.artifact_store_s3_kms_arn == null ? [] : [1]

      content {
        id   = var.artifact_store_s3_kms_arn
        type = "KMS"
      }
    }
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.this.arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
        DetectChanges    = var.auto_trigger
      }
    }
  }


  dynamic "stage" {
    for_each = var.pipeline_stages

    content {
      name = stage.value.name
      action {
        name             = stage.value.name
        category         = stage.value.category
        owner            = "AWS"
        provider         = stage.value.provider
        version          = stage.value.version
        output_artifacts = stage.value.output_artifacts
        input_artifacts  = stage.value.input_artifacts
        configuration = {
          ProjectName          = stage.value.project_name
          EnvironmentVariables = stage.value.category == "Approval" ? null : jsonencode(stage.value.environment_variables)
        }
      }
    }
  }
  tags = var.tags
}
