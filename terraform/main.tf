# export shell environments with credenials
provider "aws" {
  region = var.region
  profile = var.aws_profile
}

# get account id
data "aws_caller_identity" "current" {
}
