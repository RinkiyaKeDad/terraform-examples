provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "cert-manager" {
  name             = "jetstack"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.3.1"
  set {
    name  = "installCRDs"
    value = "true"
  }
}
