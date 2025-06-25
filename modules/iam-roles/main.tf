/**
 * # Módulo de Gerenciamento de Roles IAM
 *
 * Este módulo gerencia de forma completa as roles IAM para service accounts,
 * permitindo adicionar novas roles e remover roles antigas de forma declarativa.
 */

# Adicionar roles à service account
resource "google_project_iam_binding" "add_roles" {
  for_each = toset(var.roles_to_add)
  
  project = var.project_id
  role    = each.value
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

# Remover roles da service account
resource "google_project_iam_binding" "remove_roles" {
  for_each = toset(var.roles_to_remove)
  
  project = var.project_id
  role    = each.value
  
  # Lista vazia de membros significa que ninguém terá esta role
  members = []
}
