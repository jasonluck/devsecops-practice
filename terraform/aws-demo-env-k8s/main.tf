###############################################################################
# Demo Environment Configuration
###############################################################################
locals {
  # VPC
  vpc_id = data.terraform_remote_state.demo.outputs.vpc_id

  #EKS Cluster info
  cluster_name            = data.terraform_remote_state.demo.outputs.eks_cluster_name
  cluster_endpoint        = data.terraform_remote_state.demo.outputs.eks_cluster_endpoint
  cluster_certifiate_data = data.terraform_remote_state.demo.outputs.eks_cluster_certificate_authority_data
  cluster_oidc_arn        = data.terraform_remote_state.demo.outputs.eks_oidc_provider_arn

  #Applications
  deploy_kubernetes_dashboard = true

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

data "terraform_remote_state" "demo" {
  backend = "s3"
  config = {
    region = "us-east-1"

    bucket         = "daimo-demo-tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "daimo-terraform-locking"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_certifiate_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(local.cluster_certifiate_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

terraform {
  backend "s3" {
    region = "us-east-1"

    bucket         = "daimo-demo-tf-state"
    key            = "terraform-k8s.tfstate"
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
