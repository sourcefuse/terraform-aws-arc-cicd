locals {

  environment_role = {
    dev = "arn:aws:iam::xxxx:role/example-dev-cicd-role"
  }

  branch_map = {
    dev = {
      terraform = "dev"
    }
    poc = {
      terraform = "stg"
    }
  }

  prefix              = "${var.namespace}-${var.environment}"
  codestar_connection = "Github-Connection"
  artifacts_bucket    = "${local.prefix}-pipeline-artifacts"

  policies = [{
    policy_document = data.aws_iam_policy_document.pipeline.json
    policy_name     = "pipeline-policy-to-reject"
  }]

  chatbot_data = {
    name                     = "${var.namespace}-slack"
    slack_channel_id         = "C0xxxxxxx5"
    slack_workspace_id       = "T0xxxxxxRT"
    managed_policy_arns      = ["arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"]
    guardrail_policies       = ["arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"]
    role_polices             = local.policies
    enable_slack_integration = true
  }

  notification_event_and_type = {
    event_type_ids = [
      "codepipeline-pipeline-pipeline-execution-failed",
      "codepipeline-pipeline-pipeline-execution-canceled",
      "codepipeline-pipeline-pipeline-execution-started",
      "codepipeline-pipeline-pipeline-execution-resumed",
      "codepipeline-pipeline-pipeline-execution-succeeded",
      "codepipeline-pipeline-pipeline-execution-superseded",
      "codepipeline-pipeline-manual-approval-failed",
      "codepipeline-pipeline-manual-approval-needed"
    ]
    targets = [{
      address = "arn:aws:chatbot::${data.aws_caller_identity.current.account_id}:chat-configuration/slack-channel/${var.namespace}-slack" // it should match chatbot_data.name
      type    = "AWSChatbotSlack"                                                                                                         // Type can be "SNS" , AWSChatbotSlack etc
    }]
  }

  // IAM roles has to be created before creating Codebuild project and Codepipeline
  role_data = {
    "${local.prefix}-codepipeline-role" = {
      pipeline_service                    = "codepipeline"
      assume_role_arns                    = []
      github_secret_arn                   = null
      terraform_state_s3_bucket           = null
      dynamodb_lock_table                 = null
      additional_iam_policy_doc_json_list = []
    },
    "${local.prefix}-codebuild-terraform" = {
      pipeline_service                    = "codebuild"
      assume_role_arns                    = [local.environment_role[var.environment], "arn:aws:iam::1111xxxx1111:role/example-management-mrr-role"]
      github_secret_arn                   = null
      terraform_state_s3_bucket           = "example-shared-services-terraform-state"
      dynamodb_lock_table                 = "example-shared-services-terraform-state-lock"
      additional_iam_policy_doc_json_list = []
    }
  }

  // Codebuild projects have to be created before creating Codepipelines
  codebuild_projects = {
    "${local.prefix}-terraform-plan" = {
      description       = "Codebuild project for Terraform Plan"
      build_type        = "Terraform"
      terraform_version = "terraform-1.8.3-1.x86_64"
      buildspec_file    = null
      role_data = {
        name = "${local.prefix}-codebuild-terraform"
      }
      artifacts_bucket    = local.artifacts_bucket
      buildspec_file_name = "buildspec-tf-apply"
    },
    "${local.prefix}-terraform-apply" = {
      description       = "Codebuild project for Terraform Apply"
      build_type        = "Terraform"
      terraform_version = "terraform-1.8.3-1.x86_64"
      buildspec_file    = null
      role_data = {
        name = "${local.prefix}-codebuild-terraform"
      }
      artifacts_bucket    = local.artifacts_bucket
      buildspec_file_name = "buildspec-tf-apply"
    }
  }


  codepipeline_data = {
    "${local.prefix}-terrafomr-module" = {
      codestar_connection       = local.codestar_connection
      artifacts_bucket          = local.artifacts_bucket
      artifact_store_s3_kms_arn = null
      auto_trigger              = false

      source_repositories = [
        {
          name              = "TF-Source"
          output_artifacts  = ["tf_source_output"]
          github_repository = "githuborg/tf-mono-infra"
          github_branch     = local.branch_map[var.environment].terraform
          auto_trigger      = false
        }
      ]


      pipeline_stages = [
        {
          stage_name       = "Terraform-Plan"
          name             = "Terraform-Plan"
          input_artifacts  = ["tf_source_output"]
          output_artifacts = ["tf_plan_output"]
          version          = "1"
          project_name     = "${local.prefix}-terraform-plan" # This has to match the Codebuild project name
          environment_variables = [
            {
              name  = "ENVIRONMENT",
              value = var.environment
            },
            {
              name  = "TF_VAR_FILE",
              value = "tfvars/${var.environment}.tfvars"
            },
            {
              name  = "WORKING_DIR",
              value = "terraform/example-module"
            },
            {
              name  = "BACKEND_CONFIG_FILE",
              value = "backend/config.shared-services.hcl"
            },
            {
              name  = "WORKSPACE",
              value = var.environment
            }
          ]
        },
        {
          stage_name = "Approval"
          name       = "Approval"
          category   = "Approval"
          provider   = "Manual"
          version    = "1"
        },
        {
          stage_name       = "Terraform-Apply"
          name             = "Terraform-Apply"
          input_artifacts  = ["tf_plan_output"]
          output_artifacts = ["tf_apply_output"]
          version          = "1"
          project_name     = "${local.prefix}-terraform-apply" # This has to match the Codebuild project name
          environment_variables = [
            {
              name  = "ENVIRONMENT",
              value = var.environment
            },
            {
              name  = "TF_VAR_FILE",
              value = "tfvars/${var.environment}.tfvars"
            },
            {
              name  = "WORKING_DIR",
              value = "terraform/example-module"
            },
            {
              name  = "BACKEND_CONFIG_FILE",
              value = "backend/config.shared-services.hcl"
            },
            {
              name  = "WORKSPACE",
              value = var.environment
            }
          ]
        }
      ]
      role_data = {
        name = "${local.prefix}-codepipeline-role"
      }
      notification_data = {
        "${local.prefix}--api-notification" = local.notification_event_and_type // "${local.prefix}--api-notification" name has to be unique for each pipeline
      }
    }
  }

}
