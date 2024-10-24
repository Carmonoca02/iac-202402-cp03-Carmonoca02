terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70"
    }
  }
  backend "s3" {
    bucket         = "tf-s3-fernanda-001"
    key            = "terraform.tfstate"
    dynamodb_table = "tf-dynamo-fernanda-001"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}