# Workload Identity Federation - GKE

## Visão geral

Este módulo implementa a configuração de Workload Identity Federation para o Google Kubernetes Engine (GKE), permitindo que pods no Kubernetes acessem recursos do Google Cloud de forma segura sem necessidade de armazenar credenciais estáticas.

O Workload Identity Federation é o método recomendado pelo Google para permitir que workloads em execução no GKE acessem serviços do Google Cloud de forma segura, substituindo o uso de chaves de conta de serviço estáticas por tokens temporários obtidos automaticamente.

## Recursos provisionados

* Definições de roles IAM para PubSub e Storage
* Configurações e outputs para Workload Identity Federation
* Estrutura de namespaces para organização de aplicações
* Service Accounts do Google Cloud (GSAs) vinculadas às Service Accounts do Kubernetes (KSAs)

## Estrutura do módulo

```
gke-workload-identity/
├─ outputs.tf             # Outputs para referência externa (usa outputs individuais do módulo common)
├─ provider.tf            # Configuração do provider (usa outputs individuais do módulo common)
├─ ARCHITECTURE.md        # Documentação da arquitetura e princípios aplicados
├─ common/                # Módulo de variáveis e configurações comuns
│   ├─ variables.tf       # Variáveis centralizadas e definições de locals
│   └─ outputs.tf         # Outputs individuais para cada variável local (sem referência direta a locals)
├─ modules/               # Módulos reutilizáveis
│   ├─ workload-identity/ # Módulo para configuração de identidade
│   │   ├─ main.tf       # Lógica principal para configuração de Workload Identity
│   │   ├─ variables.tf   # Variáveis específicas para configuração de identidade
│   │   └─ outputs.tf     # Outputs relacionados à configuração de identidade
│   └─ iam-roles/        # Módulo para gerenciamento de roles IAM
│       ├─ main.tf       # Lógica para adicionar e remover roles IAM
│       ├─ variables.tf   # Variáveis específicas para gerenciamento de roles
│       └─ outputs.tf     # Outputs relacionados às roles gerenciadas
└─ namespaces/            # Organização por namespaces
    └─ sre/               # Namespace SRE
        └─ apps/          # Aplicações no namespace SRE
            ├─ sre-app/    # Exemplo de aplicação SRE
            │   └─ main.tf  # Configuração da aplicação (usa outputs individuais do módulo common)
            └─ sre-app2/   # Outro exemplo de aplicação SRE
                └─ main.tf  # Configuração da aplicação (usa outputs individuais do módulo common)
```

### Explicação da Estrutura

1. **Raiz do Projeto**:
   - `outputs.tf`: Exporta informações importantes do projeto usando os outputs individuais do módulo common
   - `provider.tf`: Configura os providers Terraform (Google, Kubernetes) usando os outputs individuais do módulo common
   - `ARCHITECTURE.md`: Documentação detalhada sobre os princípios arquiteturais e sua aplicação prática

2. **Módulo Common**:
   - Centraliza todas as variáveis e configurações compartilhadas
   - `variables.tf`: Define variáveis e locals que são usados em todo o projeto
   - `outputs.tf`: Exporta cada variável local como um output individual (sem referência direta a `locals`)

3. **Módulos Reutilizáveis**:
   - **workload-identity**: Gerencia a configuração de identidade entre Kubernetes e Google Cloud
   - **iam-roles**: Gerencia permissões IAM de forma declarativa, com mecanismos para adicionar e remover roles

4. **Namespaces e Aplicações**:
   - Organização hierárquica por namespace e aplicação
   - Cada aplicação importa o módulo common e usa seus outputs individuais
   - Cada aplicação utiliza os módulos workload-identity e iam-roles para configurar suas permissões

## Abordagem Arquitetural e Refatoração

Este projeto foi refatorado seguindo princípios de engenharia de software para melhorar a manutenção, reutilização e segurança. Abaixo estão as principais escolhas arquiteturais e suas justificativas:

### 1. Separação de Responsabilidades

Adotamos uma arquitetura modular com clara separação de responsabilidades:

- **Módulo `workload-identity`**: Responsável apenas pela configuração da identidade (GSAs e KSAs)
- **Módulo `iam-roles`**: Responsável exclusivamente pelo gerenciamento de permissões IAM
- **Módulo `common`**: Centraliza variáveis e configurações compartilhadas

Esta separação permite que cada componente seja desenvolvido, testado e mantido independentemente, facilitando a manutenção e reduzindo o risco de mudanças não intencionais.

### 2. Gerenciamento Declarativo de Permissões

