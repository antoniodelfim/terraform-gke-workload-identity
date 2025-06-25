/**
 * # Variáveis para o Módulo de Gerenciamento de Roles IAM
 */

variable "project_id" {
  description = "ID do projeto Google Cloud onde as roles serão gerenciadas"
  type        = string
}

variable "service_account_email" {
  description = "Email completo da service account para a qual as roles serão gerenciadas"
  type        = string
}

variable "roles_to_add" {
  description = "Lista de roles IAM para adicionar à service account"
  type        = list(string)
  default     = []
}

variable "roles_to_remove" {
  description = "Lista de roles IAM para remover explicitamente (definindo uma lista vazia de membros)"
  type        = list(string)
  default     = []
}
