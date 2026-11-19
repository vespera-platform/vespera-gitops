module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "21.29.0"
  name                                     = "vespera"
  kubernetes_version                       = "1.35"
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = [var.admin_cidr]
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = false
  enabled_log_types                        = ["audit", "authenticator"]
  cloudwatch_log_group_retention_in_days   = 3

  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
      configuration_values = jsonencode({ enableNetworkPolicy = "true" })
    }
    eks-pod-identity-agent = { before_compute = true }
    aws-ebs-csi-driver = {
      pod_identity_association = [{
        role_arn        = aws_iam_role.ebs_csi.arn
        service_account = "ebs-csi-controller-sa"
      }]
    }
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