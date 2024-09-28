terraform {
    backend "s3" {
    bucket = "techchallangebucket"
    key    = "eks.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {}

### General data sources
data "aws_vpc" "techchallenge-vpc" {
  filter {
    name   = "tag:Name"
    values = ["techchallenge-vpc"]
  }
}