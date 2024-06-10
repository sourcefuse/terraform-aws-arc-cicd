data "aws_s3_bucket" "artifact" {
  bucket = var.artifacts_bucket
}
