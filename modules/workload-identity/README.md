# Módulo de Workload Identity Federation

Este módulo implementa o padrão de Workload Identity Federation entre o GKE e o Google Cloud, seguindo as melhores práticas de segurança e os padrões definidos para o projeto.

## Funcionalidades

- Cria ou reutiliza uma Google Service Account (GSA) com as permissões necessárias
- Cria ou reutiliza uma Kubernetes Service Account (KSA) com as anotações apropriadas
- Configura o binding IAM entre a KSA e a GSA
- Atribui as roles IAM necessárias à GSA

## Uso

```hcl
module "workload_identity" {
  source = "../../modules/workload-identity"

  project_id   = "meu-projeto"
  gsa_id       = "namespace-aplicacao-funcao"
  ksa_name     = "aplicacao-funcao-ksa"
  namespace    = "meu-namespace"
  display_name = "Service Account para minha aplicação"
  description  = "Gerencia acesso aos recursos do Google Cloud para minha aplicação"
  
  roles = [
    "roles/storage.objectViewer",
    "roles/pubsub.subscriber"
  ]
}
```

## Variáveis de Entrada

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:----------:|
| project_id | ID do projeto Google Cloud | `string` | - | Sim |
| gsa_id | ID da Google Service Account (parte antes do @) | `string` | - | Sim |
| ksa_name | Nome da Kubernetes Service Account | `string` | - | Sim |
| namespace | Namespace do Kubernetes onde a KSA será criada | `string` | - | Sim |
| display_name | Nome de exibição da Google Service Account | `string` | `""` | Não |
| description | Descrição da Google Service Account | `string` | `"Gerenciada pelo Terraform para Workload Identity Federation"` | Não |
| roles | Lista de roles IAM a serem atribuídas à GSA | `list(string)` | `[]` | Não |
| create_ksa | Se true, cria a KSA. Se false, assume que a KSA já existe | `bool` | `true` | Não |
| create_gsa | Se true, cria a GSA. Se false, usa uma GSA existente | `bool` | `true` | Não |
| workload_identity_pool | ID do pool de identidade do Workload Identity | `string` | `""` | Não |

## Reutilização de Service Accounts Existentes

O módulo suporta a reutilização de Google Service Accounts (GSAs) e Kubernetes Service Accounts (KSAs) existentes, o que é útil em cenários como:

- Migração de infraestrutura existente para o Terraform
- Quando as service accounts são criadas por outros processos
- Para evitar erros 409 (conflito) ao tentar criar recursos que já existem

### Implementação Técnica

A funcionalidade de reutilização de service accounts é implementada usando o parâmetro `count` do Terraform e operadores ternários:

```hcl
# Criação da GSA apenas quando create_gsa = true
resource "google_service_account" "gsa" {
  count        = var.create_gsa ? 1 : 0
  account_id   = var.gsa_id
  # ...
}

# Obtenção de dados da GSA existente quando create_gsa = false
data "google_service_account" "existing_gsa" {
  count      = var.create_gsa ? 0 : 1
  account_id = var.gsa_id
  # ...
}

# Uso condicional da GSA nova ou existente
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.create_gsa ? google_service_account.gsa[0].name : data.google_service_account.existing_gsa[0].name
  # ...
}
```

Esta abordagem segue o princípio de Dependency Inversion mencionado na documentação de arquitetura, onde o módulo depende de abstrações (a GSA, independentemente de como foi criada) em vez de implementações concretas.

### Exemplo de reutilização de GSA existente

```hcl
module "workload_identity" {
  source = "../../modules/workload-identity"

  project_id   = "meu-projeto"
  gsa_id       = "namespace-aplicacao-funcao"  # ID da GSA existente
  ksa_name     = "aplicacao-funcao-ksa"
  namespace    = "meu-namespace"
  
  create_gsa   = false  # Indica que a GSA já existe
  create_ksa   = true   # Cria uma nova KSA
  
  roles = [
    "roles/storage.objectViewer"
  ]
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| gsa | Informações sobre a Google Service Account criada |
| ksa | Informações sobre a Kubernetes Service Account criada |
| roles | Roles atribuídas à Google Service Account |
| workload_identity_binding | Informações sobre o binding do Workload Identity |

## Padrões de Nomenclatura

Este módulo segue os padrões de nomenclatura definidos para o projeto:

- **Kubernetes Service Accounts**: `[aplicação]-[função]-ksa`
- **Google Service Accounts**: `[namespace]-[aplicação]-[função]@[project-id].iam.gserviceaccount.com`

## Princípios de Segurança

O módulo implementa os seguintes princípios de segurança:

1. **Privilégio mínimo**: Cada GSA recebe apenas as permissões necessárias
2. **Segregação de responsabilidades**: Cada aplicação tem sua própria KSA e GSA
3. **Rastreabilidade**: A nomenclatura padronizada facilita a auditoria
4. **Compliance**: Segue as melhores práticas para certificações como SOC2, PCI-DSS, HIPAA e ISO27001
