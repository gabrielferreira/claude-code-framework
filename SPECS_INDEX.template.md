<!-- framework-tag: v2.49.2 framework-file: SPECS_INDEX.template.md -->
# SPECS_INDEX — {NOME_DO_PROJETO}

> Indice de specs **ativas** do projeto. Consultar ANTES de implementar qualquer item.
> Specs concluidas e descontinuadas ficam em `SPECS_INDEX_ARCHIVE.md`.
> Ao criar spec nova: adicionar entrada aqui no dominio correto.

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
     VARIANTE: MONOREPO (com coluna Sub-projeto)
     Se o projeto é monorepo, adicionar coluna "Sub-projeto" entre Owner
     e Fonte em todas as tabelas de domínio. O `/spec` faz isso
     automaticamente ao detectar `## Monorepo` no CLAUDE.md.
     ==================================================================== -->

<!--
## {Domínio — ex: Core} (monorepo)

| ID | Spec | Status | Owner | Sub-projeto | Fonte | Resumo |
|---|---|---|---|---|---|---|
| {AUTH1} | `.claude/specs/{auth-login.md}` | `concluída` | {opcional} | backend | — | {Login e autenticação} |
| {AUTH2} | `backend/.claude/specs/{auth-roles.md}` | `em andamento` | {opcional} | backend | `PROJ-123` | {Sistema de roles} |
| {PAY1} | `.claude/specs/{checkout.md}` | `rascunho` | {opcional} | frontend | — | {Checkout flow} |
| {INFRA1} | `.claude/specs/{ci-pipeline.md}` | `aprovada` | {opcional} | root | — | {Pipeline de CI} |

> **Sub-projeto:** indica qual sub-projeto do monorepo é responsável pela spec.
> Usar `root` para specs de infraestrutura, CI, ou cross-cutting.
> O path da spec depende do modelo de distribuição:
> - Centralizado: `.claude/specs/{id}.md` (todas na raiz)
> - Distribuído: `{subproject}/.claude/specs/{id}.md` (cada sub-projeto tem as suas)
-->

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

- **Nova spec criada:** adicionar linha no dominio correto
- **Spec concluida:** **mover entrada para `SPECS_INDEX_ARCHIVE.md`** (secao Concluidas), atualizar path para `done/`
- **Spec descontinuada:** **mover entrada para `SPECS_INDEX_ARCHIVE.md`** (secao Descontinuadas), adicionar nota sobre qual spec a substituiu
- **Spec removida:** remover linha
- **Mudanca de dominio:** mover linha para dominio correto
- **Dependencia adicionada:** atualizar tabela "Dependencias entre specs" E secao "Dependencias" dentro da spec
