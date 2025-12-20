resource "kubernetes_namespace" "observability" {
  metadata { name = "observability" }
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}