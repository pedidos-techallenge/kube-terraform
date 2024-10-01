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


resource "aws_eks_fargate_profile" "fargate_profile" {  
  cluster_name           = "techchallenge-eks-cluster"
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = "arn:aws:iam::117590171476:role/LabRole"
  subnet_ids             = data.aws_subnets.private.ids    

  selector {
    namespace = "default"
  }

  depends_on = [data.aws_vpc.techchallenge-vpc, aws_eks_cluster.techchallenge_eks_cluster]

}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Controla o acesso ao cluster EKS"
  vpc_id      =  data.aws_vpc.techchallenge-vpc.id  
}