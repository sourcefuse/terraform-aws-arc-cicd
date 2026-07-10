# Conditionally fetch S3 bucket data only if artifacts_bucket is provided
data "aws_s3_bucket" "artifact" {
  count  = var.artifacts_bucket != null && var.artifacts_bucket != "" ? 1 : 0
  bucket = var.artifacts_bucket
}
