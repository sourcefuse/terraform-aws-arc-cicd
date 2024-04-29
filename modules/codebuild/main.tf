module "role" {
  source = "../iam-role"
  count  = var.create_role ? 1 : 0

  name                                = var.role_data.name
  pipeline_service                    = try(var.role_data.pipeline_service, [])
  assume_role_arns                    = var.role_data.assume_role_arns
  artifact_bucket_arn                 = data.aws_s3_bucket.artifact.arn
  codestar_connection                 = var.role_data.codestar_connection
  github_secret_arn                   = var.role_data.github_secret_arn
  terraform_state_s3_bucket           = var.role_data.terraform_state_s3_bucket
  dynamodb_lock_table                 = var.role_data.dynamodb_lock_table
  additional_iam_policy_doc_json_list = var.role_data.additional_iam_policy_doc_json_list

  tags = var.tags
}

resource "aws_codebuild_project" "this" {
  name           = var.project_name
  description    = var.description
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout

  service_role = local.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = var.compute_type
    # Below chnages is to fix : YAML_FILE_ERROR: Unknown runtime version named '12' of nodejs. This build image has the following versions: 18
    # Refer :  https://repost.aws/questions/QUZKk9J4Q_QVKX2jU_MK6Jug/yaml-file-error-message-unknown-runtime-version-named-12-of-nodejs
    image                       = var.buildspec_file_name == "buildspec_ui" ? "aws/codebuild/standard:4.0" : var.compute_image
    type                        = var.compute_type_container
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode
  }

  source {
    type = "CODEPIPELINE"
    buildspec = var.build_type == "Terraform" ? templatefile("${path.module}/buildspec/${var.buildspec_file_name}.yaml", {
      TERRAFORM_VERSION = var.terraform_version
    }) : var.buildspec_file
  }

  tags = var.tags
}
