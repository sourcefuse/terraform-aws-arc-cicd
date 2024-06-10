################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.76.0"
    }
  }
}

/*
Added below provider "awscc" block to fix following error
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid provider configuration
│
│ Provider "registry.terraform.io/hashicorp/awscc" requires explicit configuration. Add a provider block to the root module and configure the provider's required arguments as described in the provider
│ documentation.
│
╵
╷
│ Error: validating provider credentials: retrieving caller identity from STS: operation error STS: GetCallerIdentity, failed to resolve service endpoint, endpoint rule error, Invalid Configuration: Missing Region
│
│   with provider["registry.terraform.io/hashicorp/awscc"],
│   on <empty> line 0:
│   (source code not available)

provider "awscc" {
  region = var.region
}
*/
