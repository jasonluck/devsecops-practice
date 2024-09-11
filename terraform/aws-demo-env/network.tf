
################################################################################
# VPC Module
# https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/README.md
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs                = local.azs
  public_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  enable_nat_gateway = true
  # Set Single Gateway to true if we don't care to demo AZ loss
  single_nat_gateway = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  tags = local.tags
}

################################################################################
# Client VPN Module
# https://github.com/cloudposse/terraform-aws-ec2-client-vpn/tree/main
################################################################################

module "client_vpn" {
  source  = "cloudposse/ec2-client-vpn/aws"
  version = "1.0.0"
  name    = "demo-vpn"

  #VPC
  vpc_id             = module.vpc.vpc_id
  client_cidr        = local.vpn_client_cidr
  associated_subnets = module.vpc.private_subnets
  organization_name  = local.organization_name

  #Certificates
  ca_common_name            = "vpn.demo.meetveracity.com"
  root_common_name          = "vpn-client.demo.meetveracity.com"
  server_common_name        = "vpn-server.demo.meetveracity.com"
  export_client_certificate = true


  #Logging
  logging_enabled     = true
  retention_in_days   = 1
  logging_stream_name = "demo-vpn"

  #Security
  authorization_rules = [
    {
      authorize_all_groups = true
      target_network_cidr  = module.vpc.vpc_cidr_block
      description          = "Allow traffic to VPC"
    }
  ]

  #Routing
  # Only route traffic AWS private resource traffic through VPN
  split_tunnel = true
  # Only need these additional routes if not using a Split tunnel
  # additional_routes = [
  #   {
  #     destination_cidr_block = "0.0.0.0/0"
  #     description            = "Internet Route"
  #     target_vpc_subnet_id   = element(module.vpc.private_subnets, 0)
  #   }
  # ]

  tags = local.tags
}
