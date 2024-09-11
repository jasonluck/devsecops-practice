/*
 * This Terraform configuration initializes all of the resources necessary to
 * utilize the Terraform S3 backend, see;
 * https://www.terraform.io/language/settings/backends/s3
 *
 * All variables are optional.
 */

variable "aws_region" {
  type        = string
  default     = ""
  description = "AWS region for the backend resources. Will default to the session region."
}

/*
 * It should be noted that if you do not provide a name for the S3 bucket then
 * Terraform will assign a random, unique name. See;
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#bucket
 */
variable "s3_bucket_name" {
  type        = string
  default     = "tf-state"
  description = "Name for the S3 bucket created to store Terraform state."
}

variable "s3_key_prefix" {
  type        = string
  default     = null
  description = "Key prefix for the Terraform state objects in the S3 bucket."
}

variable "dynamo_table_name" {
  type        = string
  default     = "terraform-locking"
  description = "Name for the DynamocDB table created to lock Terraform state."
}

variable "iam_policy_name" {
  type        = string
  default     = "Terraform-S3-Backend"
  description = "Name for the IAM policy enabling access to the backend."
}

/*
 * The `aws` provider will use the various `AWS_*` environment variables expected
 * by the AWS CLI and SDKs. See;
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs#aws-configuration-reference
 *
 * Modify this section as needed.
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
  region = var.aws_region
}

/*
 * Make the region and account ID available for use in resource parameters
 * (such as the managed IAM policy).
 */
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = can(var.s3_bucket_name) ? var.s3_bucket_name : null

  tags = {
    Name        = "Terraform S3 Backend - State"
    application = "Terraform S3 Backend"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = var.dynamo_table_name
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform S3 Backend - Locking"
    application = "Terraform S3 Backend"
  }

  lifecycle {
    prevent_destroy = false
  }
}

/*
 * Attach this policy to an IAM user, group, or role to enable access to the S3
 * backend, see;
 * https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html
 */
resource "aws_iam_policy" "terraform_s3_backend_policy" {
  name        = var.iam_policy_name
  description = "Terraform S3 backend access."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Bucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.terraform_state_bucket.arn
      },
      {
        Sid    = "StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = var.s3_key_prefix != null ? "${aws_s3_bucket.terraform_state_bucket.arn}/${var.s3_key_prefix}/*" : "${aws_s3_bucket.terraform_state_bucket.arn}/*"
      },
      {
        Sid    = "Locking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_lock_table.arn
      }
    ]
  })
}
