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
  artifacts_bucket            = each.value.artifacts_bucket
  compute_type                = each.value.compute_type
  compute_image               = each.value.compute_image
  compute_type_container      = each.value.compute_type_container
  image_pull_credentials_type = each.value.image_pull_credentials_type
  build_type                  = each.value.build_type
  buildspec_file_name         = each.value.buildspec_file_name
  buildspec_file              = each.value.buildspec_file
  terraform_version           = each.value.terraform_version
  create_role                 = each.value.create_role
  role_data                   = each.value.role_data

  tags = var.tags
}

################################################################################
## Codepipeline Project
################################################################################

module "codepipeline" {
  source = "./modules/codepipeline"

  name                      = var.codepipeline_data.name
  github_repository         = var.codepipeline_data.github_repository
  github_branch             = var.codepipeline_data.github_branch
  codestar_connection       = var.codepipeline_data.codestar_connection
  artifacts_bucket          = var.codepipeline_data.artifacts_bucket
  artifact_store_s3_kms_arn = var.codepipeline_data.artifact_store_s3_kms_arn
  pipeline_stages           = var.codepipeline_data.pipeline_stages
  auto_trigger              = var.codepipeline_data.auto_trigger
  create_role               = var.codepipeline_data.create_role
  role_data                 = var.codepipeline_data.role_data

  tags = var.tags

  depends_on = [module.codebuild]
}
