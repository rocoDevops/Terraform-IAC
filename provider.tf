terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.4.0"
    }
  }
  backend "s3" {
    bucket = "terra-bucket0123"
    key    = "states/terra-bucket0123"
    region = "us-east-1"
    dynamodb_table = "c42"
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}