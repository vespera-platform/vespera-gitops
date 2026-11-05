module "vpc" {
  name               = "vespera"
  source             = "terraform-aws-modules/vpc/aws"
  version            = "6.7.3"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-north-1a", "eu-north-1b"]
  private_subnets    = ["10.0.0.0/20", "10.0.16.0/20"]
  public_subnets     = ["10.0.128.0/24", "10.0.129.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}