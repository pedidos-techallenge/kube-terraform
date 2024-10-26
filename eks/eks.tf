## EKS subnets
#Referencing public subnets
data "aws_vpc" "techchallenge-vpc" {
  filter {
    name   = "tag:Name"
    values = ["techchallenge-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }
}

resource "aws_eks_cluster" "techchallenge_eks_cluster" {  
  name     = "techchallenge-eks-cluster"
  role_arn = "arn:aws:iam::117590171476:role/LabRole"
  version  = "1.30"

  vpc_config {
    security_group_ids = [aws_security_group.eks_security_group.id]
    subnet_ids         = data.aws_subnets.private.ids        
  }
}

resource "aws_eks_node_group" "techchallenge_eks_node_group" {
  cluster_name    = aws_eks_cluster.techchallenge_eks_cluster.name
  node_group_name = "techchallenge-node-group"
  node_role_arn   = "arn:aws:iam::117590171476:role/LabRole"  # Substitua pelo ARN correto do papel dos nós
  subnet_ids      = data.aws_subnets.private.ids
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [aws_eks_cluster.techchallenge_eks_cluster]
}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Controla o acesso ao cluster EKS"
  vpc_id      =  data.aws_vpc.techchallenge-vpc.id  
}