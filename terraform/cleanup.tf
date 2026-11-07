resource "terraform_data" "k8s_cleanup" {
  depends_on = [helm_release.root, helm_release.argocd, module.eks]

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash"]
    command     = "scripts/pre-destroy.sh"
  }
}