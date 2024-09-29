## EKS subnets
#Referencing public subnets
data "aws_subnets" "public-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnet" "public_az1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["subnet-public-az1"]
  }
  
}

data "aws_subnet" "public_az2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["subnet-public-az2"]
  }
}

data "aws_subnet" "private_az1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["subnet-private-az1"]
  }
  
}

data "aws_subnet" "private_az2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["subnet-private-az2"]
  }
}


resource "aws_eks_cluster" "techchallenge_eks_cluster" {
  name     = "techchallenge-eks-cluster"
  role_arn = "arn:aws:iam::117590171476:role/LabRole"
  version  = "1.30"

  vpc_config {
    security_group_ids = [aws_security_group.eks_security_group.id]
    subnet_ids = [
      data.aws_subnet.public_az1.id,
      data.aws_subnet.public_az2.id,
    ]
  }
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = "techchallenge-eks-cluster"
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = "arn:aws:iam::117590171476:role/LabRole"
  subnet_ids = [
    data.aws_subnet.private_az1.id,
    data.aws_subnet.private_az2.id,
  ]

  selector {
    namespace = "default"
  }

  depends_on = [data.aws_vpc.techchallenge-vpc, aws_eks_cluster.techchallenge_eks_cluster]

}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Controla o acesso ao cluster EKS"
  vpc_id      = data.aws_vpc.techchallenge-vpc.id
}

output "eks_cluster_name" {
  value = data.aws_vpc.techchallenge-vpc.tags.Name
}

output "fargate_profile_name" {
  value = aws_eks_fargate_profile.fargate_profile.fargate_profile_name
}