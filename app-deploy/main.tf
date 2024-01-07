terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_deployment" "cms_frontend_deployment" {
  metadata {
    name      = "cms-frontend"
    namespace = var.client_namespace

    labels = {
      app = "cms-frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "cms-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app   = "cms-frontend"
          owner = var.client_namespace
        }
      }

      spec {
        container {
          name  = "cms-frontend"
          image = var.frontend_image_config.image

          env_from {
            secret_ref {
              name = var.frontend_image_config.env_secret_name
            }
          }

          port {
            container_port = var.frontend_image_config.port
          }

          resources {
            limits = var.frontend_image_config.limits

            requests = var.frontend_image_config.requests
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.frontend_image_config.port
            }
            initial_delay_seconds = 30
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.frontend_image_config.port
            }
            initial_delay_seconds = 30
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "backend_deployment" {
  metadata {
    name      = "cms-backend"
    namespace = var.client_namespace

    labels = {
      app = "cms-backend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "cms-backend"
      }
    }

    template {
      metadata {
        labels = {
          app   = "cms-backend"
          owner = var.client_namespace
        }
      }

      spec {
        container {
          name  = "cms-backend"
          image = var.backend_image_config.image

          env_from {
            secret_ref {
              name = var.backend_image_config.env_secret_name
            }
          }

          port {
            container_port = var.backend_image_config.port
          }

          resources {
            limits = var.backend_image_config.limits

            requests = var.backend_image_config.requests
          }

          # liveness_probe {
          #   http_get {
          #     path = "/swagger"
          #     port = var.backend_image_config.port
          #   }
          #   initial_delay_seconds = 60
          #   period_seconds        = 5
          # }

          # readiness_probe {
          #   http_get {
          #     path = "/swagger"
          #     port = var.backend_image_config.port
          #   }
          #   initial_delay_seconds = 60
          #   period_seconds        = 5
          # }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend_service" {
  metadata {
    name      = "frontend-service"
    namespace = var.client_namespace
  }

  spec {
    selector = {
      app = "cms-frontend"
    }
    port {
      port        = 80
      target_port = var.frontend_image_config.port
    }
  }
}


resource "kubernetes_service" "backend_service" {
  metadata {
    name      = "backend-service"
    namespace = var.client_namespace
  }

  spec {
    selector = {
      app = "cms-backend"
    }
    port {
      port        = 80
      target_port = var.backend_image_config.port
    }
  }
}
