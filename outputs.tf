/**
 * # Outputs do Workload Identity Federation
 *
 * Outputs da configuração de Workload Identity Federation.
 * Estes outputs são usados pelo terraform_remote_state nas aplicações.
 */

# Output para informações sobre o Workload Identity
output "workload_identity_info" {
  description = "Informações sobre a configuração do Workload Identity"
  value = {
    pool_id = module.common.workload_identity_pool
    project = module.common.project_id
  }
}

# Output para a GSA usada no Workload Identity Federation
output "google_service_account" {
  description = "Google Service Account usada para Workload Identity Federation"
  value = {
    email = "sre-gsa@${module.common.project_id}.iam.gserviceaccount.com",
    name = "projects/${module.common.project_id}/serviceAccounts/sre-gsa@${module.common.project_id}.iam.gserviceaccount.com"
  }
}

# Output para informar sobre o módulo de Workload Identity
output "workload_identity_module" {
  description = "Informações sobre o módulo de Workload Identity"
  value = {
    path = "./modules/workload-identity"
    description = "Módulo para criação de GSAs e KSAs com Workload Identity Federation"
  }
}
