# SPECS_INDEX — {NOME_DO_PROJETO}

> Índice de todas as specs do projeto. Consultar ANTES de implementar qualquer item.
> Ao criar spec nova: adicionar entrada aqui no domínio correto.

## Como usar

1. Identificar o domínio da mudança
2. Localizar a spec pelo ID ou palavras-chave
3. Abrir APENAS a spec identificada
4. Se status é `rascunho` — perguntar antes de implementar

## {Domínio 1 — ex: Autenticação & Acesso}

| ID | Spec | Status | Resumo |
|---|---|---|---|
| {AUTH1} | `.claude/specs/{auth-login.md}` | `concluída` | {Login e OTP} |
| {AUTH2} | `.claude/specs/{auth-roles.md}` | `em andamento` | {Sistema de roles} |

## {Domínio 2 — ex: Pagamentos}

| ID | Spec | Status | Resumo |
|---|---|---|---|
| {PAY1} | `.claude/specs/{stripe-checkout.md}` | `concluída` | {Checkout e webhooks} |

## {Domínio 3 — ex: Core / Funcionalidade Principal}

| ID | Spec | Status | Resumo |
|---|---|---|---|
| {CORE1} | `.claude/specs/{feature-x.md}` | `rascunho` | {Feature X} |

## {Domínio 4 — ex: UI & UX}

| ID | Spec | Status | Resumo |
|---|---|---|---|

## {Domínio 5 — ex: Segurança}

| ID | Spec | Status | Resumo |
|---|---|---|---|

## {Domínio 6 — ex: Testes & Qualidade}

| ID | Spec | Status | Resumo |
|---|---|---|---|

## {Domínio 7 — ex: Infraestrutura}

| ID | Spec | Status | Resumo |
|---|---|---|---|

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

## Manutenção deste índice

- **Nova spec criada:** adicionar linha no domínio correto
- **Spec concluída:** atualizar status para `concluída`, mover path para `done/`
- **Spec removida:** remover linha
- **Mudança de domínio:** mover linha para domínio correto
