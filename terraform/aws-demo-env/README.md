# Demo Environment
Terraform project for deploying an AWS environment for us during demos where we just needs something quick and dirty. This project deploys the following resources:

 - VPC
  - 3 public subnets, across 3 AZs
  - 3 private subnets, across 3 AZs
  - Internet Gateway for public subnets
  - NAT Gateway for private subnets
- VPN Client into private subnets
- EKS Cluster

## Deploying the environment
### Prerequisites for deployment
Before you can deploy the demo environment using terraform, you will need to create bootstrap some remote terraform state storage and setup an account that Terraform can use to authenticate to the AWS account. To bootstrap the remote state storage follow the instructions in the [Bootstrap project](../bootstrap)

Make sure to update the backend configuration in [main.tf](main.tf) to match the s3 bucket name and dynamo DB lock tables names

### Configure Authentication
Configure your AWS authentication via environment variables. These are the variables that needs to be set:
```
export AWS_ACCESS_KEY=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION="us-east-1"
```

### Execute Terraform
With your remote state and authentication setup you are ready to run Terraform to deploy the infrastructure. Run the following commands, review the plan and type 'yes' to execute.
```
terraform init
terraform apply
```

## VPN Access
To access the VPN that is setup by this project, you will need your favorite OpenVPN client installed. If you don't have a favorite, you can use [Tunnelblick](https://tunnelblick.net/downloads.html). Once you have installed your VPN client, you can run the following command to create your VPN configuration file.
```
terraform output --raw vpn_client_full_configuration > demo-vpn.ovpn
```
Import this configuration file into your VPN client and you are ready to connect to the VPN.

## Granting AWS Console Access

## Accessing Kubernetes Dashboard
