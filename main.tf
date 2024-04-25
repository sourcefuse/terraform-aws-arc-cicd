module "role" {
  source   = "./modules/iam-role"
  for_each = var.role_data

  name                                = each.key
  pipeline_service                    = each.value.pipeline_service
  assume_role_arns                    = each.value.assume_role_arns
  artifact_bucket_arn                 = data.aws_s3_bucket.artifact.arn
  codestar_connection                 = var.codestar_connection
  github_secret_arn                   = each.value.github_secret_arn
  terraform_state_s3_bucket           = each.value.terraform_state_s3_bucket
  dynamodb_lock_table                 = each.value.dynamodb_lock_table
  additional_iam_policy_doc_json_list = each.value.additional_iam_policy_doc_json_list

  tags = var.tags
}

################################################################################
## Codebuild Project
################################################################################
module "codebuild" {
  source   = "./modules/codebuild"
  for_each = var.codebuild_projects

  project_name                = each.key
  description                 = each.value.description
  build_timeout               = each.value.build_timeout
  queued_timeout              = each.value.queued_timeout
  artifacts_bucket            = var.artifacts_bucket
  compute_type                = each.value.compute_type
  compute_image               = each.value.compute_image
  compute_type_container      = each.value.compute_type_container
  privileged_mode             = each.value.privileged_mode
  image_pull_credentials_type = each.value.image_pull_credentials_type
  build_type                  = each.value.build_type
  buildspec_file_name         = each.value.buildspec_file_name
  buildspec_file              = each.value.buildspec_file
  terraform_version           = each.value.terraform_version
  create_role                 = each.value.create_role
  role_data = merge(
    each.value.role_data,
    {
      codestar_connection = var.codestar_connection
    }

  )

  tags = var.tags

  depends_on = [module.role]
}

################################################################################
## Codepipeline Project
################################################################################

module "codepipeline" {
  source   = "./modules/codepipeline"
  for_each = var.codepipelines

  name                      = each.key
  github_repository         = each.value.github_repository
  github_branch             = each.value.github_branch
  codestar_connection       = var.codestar_connection
  artifacts_bucket          = var.artifacts_bucket
  artifact_store_s3_kms_arn = each.value.artifact_store_s3_kms_arn
  pipeline_stages           = each.value.pipeline_stages
  auto_trigger              = each.value.auto_trigger
  create_role               = each.value.create_role
  role_data = merge(
    each.value.role_data,
    {
      codestar_connection = var.codestar_connection
    }

  )

  tags = var.tags

  depends_on = [module.codebuild, module.role]
}
