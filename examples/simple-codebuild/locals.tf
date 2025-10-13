locals {
  prefix = "${var.namespace}-${var.environment}"

  // Simple IAM role for standalone CodeBuild project
  role_data = {
    "${local.prefix}-simple-codebuild-role" = {
      pipeline_service                    = "codebuild"
      assume_role_arns                    = []
      github_secret_arn                   = null
      terraform_state_s3_bucket           = null
      dynamodb_lock_table                 = null
      additional_iam_policy_doc_json_list = []
    }
  }

  // Simple standalone CodeBuild project with NO_SOURCE
  codebuild_projects = {
    "${local.prefix}-simple-build" = {
      description    = "Simple CodeBuild project with NO_SOURCE for manual builds"
      build_type     = "UI"
      buildspec_file = <<-BUILDSPEC
        version: 0.2

        env:
          variables:
            MESSAGE: "Hello from CodeBuild"

        phases:
          pre_build:
            commands:
              - echo "Pre-build phase started"
              - echo "Environment: $MESSAGE"
          build:
            commands:
              - echo "Build phase started"
              - echo "Running custom build commands..."
              - date
          post_build:
            commands:
              - echo "Post-build phase completed"
              - echo "Build finished successfully!"

        artifacts:
          files:
            - '**/*'
      BUILDSPEC
      role_data = {
        name = "${local.prefix}-simple-codebuild-role"
      }
      source_type        = "NO_SOURCE" # No source code required
      source_location    = null
      artifacts_type     = "NO_ARTIFACTS" # No artifacts output
      artifacts_location = null
      artifacts_bucket   = null # Not needed for NO_SOURCE
      privileged_mode    = false
    }
  }
}
