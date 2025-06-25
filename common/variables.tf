/**
 * # Variáveis Comuns
 *
 * Variáveis compartilhadas entre todas as aplicações do projeto de Workload Identity Federation.
 * Este arquivo deve ser importado pelos módulos que precisam dessas variáveis.
 */

locals {
  # Variáveis do projeto
  project_id = "my-project-id"
  region     = "us-central1"
  zone       = "us-central1-c"
  
  # Variáveis do Workload Identity
  workload_identity_pool = "my-project-id.svc.id.goog"
  
  # Configuração do cluster GKE
  cluster_name = "my-gke-cluster"
  
  # Configuração do provider Kubernetes
  kubernetes_provider = {
    host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  }
}

# Obter dados do cliente Google para autenticação com GKE
data "google_client_config" "default" {}

# Obter dados do cluster GKE
data "google_container_cluster" "my_cluster" {
  name     = local.cluster_name
  location = local.zone
  project  = local.project_id
}
