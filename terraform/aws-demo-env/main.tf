###############################################################################
# Demo Environment Configuration
###############################################################################
locals {
  name              = "demo"
  organization_name = "Veracity"

  vpn_client_cidr = "10.1.0.0/16"
  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)

  #EKS
  eks_cluster_name     = "demo"
  node_group_name      = "demo"
  cluster_min_size     = 0
  cluster_max_size     = 3
  cluster_desired_size = 3

  tags = {
  }
}

/*
 * The `aws` provider will use the various `AWS_*` environment variables expected
 * by the AWS CLI and SDKs. See;
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs#aws-configuration-reference
 *
 */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Purpose   = "DAIMO demo"
      POC       = "Jason Luck"
      ManagedBy = "Terraform"
    }
  }
}

terraform {
  backend "s3" {
    region = "us-east-1"

    bucket         = "daimo-demo-tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "daimo-terraform-locking"
  }
}

/*
 * Make the region and account ID available for use in resource parameters
 */
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
