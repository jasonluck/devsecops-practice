# Terraform State Bootstrapping

This project is used to bootstrap the resources necessary for storing Terraform
remote state in an S3 bucket with DynamoDB state locking.

## Authenticating to AWS

## Executing this project
Execute terraform in this directory providing the variable values for the
bucket name if necessary.
```bash
terraform init
terraform apply -var 's3_bucket_name=MyCustomBucketName' -var 'dynamo_table_name=my-table-name'
```

## Using these resources for remote state
After creating these resources, you will need to add a remote state
configuration to your Terraform project in order to make use of them. Add the
following code block to your `main.tf` file.

Make sure to update the attribute values to match your region, profile,
bucket values. Make sure the key is unique to your project if you are storing
multiple state files in the same bucket.
```hcl
terraform {
  backend "s3" {
    region         = "us-east-1"
    profile        = "admin-acct-profile"

    bucket         = "tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-locking"
  }
}
```
