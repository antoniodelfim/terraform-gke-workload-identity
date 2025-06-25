# Arquitetura: Workload Identity Federation com IAM

## Módulos e Responsabilidades

- **`common`**: Centraliza variáveis e configurações compartilhadas
- **`workload-identity`**: Gerencia identidades entre Kubernetes e GCP
- **`iam-roles`**: Gerencia permissões IAM de forma declarativa

## Princípios Aplicados

- **Single Responsibility**: Cada módulo com responsabilidade única
- **DRY**: Eliminação de código duplicado via módulo `common`
- **Extensível**: `roles_to_add` e `roles_to_remove` para fácil expansão
- **Segurança**: Implementação do princípio do privilégio mínimo

## Decisões Chave

- **Separação de Identidade e Permissões**: Responsabilidades distintas em módulos separados
- **Gerenciamento Declarativo**: Controle completo do ciclo de vida das permissões
- **Centralização**: Variáveis e configurações compartilhadas em um único lugar

## Referências

- [Terraform Module Structure](https://www.terraform.io/language/modules/develop/structure)
- [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
