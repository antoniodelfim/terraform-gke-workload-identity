/**
 * # Outputs do Módulo Comum
 *
 * Outputs para expor variáveis e configurações comuns para outros módulos.
 */

output "project_id" {
  description = "ID do projeto GCP"
  value       = local.project_id
}

output "region" {
  description = "Região do GCP"
  value       = local.region
}

output "zone" {
  description = "Zona do GCP"
  value       = local.zone
}

output "workload_identity_pool" {
  description = "Pool de identidade do Workload Identity"
  value       = local.workload_identity_pool
}

output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = local.cluster_name
}

output "kubernetes_provider" {
  description = "Configuração do provider Kubernetes"
  value       = local.kubernetes_provider
  sensitive   = true
}
