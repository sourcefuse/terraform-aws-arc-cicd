data "aws_codestarconnections_connection" "this" {
  name = var.codestar_connection
}


locals {
  env       = can(var.tags.Environment) ? "/${var.tags.Environment}" : (can(var.tags.environment) ? "/${var.tags.environment}" : " ")
  role_path = "/cicd${local.env}/${var.pipeline_service}/"
}
