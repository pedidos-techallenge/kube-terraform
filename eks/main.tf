terraform {
    backend "s3" {
    bucket = "techchallangebucket"
    key    = "eks.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {}