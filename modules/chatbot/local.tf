locals {
  environment = try(var.tags.environment, var.tags.Environment, "")
  namespace   = try(var.tags.namespace, "")
  prefix      = local.namespace == "" ? local.environment : "${local.namespace}-${local.environment}"
}
