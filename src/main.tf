terraform {
  backend "s3" {
    bucket = "tech-challenge-fase-3"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = local.aws_region
}

################################################################################
# EKS Cluster Cloudwatch Group
################################################################################

resource "aws_cloudwatch_log_group" "eks_cluster" {
  count             = 1
  name              = local.aws_eks_name
  retention_in_days = 5

  tags = local.aws_project_tags
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name    = local.aws_eks_name
  cluster_version = local.aws_eks_version

  enable_cluster_creator_admin_permissions = true

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    min_size                   = 1
    max_size                   = 1
    desired_size               = 1
    instance_types             = local.aws_eks_managed_node_groups_instance_types
    use_custom_launch_template = false
    tags                       = local.aws_project_tags
  }

  tags = local.aws_project_tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = local.aws_vpc_name
  cidr = local.aws_vpc_cidr

  azs             = local.aws_vpc_azs
  private_subnets = local.aws_vpc_private_subnets
  public_subnets  = local.aws_vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = merge(local.aws_project_tags, { "kubernetes.io/cluster/${local.aws_eks_name}" = "shared" })

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.aws_eks_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.aws_eks_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

