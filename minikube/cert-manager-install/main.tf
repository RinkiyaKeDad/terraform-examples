provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "cert-manager" {
  name  = "jetstack"
  chart = "https://charts.jetstack.io"
}
