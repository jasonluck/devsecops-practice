
# Demo Environment - Kubernetes Configuration
Terraform project for configuring the EKS cluster associated with the [Demo Environment](../aws-demo-env) project. This project deploys the following Kubernetes resources:

- AWS ALB Controller
- Kubernetes Dashboard
- ALB ingress resource for Kubernetes Dashboard
- Service Account for access Kubernetes Dashboard

## Deploying the environment
### Prerequisites for deployment
Before you can deploy the demo environment using terraform, you will need to create bootstrap some remote terraform state storage and setup an account that Terraform can use to authenticate to the AWS account. To bootstrap the remote state storage follow the instructions in the [Bootstrap project](../bootstrap)

Make sure to update the backend configuration in [main.tf](main.tf) to match the s3 bucket name and dynamo DB lock tables names

You will also need to have run the [Demo Environment](../aws-demo-env) project. to setup the EKS cluster.

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

## Next Steps
At this point you should have a fully functional EKS environment with Dashboard access for ease of use. Next steps would be to deploy your application pods into the cluster and configure ingress resources to configure the ALB to route traffic to those pods.
