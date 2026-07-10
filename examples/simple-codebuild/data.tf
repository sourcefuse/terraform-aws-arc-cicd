# This simple example only needs basic AWS account info
# The CodeBuild project with NO_SOURCE doesn't require additional IAM policies

# Fetch default VPC
data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["arc-poc-vpc"]
  }
}

# Fetch subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch default security group
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}
