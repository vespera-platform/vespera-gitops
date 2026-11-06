provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "eu-north-1", "--role-arn", "arg:aws:iam::835780010951:role/vespera-terraform"]
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.10.5"
  namespace        = "argocd"
  create_namespace = true
  values           = [file("${path.module}/../bootstrap/argocd-values.yaml")]

  depends_on = [module.eks]
}

resource "helm_release" "root" {
  name       = "root"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.7"
  namespace  = "argocd"

  values = [yamlencode({
    applications = {
      root = {
        namespace = "argocd"
        project   = "default"
        source = {
          repoURL        = "https://github.com/vespera-platform/vespera-gitops.git"
          targetRevision = "main"
          path           = "clusters/eks/apps"
        }
        destination = {
          server    = "https://kubernetes.default.svc",
          namespace = "argocd"
        }
        syncPolicy = {
          automated = {
            selfHeal = true,
            prune    = true
          }
        }
      }
    }
  })]

  depends_on = [helm_release.argocd]
}