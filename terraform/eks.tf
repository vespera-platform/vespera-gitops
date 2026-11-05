module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "21.29.0"
  name                                     = "vespera"
  kubernetes_version                       = "1.35"
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = ["185.164.142.227/32"]
  enable_cluster_creator_admin_permissions = true
  enable_irsa = false
  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = { before_compute = true }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m7i-flex.large"]
      min_size       = 3
      max_size       = 4
      desired_size   = 3
    }
  }

  access_entries = {
    oskar = {
      principal_arn = "arn:aws:iam::835780010951:role/managed/AccountFullAccessRole"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
}