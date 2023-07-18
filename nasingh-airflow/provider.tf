terraform {
  required_version = "1.4.6"
  backend "s3" {
    bucket                  = "nasingh-airflow"
    key                     = "terraform/terraform.tfstate"
    region                  = "us-east-1"
    profile                 = "default"
    shared_credentials_file = "$HOME/.aws/config"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.76"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  profile                 = "default"
  shared_credentials_file = "$HOME/.aws/config"
}
