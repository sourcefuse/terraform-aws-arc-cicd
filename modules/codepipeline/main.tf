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

  // Idea derived from https://stackoverflow.com/questions/69235896/terraform-aws-codepipeline-multiple-codecommit-sources
  stage {
    name = "Source"

    dynamic "action" {
      for_each = var.source_repositories
      content {
        name             = action.value.name
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = action.value.output_artifacts
        configuration = {
          ConnectionArn    = data.aws_codestarconnections_connection.this.arn
          FullRepositoryId = action.value.github_repository
          BranchName       = action.value.github_branch
          DetectChanges    = action.value.auto_trigger
        }
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

  // refer :  https://github.com/hashicorp/terraform-provider-aws/issues/35475#issuecomment-1961565715
  trigger {

    provider_type = "CodeStarSourceConnection"

    dynamic "git_configuration" {
      for_each = var.trigger
      content {

        source_action_name = git_configuration.source_action_name

        dynamic "push" {
          for_each = var.git_configuration.push
          content {

            branches {
              includes = push.value.branches.includes
              excludes = push.value.branches.incluexcludesdes
            }
            file_paths {
              includes = push.value.file_paths.includes
              excludes = push.value.file_paths.incluexcludesdes
            }

          }
        }

        pull_request {
          events = git_configuration.pull_request.events
          dynamic "push" {
            for_each = var.pull_request.push
            content {

              branches {
                includes = push.value.branches.includes
                excludes = push.value.branches.incluexcludesdes
              }
              file_paths {
                includes = push.value.file_paths.includes
                excludes = push.value.file_paths.incluexcludesdes
              }

            }
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_codestarnotifications_notification_rule" "this" {
  for_each = var.notification_data == null ? {} : var.notification_data

  name           = each.key
  detail_type    = each.value.detail_type
  event_type_ids = each.value.event_type_ids

  resource = aws_codepipeline.codepipeline.arn

  target {
    address = each.value.address
    type    = each.value.type
  }

  tags = var.tags
}
