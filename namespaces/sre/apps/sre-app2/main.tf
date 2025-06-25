/**
 * # SRE App2 - Workload Identity Federation
 *
 * Configuração de Workload Identity Federation para a aplicação SRE App2.
 * Este arquivo configura a KSA e GSA com permissões para acesso a Storage e PubSub.
 * Utiliza o módulo reutilizável de Workload Identity Federation.
 */

# Definições locais para a aplicação
locals {
  app_name  = "sre-app2"
  namespace = "sre"
  ksa_name  = "${local.app_name}-sa"
  # Removendo a duplicação do prefixo "sre-"
  app_id    = "app2"  # Nome da aplicação sem o prefixo do namespace
  gsa_id    = "${local.namespace}-${local.app_id}"
}

# Importar variáveis comuns centralizadas
module "common" {
  source = "../../../../common"
}

# Configuração do provider Kubernetes usando GKE
provider "kubernetes" {
  host                   = module.common.kubernetes_provider.host
  token                  = module.common.kubernetes_provider.token
  cluster_ca_certificate = module.common.kubernetes_provider.cluster_ca_certificate
}

# Definir roles para a aplicação
locals {
  # Roles para adicionar à service account
  roles_to_add = [
    # Storage roles - escolha apenas uma opção conforme necessidade
    "roles/storage.objectViewer",     # Apenas leitura de objetos
    # "roles/storage.objectUser",      # Leitura/escrita de objetos
    # "roles/storage.objectAdmin",     # Controle total de objetos
    
    # PubSub roles - escolha conforme necessidade
    "roles/pubsub.publisher",        # Apenas publicar mensagens
    # "roles/pubsub.subscriber",       # Apenas consumir mensagens
    # "roles/pubsub.editor",           # Publicar e consumir mensagens
    
    # Adicione outras roles de Storage ou PubSub conforme necessário
  ]

  # Roles que precisam ser explicitamente removidas
  roles_to_remove = [
    # "roles/storage.admin",            # Remover acesso administrativo ao Storage
    # "roles/pubsub.admin",            # Remover acesso administrativo ao PubSub
  ]
}

# Usar o módulo de Workload Identity Federation com caminho absoluto
module "workload_identity" {
  source = "../../../../modules/workload-identity"

  project_id   = module.common.project_id
  gsa_id       = local.gsa_id
  ksa_name     = local.ksa_name
  namespace    = local.namespace
  display_name = "Service Account para ${local.app_name}"
  description  = "Gerencia acesso ao Storage e PubSub para a aplicação ${local.app_name}"
  
  # Não passamos mais roles para o módulo workload_identity
  # As roles são gerenciadas pelo módulo iam_roles
  roles = []
  
  # Usar GSA e KSA existentes em vez de tentar criar novas
  create_gsa = false
  create_ksa = false
  
  # Usar o pool de identidade definido nas variáveis comuns
  workload_identity_pool = module.common.workload_identity_pool
}

# Usar o módulo de gerenciamento de roles IAM
module "iam_roles" {
  source = "../../../../modules/iam-roles"

  project_id            = module.common.project_id
  service_account_email = "${local.gsa_id}@${module.common.project_id}.iam.gserviceaccount.com"
  
  # Roles para adicionar à service account
  roles_to_add = local.roles_to_add
  
  # Roles para remover explicitamente
  roles_to_remove = local.roles_to_remove
}

# Outputs para documentar os recursos
output "kubernetes_service_account" {
  description = "Informações da Kubernetes Service Account"
  value       = module.workload_identity.ksa
}

output "google_service_account" {
  description = "Informações da Google Service Account"
  value       = module.workload_identity.gsa
}

output "roles" {
  description = "Roles atribuídas à Google Service Account"
  value       = module.workload_identity.roles
}

output "workload_identity_binding" {
  description = "Informações sobre o binding do Workload Identity"
  value       = module.workload_identity.workload_identity_binding
}
