# Módulo de Gerenciamento de Roles IAM

Este módulo gerencia de forma completa as roles IAM para service accounts no Google Cloud Platform, permitindo adicionar novas roles e remover roles antigas de forma declarativa.

## Funcionalidades

- **Adição de roles**: Adiciona múltiplas roles IAM a uma service account
- **Remoção de roles**: Remove explicitamente roles IAM específicas
- **Gerenciamento completo**: Garante que o Terraform gerencie completamente o ciclo de vida das permissões
- **Abordagem declarativa**: Define exatamente quais permissões a service account deve ter

## Uso

```hcl
module "iam_roles" {
  source = "../../modules/iam-roles"

  project_id            = "my-project-id"
  service_account_email = "my-service-account@my-project-id.iam.gserviceaccount.com"
  
  roles_to_add = [
    "roles/storage.objectViewer",
    "roles/pubsub.subscriber",
    "roles/logging.viewer"
  ]
  
  roles_to_remove = [
    "roles/storage.admin",
    "roles/pubsub.publisher"
  ]
}
```

## Variáveis de entrada

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|------------|
| project_id | ID do projeto Google Cloud onde as roles serão gerenciadas | string | - | sim |
| service_account_email | Email completo da service account para a qual as roles serão gerenciadas | string | - | sim |
| roles_to_add | Lista de roles IAM para adicionar à service account | list(string) | [] | não |
| roles_to_remove | Lista de roles IAM para remover explicitamente | list(string) | [] | não |

## Outputs

| Nome | Descrição |
|------|-----------|
| added_roles | Roles que foram adicionadas à service account |
| removed_roles | Roles que foram explicitamente removidas |
| service_account | Email da service account que teve suas roles gerenciadas |

## Considerações importantes

- O uso de `google_project_iam_binding` significa que o Terraform gerencia completamente quem tem acesso a cada role específica.
- Se outras service accounts ou usuários tiverem a mesma role, eles serão removidos a menos que estejam explicitamente incluídos.
- Esta abordagem é adequada quando apenas uma aplicação usa cada service account ou quando você tem controle completo sobre as permissões.

## Princípios de segurança

Este módulo foi projetado seguindo os princípios:

- **Privilégio mínimo**: Conceda apenas as permissões necessárias
- **Separação de responsabilidades**: Separe a gestão de identidade da gestão de permissões
- **Rastreabilidade**: Todas as permissões são claramente documentadas no código
- **Conformidade**: Facilita auditorias e requisitos de compliance
