data "aws_iam_role" "this" {
  count = var.create_role ? 0 : 1
  name  = var.role_data.name
}

data "aws_s3_bucket" "artifact" {
  bucket = var.artifacts_bucket
}
