provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "one-minikube-namespace" {
  metadata {
    name = "my-first-terraform-namespace"
  }
}
