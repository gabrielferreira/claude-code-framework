<!-- framework-tag: v2.33.0 framework-file: SPECS_INDEX.template.md -->
# SPECS_INDEX — {NOME_DO_PROJETO}

> Índice de todas as specs do projeto. Consultar ANTES de implementar qualquer item.
> Ao criar spec nova: adicionar entrada aqui no domínio correto.

## Como usar

1. Identificar o domínio da mudança
2. Localizar a spec pelo ID ou palavras-chave
3. Abrir APENAS a spec identificada
4. Verificar status antes de implementar:

### Ciclo de vida dos status

| Status | Significa | Pode implementar? |
|--------|----------|-------------------|
| `rascunho` | Incompleta ou não revisada | Não — perguntar antes |
| `aprovada` | Time concordou, pronta para implementar | Sim |
| `em andamento` | Alguém está implementando | — (verificar quem) |
| `parcial` | Parte implementada, parte pendente | Ver detalhe na spec |
| `concluída` | Tudo verificado e entregue | — |
| `descontinuada` | Cancelada ou substituída | Não — verificar substituta |

## {Domínio 1 — ex: Autenticação & Acesso}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|
| {AUTH1} | `.claude/specs/{auth-login.md}` | `concluída` | {opcional} | — | {Login e autenticação} |
| {AUTH2} | `.claude/specs/{auth-roles.md}` | `em andamento` | {opcional} | `PROJ-123` | {Sistema de roles} |

## {Domínio 2 — ex: Pagamentos}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|
| {PAY1} | `.claude/specs/{stripe-checkout.md}` | `concluída` | {opcional} | `PROJ-456` | {Checkout e webhooks} |
| {PAY2} | `.claude/specs/{stripe-webhooks.md}` | `em andamento` | {opcional} | `PROJ-456` | {Webhooks e reconciliação} |

> **Nota:** Multiplas specs podem referenciar a mesma Fonte (ex: PAY1 e PAY2 ambos vem de PROJ-456). Isso e normal quando um card grande e quebrado em specs menores.

## {Domínio 3 — ex: Core / Funcionalidade Principal}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|
| {CORE1} | `.claude/specs/{feature-x.md}` | `rascunho` | {opcional} | — | {Feature X} |

## {Domínio 4 — ex: UI & UX}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|

## {Domínio 5 — ex: Segurança}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|

## {Domínio 6 — ex: Testes & Qualidade}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|

## {Domínio 7 — ex: Infraestrutura}

| ID | Spec | Status | Owner | Fonte | Resumo |
|---|---|---|---|---|---|

---

## Dependências entre specs

| Spec | Depende de | Motivo | Seção relevante |
|---|---|---|---|
| {ID} | {ID dependência} | {Por quê} | {Seção} |

### Regras de dependência

- Máximo 2 specs dependentes por tarefa
- Se detectar dependência circular, carregar apenas seção relevante de cada
- Dependência `rascunho` = perguntar antes de implementar

---

<!-- ====================================================================
     VARIANTE: SPECS EM FERRAMENTA EXTERNA (Notion, Confluence, Linear)
     Se as specs ficam numa ferramenta externa acessada via MCP,
     substitua as tabelas de domínio acima por esta variante.
     Remova este comentário e a seção "Variante: specs locais" acima.
     ==================================================================== -->

<!--
## {Domínio — ex: Autenticação & Acesso} (external)

| ID | Título na ferramenta | External ID | Status | Owner | Resumo |
|---|---|---|---|---|---|
| {AUTH1} | {Spec: Login Flow} | {page-id-ou-url} | `concluída` | {opcional} | {Login e autenticação} |

> **External ID:** identificador na ferramenta externa.
> - Notion: Page ID (parte após último `-` na URL)
> - Confluence: Page ID (numérico na URL)
> - Linear: Issue ID (ex: ENG-123)
>
> **Regras de acesso à ferramenta externa:**
> - Usar o External ID ou título exato para buscar. Nunca fazer search aberto no workspace.
> - Se a chamada falhar (timeout, permissão), avisar e continuar com o que já sabe. Não inventar requisitos.
> - O conteúdo da ferramenta externa é fonte de verdade. Se houver conflito com código, seguir a spec e sinalizar.
-->

---

## Manutenção deste índice

- **Nova spec criada:** adicionar linha no domínio correto
- **Spec concluída:** atualizar status para `concluída`, mover path para `done/`
- **Spec descontinuada:** atualizar status para `descontinuada`, adicionar nota sobre qual spec a substituiu
- **Spec removida:** remover linha
- **Mudança de domínio:** mover linha para domínio correto
- **Dependência adicionada:** atualizar tabela "Dependências entre specs" E seção "Dependências" dentro da spec
