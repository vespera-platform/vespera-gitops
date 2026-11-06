terraform {
  backend "s3" {
    bucket       = "vespera-tfstate-835780010951"
    key          = "eks/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    assume_role = {
      role_arn = "arn:aws:iam::835780010951:role/vespera-terraform"
    }
  }
}