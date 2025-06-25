/**
 * # Outputs do Módulo de Gerenciamento de Roles IAM
 */

output "added_roles" {
  description = "Roles que foram adicionadas à service account"
  value       = var.roles_to_add
}

output "removed_roles" {
  description = "Roles que foram explicitamente removidas"
  value       = var.roles_to_remove
}

output "service_account" {
  description = "Email da service account que teve suas roles gerenciadas"
  value       = var.service_account_email
}
