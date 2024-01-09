terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}

resource "google_dns_record_set" "vault_dns_record" {
  name         = "${var.client_namespace}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [var.ingress_controller_ip]
}

resource "kubernetes_manifest" "prod_cert_manager" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "cert-manager-prod"
      namespace = var.client_namespace
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.cert_manager_email
        privateKeySecretRef = {
          name = "cert-manager-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "ingress" {
  depends_on = [kubernetes_manifest.prod_cert_manager]
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"

    metadata = {
      name      = "ingress"
      namespace = var.client_namespace

      annotations = {
        "kubernetes.io/ingress.class"  = "nginx"
        "cert-manager.io/issuer"       = kubernetes_manifest.prod_cert_manager.manifest.metadata.name
        "cert-manager.io/duration"     = "2140h"
        "cert-manager.io/renew-before" = "1500h"
      }
    }

    spec = {
      tls = [
        {
          hosts      = ["${var.client_namespace}.${var.domain}"]
          secretName = "${var.client_namespace}-tls-certificate"
        }
      ]

      ingressClassName = "nginx"

      rules = [
        {
          host = "${var.client_namespace}.${var.domain}"

          http = {
            paths = [
              {
                path     = "/"
                pathType = "Exact"

                backend = {
                  service = {
                    name = "frontend-service"
                    port = {
                      number = 80
                    }
                  }
                }
              },
              {
                path     = "/api"
                pathType = "Prefix"

                backend = {
                  service = {
                    name = "backend-service"
                    port = {
                      number = 80
                    }
                  }
                }
              },
            ]
          }
        }
      ]
    }
  }
}
