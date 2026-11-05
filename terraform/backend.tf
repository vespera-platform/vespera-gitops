terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
  }

  required_version = "~>1.16.0"

  backend "s3" {
    bucket = "vespera-tfstate-835780010951"
    key    = "eks/terraform.tfstate"
    region = "eu-north-1"
    assume_role = {
      role_arn = "arn:aws:iam::835780010951:role/vespera-terraform"
    }
    use_lockfile = true
  }
}