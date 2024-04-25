################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project

  extra_tags = {
    Repo         = "github.com/sourcefuse/terraform-aws-arc-security"
    MonoRepo     = "True"
    MonoRepoPath = "terraform/security"
  }
}


module "pipeline" {
  source = "../"

  region      = var.region
  environment = var.environment
  namespace   = var.namespace

  codebuild_projects = {
    "react-ui" = {
      description      = "Test Codebuild project"
      build_type       = "UI"
      buildspec_file   = file("${path.module}/buildspec/buildspec.yaml")
      create_role      = true
      artifacts_bucket = "trinet-codebuild-project-artifact"
      role_data = {
        name                                = "test-codebuild-role"
        pipeline_service                    = "codebuild"
        assume_role_arns                    = []
        codestar_connection                 = "Github-Connection"
        github_secret_arn                   = null
        terraform_state_s3_bucket           = null
        dynamodb_lock_table                 = null
        additional_iam_policy_doc_json_list = []
      }
    }
  }

  codepipeline_data = {
    name                      = "${var.environment}-${var.namespace}-app-ui"
    github_repository         = "himanshutmllc/app-ui"
    github_branch             = "main"
    codestar_connection       = "Github-Connection"
    artifacts_bucket          = "trinet-codebuild-project-artifact"
    artifact_store_s3_kms_arn = null
    pipeline_stages = [
      {
        stage_name = "Approval"
        name       = "Approval"
        category   = "Approval"
        provider   = "Manual"
        version    = "1"
      },
      {
        stage_name       = "ui-build"
        name             = "ui-build"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"
        project_name     = "react-ui" # This has to match the Codebuild project name
        environment_variables = [{
          name  = "TEST",
          value = "value",
          type  = "PLAINTEXT"
          }
        ]
      }
    ]
    auto_trigger = false
    create_role  = true
    role_data = {
      name                                = "codepipeline-role"
      github_secret_arn                   = null
      additional_iam_policy_doc_json_list = []
    }
  }

  tags = module.tags.tags
}
