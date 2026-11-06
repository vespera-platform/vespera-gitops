provider "aws" {
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::835780010951:role/vespera-terraform"
  }

  default_tags {
    tags = {
      Project   = "vespera"
      ManagedBy = "terraform"
    }
  }
}