################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0, < 7.0"
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


module "simple_codebuild" {
  source = "../../"

  artifacts_bucket    = null # Not required for NO_SOURCE builds
  codestar_connection = null # Not using CodeStar connection

  role_data          = local.role_data
  codebuild_projects = local.codebuild_projects
  codepipelines      = {}   # Not creating any pipelines
  chatbot_data       = null # Not using Slack integration

  tags = module.tags.tags
}