O módulo `iam-roles` implementa uma abordagem declarativa para gerenciar permissões:

- **`roles_to_add`**: Lista de roles IAM que devem ser concedidas à service account
- **`roles_to_remove`**: Lista de roles IAM que devem ser explicitamente removidas
- **Uso de `google_project_iam_binding`**: Garante que o Terraform gerencie completamente o ciclo de vida das permissões

Esta abordagem permite:
- Controle granular sobre as permissões
- Remoção explícita de roles não desejadas
- Evitar permissões “zumbi” que persistem mesmo após serem removidas do código

### 3. Centralização de Variáveis e Configurações

O módulo `common` centraliza todas as variáveis e configurações compartilhadas:

- **Variáveis de projeto**: `project_id`, `region`, `zone`
- **Configuração do Workload Identity**: `workload_identity_pool`
- **Configuração do provider Kubernetes**: Dados de conexão com o cluster GKE (marcado como sensível)

Benefícios:
- Eliminação de duplicação de código (DRY - Don't Repeat Yourself)
- Consistência garantida entre todas as aplicações
- Facilidade de manutenção: mudanças em um único lugar são refletidas em todo o projeto

### 4. Princípio do Privilégio Mínimo

Implementamos opções detalhadas de permissões para Storage e PubSub:

- **Storage**: Desde `roles/storage.objectViewer` (apenas leitura) até `roles/storage.admin` (controle total)
- **PubSub**: Desde `roles/pubsub.subscriber` (apenas consumir) até `roles/pubsub.admin` (controle total)

Esta granularidade permite que cada aplicação receba apenas as permissões mínimas necessárias para seu funcionamento, reduzindo a superfície de ataque e seguindo as melhores práticas de segurança.

### 5. Reutilização de Service Accounts

O projeto suporta a reutilização de GSAs e KSAs existentes:

- **`create_gsa = false`**: Usa uma GSA existente em vez de criar uma nova
- **`create_ksa = false`**: Usa uma KSA existente em vez de criar uma nova

Esta flexibilidade permite que o módulo seja usado em ambientes onde as service accounts já foram criadas por outros processos ou em migrações de infraestrutura existente.

### 6. Padronização entre Aplicações

Todas as aplicações (`sre-app`, `sre-app2`, etc.) seguem o mesmo padrão de configuração:

- Importam o módulo `common` para variáveis compartilhadas
- Usam o módulo `workload-identity` para configuração de identidade
- Usam o módulo `iam-roles` para gerenciamento de permissões

Esta padronização facilita o onboarding de novos desenvolvedores e a criação de novas aplicações, além de garantir consistência em todo o projeto.

## Pré-requisitos

1. Cluster GKE com Workload Identity habilitado
2. Permissões para criar e gerenciar Service Accounts no Google Cloud
3. Permissões para conceder roles IAM às Service Accounts
4. Kubernetes Provider configurado para acessar o cluster GKE
5. Backend GCS configurado para armazenamento do estado do Terraform

## Variáveis

### Obrigatórias

| Nome | Descrição |
|------|-----------|
| `project_id` | ID do projeto Google Cloud |
| `workload_identity_pool` | ID do pool de identidade do Workload Identity |

### Opcionais

| Nome | Descrição | Valor padrão |
|------|-----------|-------------|
| `region` | Região do Google Cloud | `us-central1` |
| `zone` | Zona do Google Cloud | `us-central1-c` |

## Uso

### Configuração básica

```hcl
module "workload_identity" {
  source = "./environments/shared/development/gke-workload-identity"
  
  project_id           = "seu-projeto-id"
  workload_identity_pool = "seu-projeto-id.svc.id.goog"
}
```

### Adicionando uma nova aplicação

1. Crie um novo diretório para a aplicação em `namespaces/NAMESPACE/apps/NOME-APP`

2. Crie um arquivo `main.tf` para a aplicação:

```hcl
data "terraform_remote_state" "root" {
  backend = "gcs"
  config = {
    bucket = "tf-iac-infra-shared-dev"
    prefix = "environments/shared/development/gke-workload-identity"
  }
}

# Importar o módulo common para variáveis compartilhadas
module "common" {
  source = "../../../../common"
}

# Referencial para a ID da GSA
locals {
  gsa_id = "nome-app-gsa"
  ksa_name = "nome-app-ksa"
  namespace = "namespace-app"
  app_name = "Nome da Aplicação"
  
  # Roles para adicionar à service account
  roles_to_add = [
    "roles/storage.objectViewer",
    "roles/pubsub.subscriber"
  ]
  
  # Roles para remover explicitamente
  roles_to_remove = [
    "roles/storage.admin",
    "roles/pubsub.admin"
  ]
}

# Usar o módulo de Workload Identity Federation
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
```

3. Crie o arquivo `variables.tf` para a aplicação:

```hcl
# Não precisamos mais declarar estas variáveis aqui
# Elas são importadas do módulo common

# Variáveis específicas da aplicação
variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "nome-app"
}

variable "namespace" {
  description = "Namespace Kubernetes onde a aplicação será implantada"
  type        = string
  default     = "namespace-app"
}
```

## Outputs

| Nome | Descrição |
|------|----------|
| `workload_identity_info` | Informações sobre a configuração do Workload Identity |
| `project_id` | ID do projeto Google Cloud |
| `region` | Região do Google Cloud |
| `zone` | Zona do Google Cloud |
| `workload_identity_pool` | ID do pool de identidade do Workload Identity |
| `cluster_name` | Nome do cluster GKE |
| `kubernetes_provider` | Configuração do provider Kubernetes (marcado como sensível) |

## Verificação pós-implantação

1. Verifique se as Service Accounts do Google Cloud foram criadas:

```bash
gcloud iam service-accounts list --project=SEU_PROJETO_ID
```

2. Verifique os papéis (roles) associados a cada Service Account:

```bash
gcloud projects get-iam-policy SEU_PROJETO_ID --format=json | jq '.bindings[] | select(.members[] | contains("serviceAccount:NOME_SA@SEU_PROJETO_ID.iam.gserviceaccount.com"))'
```

3. Verifique se as KSAs estão configuradas no cluster:

```bash
kubectl get sa -n NAMESPACE
```

4. Valide as anotações de Workload Identity nas KSAs:

```bash
kubectl describe sa NOME-KSA -n NAMESPACE
```

## Princípios de segurança

1. **Privilégio mínimo**: Cada Service Account deve ter apenas as permissões necessárias para sua função específica.
2. **Segregação de responsabilidades**: Cada aplicação deve ter sua própria GSA e KSA dedicadas.
3. **Nomenclatura padronizada**: 
   - KSAs: `[aplicação]-ksa`
   - GSAs: `[namespace]-[aplicação]-[função]@[project-id].iam.gserviceaccount.com`
4. **Auditoria**: Configure auditorias regulares de acesso e uso das Service Accounts.

## Manutenção

### Adicionando novas roles IAM

Para adicionar novos conjuntos de roles, modifique o arquivo `roles.tf`:

```hcl
locals {
  # Roles existentes...
  
  # Nova categoria de roles
  bigquery_roles = {
    reader = ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"]
    writer = ["roles/bigquery.dataEditor", "roles/bigquery.jobUser"]
    admin  = ["roles/bigquery.admin"]
  }
}

# Atualizar também o output para incluir as novas roles
output "roles" {
  description = "Mapa de roles IAM organizadas por serviço"
  value = {
    pubsub   = local.pubsub_roles
    storage  = local.storage_roles
    bigquery = local.bigquery_roles  # Adicionar novas roles ao output
  }
}
```

### Rotação de Service Accounts

Para rotar uma Google Service Account:

1. Crie uma nova GSA com as mesmas permissões
2. Atualize os bindings do Workload Identity para apontar para a nova GSA
3. Após confirmar que todos os workloads estão funcionando, remova a GSA antiga

## Solução de problemas

### Erros comuns de Workload Identity

1. **Permissão negada ao acessar recursos do Google Cloud**:
   - Verifique se a KSA tem a anotação correta para o Workload Identity
   - Confirme se a GSA tem as permissões necessárias
   - Verifique se o binding IAM entre KSA e GSA está configurado corretamente

2. **Erro "Unable to generate access token"**:
   - Verifique se o Workload Identity está habilitado no cluster GKE
   - Confirme se o formato do pool de identidades está correto (`PROJECT_ID.svc.id.goog`)

3. **Configuração incorreta de namespace**:
   - O namespace deve existir antes de criar recursos nele
   - O formato do membro no binding IAM deve ser `serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]`

### Depuração

1. Verifique os logs do pod que está tentando usar o Workload Identity
2. Use o comando `kubectl describe pod POD_NAME -n NAMESPACE` para verificar eventos relacionados à inicialização
3. Teste a autenticação manualmente executando um pod temporário com a KSA configurada

## Referências

- [Documentação oficial do Google Cloud sobre Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [Melhores práticas de segurança para GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/security-overview)
- [Guia para migração de chaves de serviço para Workload Identity](https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-engine-now-supports-workload-identity)
