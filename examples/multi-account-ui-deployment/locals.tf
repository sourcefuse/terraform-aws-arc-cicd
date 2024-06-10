locals {

  environment_role = {
    dev = "arn:aws:iam::xxxxx:role/cicd-role"
  }

  branch_map = {
    dev = {
      ui = "dev"
    }
    poc = {
      ui = "staging"
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
    "${local.prefix}-codebuild-role" = {
      pipeline_service                    = "codebuild"
      assume_role_arns                    = [local.environment_role[var.environment]]
      github_secret_arn                   = null
      terraform_state_s3_bucket           = null
      dynamodb_lock_table                 = null
      additional_iam_policy_doc_json_list = []
    }
  }

  // Codebuild projects have to be created before creating Codepipelines
  codebuild_projects = {
    "${local.prefix}-ui" = {
      description    = "Codebuild project for UI"
      build_type     = "UI"
      buildspec_file = file("${path.module}/buildspec/buildspec-ui.yaml")
      create_role    = false
      role_data = {
        name = "${local.prefix}-codebuild-role"
      }
      artifacts_bucket = local.artifacts_bucket
    },

  }


  codepipeline_data = {
    "${local.prefix}-ui" = {
      codestar_connection       = local.codestar_connection
      artifacts_bucket          = local.artifacts_bucket
      artifact_store_s3_kms_arn = null

      source_repositories = [
        {
          name              = "Source"
          output_artifacts  = ["source_output"]
          github_repository = "githuborg/ui"
          github_branch     = local.branch_map[var.environment].ui
          auto_trigger      = false
        }
      ]

      pipeline_stages = [
        {
          stage_name = "Approval"
          name       = "Approval"
          category   = "Approval"
          provider   = "Manual"
          version    = "1"
        },
        {
          stage_name       = " UI-build"
          name             = "UI-Build"
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          version          = "1"
          auto_trigger     = false
          project_name     = "${local.prefix}-ui" # This has to match the Codebuild project name
          environment_variables = [
            {
              name  = "ENVIRONMENT",
              value = var.environment
            },
            {
              name  = "APPLICATION",
              value = "ui"
            },
            {
              name  = "NAMESPACE",
              value = var.namespace
            },
            {
              name  = "ROLE_TO_ASSUME",
              value = local.environment_role[var.environment] // This is the role codebuild project will assume to deploy UI related files
            }
          ]
        }
      ]
      create_role = false
      role_data = {
        name = "${local.prefix}-codepipeline-role"
      }
      notification_data = {
        "${local.prefix}-ui-notification" = local.notification_event_and_type
      }
    }

  }

}
