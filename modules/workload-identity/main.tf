/**
 * # Módulo de Workload Identity Federation
 *
 * Este módulo cria e configura os recursos necessários para implementar o Workload Identity Federation
 * entre o GKE e o Google Cloud, seguindo as melhores práticas de segurança.
 *
 * O módulo cria:
 * 1. Uma Google Service Account (GSA)
 * 2. Uma Kubernetes Service Account (KSA)
 * 3. O binding IAM entre a KSA e a GSA
 * 4. As permissões IAM necessárias para a GSA
 */

# Criação da Google Service Account (GSA)
resource "google_service_account" "gsa" {
  count        = var.create_gsa ? 1 : 0
  account_id   = var.gsa_id
  display_name = var.display_name
  description  = var.description
  project      = var.project_id
}

# Dados da Google Service Account existente (quando create_gsa = false)
data "google_service_account" "existing_gsa" {
  count      = var.create_gsa ? 0 : 1
  account_id = var.gsa_id
  project    = var.project_id
}

# Binding IAM para permitir que a KSA atue como a GSA
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.create_gsa ? google_service_account.gsa[0].name : data.google_service_account.existing_gsa[0].name
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.ksa_name}]"
  ]
}

# Criação da Kubernetes Service Account (KSA)
resource "kubernetes_service_account" "ksa" {
  count = var.create_ksa ? 1 : 0
  
  metadata {
    name      = var.ksa_name
    namespace = var.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.create_gsa ? google_service_account.gsa[0].email : data.google_service_account.existing_gsa[0].email
    }
  }
}

# Atribuição de roles à GSA usando binding para gerenciamento completo
resource "google_project_iam_binding" "gsa_roles" {
  for_each = toset(var.roles)
  
  project = var.project_id
  role    = each.value
  members = [
    "serviceAccount:${var.create_gsa ? google_service_account.gsa[0].email : data.google_service_account.existing_gsa[0].email}"
  ]
}
