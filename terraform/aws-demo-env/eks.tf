################################################################################Q
# EKS Admin Access
################################################################################
resource "aws_iam_group" "eks_admin" {
  name = "${local.eks_cluster_name}-admins"
}

resource "aws_iam_role" "eks_admin" {
  name = "${local.eks_cluster_name}-administrator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "eks_admin" {
  name        = "${local.eks_cluster_name}-administrator"
  description = "Administrator access to ${local.eks_cluster_name} EKS Cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "${aws_iam_role.eks_admin.arn}"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "eks_admin" {
  group      = aws_iam_group.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

################################################################################
#EKS Cluster
#https://github.com/terraform-aws-modules/terraform-aws-eks
################################################################################
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  vpc_id                               = module.vpc.vpc_id
  cluster_name                         = local.eks_cluster_name
  cluster_version                      = "1.30"
  create_iam_role                      = true
  iam_role_name                        = "eks-${local.eks_cluster_name}"
  iam_role_description                 = "EKS cluster role for ${local.eks_cluster_name}"
  iam_role_tags                        = local.tags
  cluster_enabled_log_types            = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
  create_cluster_security_group        = true
  subnet_ids                           = module.vpc.private_subnets
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_security_group_additional_rules = {
    ingress_443_private_subnets = {
      protocol    = "TCP"
      to_port     = "443"
      from_port   = "443"
      type        = "ingress"
      description = "Allow Cluster API access from private VPC subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  cluster_encryption_config = {
    resources = ["secrets"]
  }

  cluster_addons = {
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
    coredns                = {}
  }

  create_node_security_group               = true
  cluster_encryption_policy_name           = "project-${local.eks_cluster_name}"
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin_group = {
      principal_arn = aws_iam_role.eks_admin.arn
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags
}

################################################################################Q
#EKS Node Group
#https://github.com/terraform-aws-modules/eks/aws/modules/eks-managed-node-group
################################################################################
module "eks-node-group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"


  cluster_name         = module.eks.cluster_name
  create_iam_role      = true
  iam_role_name        = "${module.eks.cluster_name}-node-group"
  iam_role_description = "EKS node group role for ${module.eks.cluster_name}"
  iam_role_additional_policies = {
    "AmazonEC2RoleforSSM"          = data.aws_iam_policy.ec2_ssm.arn
    "AmazonSSMManagedInstanceCore" = data.aws_iam_policy.ssm_managed.arn
    "CloudWatchReadOnlyAccess"     = data.aws_iam_policy.cloudwatch.arn
  }
  subnet_ids                        = module.vpc.private_subnets
  cluster_service_cidr              = module.eks.cluster_service_cidr
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  min_size                          = local.cluster_min_size
  max_size                          = local.cluster_max_size
  desired_size                      = local.cluster_desired_size
  name                              = local.node_group_name
  ami_type                          = "AL2_x86_64"
  key_name                          = aws_key_pair.demo.key_name
  capacity_type                     = "ON_DEMAND"
  instance_types                    = ["t3a.xlarge"]

  tags = local.tags
}

data "aws_iam_policy" "ec2_ssm" {
  name = "AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "ssm_managed" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch" {
  name = "CloudWatchReadOnlyAccess"
}
