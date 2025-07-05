terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Reference moduleBigA from Artifactory
module "big_a" {
  source = "artifactory.jfrog.io/devo-terraform__devo_tf_demo_module/moduleBigA/aws"

  environment = var.environment
  name_prefix = var.big_a_name_prefix
}

# Reference moduleBigB from Artifactory
module "big_b" {
  source = "artifactory.jfrog.io/devo-terraform__devo_tf_demo_module/moduleBigB/aws"

  environment = var.environment
  name_prefix = var.big_b_name_prefix
}

# Reference moduleSmallC from Artifactory
module "small_c" {
  source = "artifactory.jfrog.io/devo-terraform__devo_tf_demo_module/moduleSmallC/aws"

  environment = var.environment
  name_prefix = var.small_c_name_prefix
} 