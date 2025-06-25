/**
 * # Outputs do Módulo de Workload Identity Federation
 *
 * Este arquivo define os outputs do módulo de Workload Identity Federation.
 */

# Output para a Google Service Account
output "gsa" {
  description = "Informações da Google Service Account criada ou existente"
  value = var.create_gsa ? {
    email      = google_service_account.gsa[0].email
    account_id = google_service_account.gsa[0].account_id
    id         = google_service_account.gsa[0].id
    name       = google_service_account.gsa[0].name
    unique_id  = google_service_account.gsa[0].unique_id
    project_id = var.project_id
    created    = true
  } : {
    email      = data.google_service_account.existing_gsa[0].email
    account_id = data.google_service_account.existing_gsa[0].account_id
    id         = data.google_service_account.existing_gsa[0].id
    name       = data.google_service_account.existing_gsa[0].name
    unique_id  = data.google_service_account.existing_gsa[0].unique_id
    project_id = var.project_id
    created    = false
  }
}

# Output para a Kubernetes Service Account
output "ksa" {
  description = "Informações da Kubernetes Service Account criada"
  value = var.create_ksa ? {
    name      = kubernetes_service_account.ksa[0].metadata[0].name
    namespace = kubernetes_service_account.ksa[0].metadata[0].namespace
    created   = true
  } : {
    name      = var.ksa_name
    namespace = var.namespace
    created   = false
  }
}

# Output para as roles atribuídas
output "roles" {
  description = "Roles atribuídas à Google Service Account"
  value       = var.roles
}

# Output para o binding do Workload Identity
output "workload_identity_binding" {
  description = "Informações sobre o binding do Workload Identity"
  value = {
    service_account_id = google_service_account_iam_binding.workload_identity_binding.service_account_id
    role               = google_service_account_iam_binding.workload_identity_binding.role
    member             = "serviceAccount:${var.workload_identity_pool}[${var.namespace}/${var.ksa_name}]"
  }
}

# Nota: O output available_roles foi removido pois as definições de roles
# agora são mantidas localmente em cada aplicação
