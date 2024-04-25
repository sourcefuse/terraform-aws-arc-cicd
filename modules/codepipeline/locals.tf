locals {
  role_arn = var.create_role ? module.role[0].arn : data.aws_iam_role.this[0].arn

}
