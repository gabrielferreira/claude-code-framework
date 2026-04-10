<!-- framework-tag: v2.37.3 framework-file: PRDS_INDEX.template.md -->
# PRDS_INDEX — {NOME_DO_PROJETO}

> Índice de todos os PRDs (Product Requirements Documents) do projeto.
> Consultar ANTES de criar specs técnicas para verificar se já existe análise de produto.
> Criar PRD com `/prd {ID} {Titulo}`.

## Como usar

1. Verificar se já existe PRD para o domínio/problema
2. Se existir, criar specs vinculadas ao PRD
3. Acompanhar status: PRD `aprovado` → specs podem ser criadas
4. PRD `concluido` = todas as specs vinculadas entregues

## PRDs ativos

| PRD ID | Titulo | Status | Specs vinculadas | Resumo |
|--------|--------|--------|------------------|--------|
| *{SUPORTE}* | *{Tempo de resposta do suporte alto}* | `aprovado` | *SUP1, SUP2* | *{Reduzir tempo medio de resposta de 48h para 4h}* |

## PRDs concluidos

| PRD ID | Titulo | Data conclusao | Specs geradas |
|--------|--------|---------------|---------------|
| *{AUTH}* | *{Autenticacao unificada}* | *2025-03-15* | *AUTH1, AUTH2, AUTH3* |

---

<!-- ====================================================================
     VARIANTE: PRDs EM FERRAMENTA EXTERNA (Jira, Notion, Confluence)
     Se os PRDs ficam numa ferramenta externa, substitua as tabelas acima.
     ==================================================================== -->

<!--
## PRDs ativos (external)

| PRD ID | Titulo | External Ref | Status | Specs vinculadas | Resumo |
|--------|--------|-------------|--------|------------------|--------|
| {AUTH} | {Autenticacao unificada} | [Jira](url) | `aprovado` | AUTH1, AUTH2 | {resumo} |

> **External Ref:** link para o PRD na ferramenta externa (Jira epic, Notion page, Confluence page).
> A ferramenta externa é fonte de verdade para o conteúdo do PRD.
> Este índice mantém apenas referências para rastreabilidade local.
-->

---

## Manutenção deste índice

- **Novo PRD criado:** adicionar linha em "PRDs ativos"
- **PRD aprovado:** atualizar status para `aprovado` — specs podem ser criadas
- **Spec vinculada:** adicionar ID da spec na coluna "Specs vinculadas"
- **PRD concluído:** mover para "PRDs concluidos" com data e lista de specs
- **PRD descontinuado:** atualizar status para `descontinuado — ver {SUBSTITUTO}`
