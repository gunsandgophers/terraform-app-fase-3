################################################################################
# EKS Resource
################################################################################

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.projectName
  role_arn = var.labRole

  vpc_config {
    subnet_ids = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != "${var.regionDefault}e"]
  }

  access_config {
    authentication_mode = var.accessConfig
  }
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.nodeGroup
  node_role_arn   = var.labRole
  subnet_ids      = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != "${var.regionDefault}e"]
  disk_size       = 50
  instance_types  = [var.instanceType]

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
  principal_arn     = var.principalArn
  kubernetes_groups = ["fiap"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks-access-policy" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = var.policyArn
  principal_arn = var.principalArn

  access_scope {
    type = "cluster"
  }
}

