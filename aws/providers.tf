terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    shared_config_files = ["~/.aws/config"]
    shared_credentials_files = ["~/.aws/credentials"]
    region = var.region
    #profile = "awsprofile"
}

#terraform {
#  backend "s3" {
#    bucket = "dt-storage"
#    key    = "terraform.tfstate"
#  }
#}
