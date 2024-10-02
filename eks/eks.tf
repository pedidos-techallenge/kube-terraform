data "aws_iam_role" LabRole {
  name = "LabRole"
}

data "aws_vpc" "techchallenge-vpc" {
  filter {
    name   = "tag:Name"
    values = ["techchallenge-vpc"]
  }
}

data "aws_subnets" "private-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}


resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  vpc_id = data.aws_vpc.techchallenge-vpc.id
}



resource "aws_eks_cluster" "techchallenge-eks-cluster" {
  name     = "techchallenge-eks-cluster"
  role_arn = data.aws_iam_role.LabRole.arn
  version  = "1.30"
  tags = {
    Environment = "prod"
  }

  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids = data.aws_subnets.private-subnets.ids
    endpoint_private_access = true
    security_group_ids = [aws_security_group.eks_security_group.id]

  }
  kubernetes_network_config {
    ip_family = "ipv4"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

}

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.techchallenge-eks-cluster.name
  node_group_name = "nodegroup"
  node_role_arn   = data.aws_iam_role.LabRole.arn
  subnet_ids = data.aws_subnets.private-subnets.ids
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

}