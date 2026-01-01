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
          image = "swaggerapi/swagger-ui"
          port { container_port = 8080 }
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


# Service for Frontend
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "frontend"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.frontend]
}

# Service for API
resource "kubernetes_service" "api" {
  metadata {
    name      = "api-service"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "api"
    }

    port {
      port        = 80
      target_port = 5678
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.api]
}

# Ingress with ALB and path-based routing
resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "main-ingress"
    namespace = kubernetes_namespace.apps.metadata[0].name
    
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{ HTTP = 80 }])
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/group.name"       = "eks-demo"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        # Path for Frontend - Root path
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        # Path for API - /api path
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.frontend,
    kubernetes_service.api
  ]
}


