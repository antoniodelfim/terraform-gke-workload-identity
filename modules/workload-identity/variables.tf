/**
 * # Variáveis do Módulo de Workload Identity Federation
 *
 * Este arquivo define as variáveis necessárias para o módulo de Workload Identity Federation.
 */

variable "project_id" {
  description = "ID do projeto Google Cloud onde os recursos serão criados"
  type        = string
}

variable "gsa_id" {
  description = "ID da Google Service Account (parte antes do @)"
  type        = string
}

variable "ksa_name" {
  description = "Nome da Kubernetes Service Account"
  type        = string
}

variable "namespace" {
  description = "Namespace do Kubernetes onde a KSA será criada"
  type        = string
}

variable "display_name" {
  description = "Nome de exibição da Google Service Account"
  type        = string
  default     = ""
}

variable "description" {
  description = "Descrição da Google Service Account"
  type        = string
  default     = "Gerenciada pelo Terraform para Workload Identity Federation"
}

variable "roles" {
  description = "Lista de roles IAM a serem atribuídas à Google Service Account"
  type        = list(string)
  default     = []
}

variable "create_ksa" {
  description = "Se true, cria a Kubernetes Service Account. Se false, assume que a KSA já existe"
  type        = bool
  default     = true
}

variable "create_gsa" {
  description = "Se true, cria a Google Service Account. Se false, assume que a GSA já existe"
  type        = bool
  default     = true
}

variable "workload_identity_pool" {
  description = "ID do pool de identidade do Workload Identity (normalmente project_id.svc.id.goog)"
  type        = string
  default     = ""
}
