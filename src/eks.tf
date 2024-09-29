################################################################################
# EKS Resource
################################################################################

resource "aws_eks_cluster" "eks-cluster" {
  name     = local.aws_project_name
  role_arn = local.aws_role

  vpc_config {
    subnet_ids = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != "${local.aws_region}e"]
  }

  access_config {
    authentication_mode = local.aws_access_config
  }
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = local.aws_node_group
  node_role_arn   = local.aws_role
  subnet_ids      = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != "${local.aws_region}e"]
  disk_size       = 50
  instance_types  = local.aws_instance_type

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_eks_access_entry" "eks-access-entry" {
  cluster_name      = aws_eks_cluster.eks-cluster.name
  principal_arn     = local.aws_principal_arn
  kubernetes_groups = [local.aws_node_group]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks-access-policy" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = local.aws_policy_arn
  principal_arn = local.aws_principal_arn

  access_scope {
    type = "cluster"
  }
}

