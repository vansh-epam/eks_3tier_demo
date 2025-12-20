resource "kubernetes_namespace" "apps" {
  metadata { name = "apps" }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels    = { app = "frontend" }
  }

  spec {
    replicas = 2
    selector { match_labels = { app = "frontend" } }

    template {
      metadata { labels = { app = "frontend" } }
      spec {
        container {
          name  = "frontend"
          image = "containous/whoami"
          port { container_port = 80 }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels    = { app = "api" }
  }

  spec {
    replicas = 2
    selector { match_labels = { app = "api" } }

    template {
      metadata { labels = { app = "api" } }
      spec {
        container {
          name  = "api"
          image = "hashicorp/http-echo"
          args  = ["-text=Hello from API"]
          port { container_port = 5678 }
        }
      }
    }
  }
}