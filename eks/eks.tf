### EKS subnets
# Referencing public subnets
# data "aws_subnets" "public-subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.techchallenge-vpc.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["*public*"]
#   }
# }


resource "aws_eks_cluster" "techchallenge_eks_cluster" {
  name     = "techchallenge-eks-cluster"
  role_arn = "arn:aws:iam::117590171476:role/LabRole"
  version  = "1.30"

  vpc_config {
    security_group_ids = [aws_security_group.eks_security_group.id]
    subnet_ids         = aws_subnet.eks_subnet[*].id
  }
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = "techchallenge-eks-cluster"
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = "arn:aws:iam::117590171476:role/LabRole"
  subnet_ids             = aws_subnet.eks_subnet[*].id

  selector {
    namespace = "default"
  }

  depends_on = [aws_eks_cluster.techchallenge_eks_cluster]

}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Controla o acesso ao cluster EKS"
  vpc_id      = aws_vpc.eks_vpc.id
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true
}

output "eks_cluster_name" {
  value = aws_eks_cluster.techchallenge_eks_cluster.name
}

output "fargate_profile_name" {
  value = aws_eks_fargate_profile.fargate_profile.fargate_profile_name
}