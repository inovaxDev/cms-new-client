terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

resource "vault_policy" "client_policy" {
  name   = "${var.client_name}-kv-policy"
  policy = <<EOT
    path "${var.client_namespace}_kv/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

resource "vault_token" "client_token" {
  depends_on = [vault_policy.client_policy]

  policies = [vault_policy.client_policy.name]
  metadata = {
    app = "cms"
  }
}

resource "kubernetes_secret" "secret_store_vault_token" {
  depends_on = [vault_token.client_token]

  metadata {
    name      = "vault-secret-store-token"
    namespace = var.client_namespace
  }

  data = {
    token = vault_token.client_token.client_token
  }

  type = "generic"
}

resource "kubernetes_manifest" "vault_secret_store" {
  depends_on = [kubernetes_secret.secret_store_vault_token]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "secret-store"
      namespace = var.client_namespace
    }
    spec = {
      provider = {
        vault = {
          server  = var.secret_store_server
          path    = var.secret_store_path
          version = var.secret_store_version
          auth = {
            tokenSecretRef = {
              name = kubernetes_secret.secret_store_vault_token.metadata[0].name
              key  = "token"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "backend_external_secret" {
  depends_on = [kubernetes_manifest.vault_secret_store]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "cms-backend-env-external-secret"
      namespace = var.client_namespace
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = kubernetes_manifest.vault_secret_store.manifest.metadata.name
        kind = "SecretStore"
      }
      target = {
        name           = "cms-backend-env"
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = "backend-env"
          }
          rewrite = [
            {
              regexp = {
                source = "[^a-zA-Z0-9 -]"
                target = "_"
              }
            }
          ]
        }
      ]
    }
  }
}
