/**
 * # Provider Configuration
 *
 * Configuração dos providers necessários para o Workload Identity Federation.
 */

# Importar variáveis comuns centralizadas
module "common" {
  source = "./common"
}

# Configuração do provider Google
provider "google" {
  project = module.common.project_id
  region  = module.common.region
  zone    = module.common.zone
}

# Configuração do provider local para arquivos
provider "local" {}

# Configuração do backend para armazenar o estado do Terraform
terraform {
  required_version = ">= 1.10.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.18.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "environments/shared/development/gke-workload-identity"
  }
}
