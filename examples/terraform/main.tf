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

  // backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project
}


module "pipelines" {
  source = "../../"

  artifacts_bucket    = local.artifacts_bucket
  codestar_connection = local.codestar_connection

  role_data          = local.role_data
  codebuild_projects = local.codebuild_projects
  codepipelines      = local.codepipeline_data
  chatbot_data       = local.chatbot_data

  tags = module.tags.tags
}
