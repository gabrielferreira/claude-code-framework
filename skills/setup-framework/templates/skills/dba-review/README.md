# Skill: DBA Review — {NOME_DO_PROJETO}

> Executar quando criar ou modificar tabelas, migrations, queries ou índices.

## Quando ativar

- Criar ou alterar tabelas (`CREATE TABLE`, `ALTER TABLE`)
- Criar migrations
- Adicionar queries com `JOIN`, `WHERE` em colunas sem índice
- Adicionar ou remover índices
- Alterar constraints (`CHECK`, `UNIQUE`, `FK`)

## Checklist obrigatório

### Schema e tipos

{Adaptar ao banco: PostgreSQL, MySQL, SQLite, etc.}

- [ ] **PKs consistentes** — {UUID `DEFAULT gen_random_uuid()` / BIGSERIAL / etc.} em todas as tabelas
- [ ] **Timestamps com timezone** — {TIMESTAMPTZ / DATETIME / etc.} — nunca sem timezone
- [ ] **Strings com limite** — {VARCHAR(N)} para campos estruturados (email, nome), {TEXT} para conteúdo livre
- [ ] **CHECK constraints** — valores permitidos explícitos para colunas de status/tipo
- [ ] **NOT NULL** — campos obrigatórios têm NOT NULL, opcionais não
- [ ] **Defaults** — valores padrão onde faz sentido (created_at, status inicial)

### Índices

- [ ] **UNIQUE cria índice implícito** — não criar INDEX separado para colunas com UNIQUE constraint
- [ ] **Queries WHERE/JOIN/ORDER BY** — coluna de frequência média/alta? Tem índice?
- [ ] **Índices parciais** — usar `WHERE condition` quando possível (ex: `WHERE status = 'active'`)
- [ ] **Índices compostos** — se query filtra por 2+ colunas, considerar índice composto em vez de 2 simples
- [ ] **Não indexar tabelas pequenas** — tabelas com <100 rows não precisam de índice além do PK

### Constraints e integridade

- [ ] **FK para toda referência** — `user_id` referencia `users(id)`, etc.
- [ ] **ON DELETE** — definir comportamento: CASCADE, RESTRICT, ou SET NULL
- [ ] **UNIQUE onde necessário** — idempotência (reference_id), unicidade de negócio (email, code)
- [ ] **CHECK para enums** — `status IN ('a','b','c')` em vez de confiar no código
- [ ] **Tabelas append-only** — {ledger, audit_log, event_log} NUNCA têm UPDATE/DELETE

### Migrations

- [ ] **Incremental** — nunca ALTER direto em produção, sempre via migration numerada
- [ ] **Idempotente** — usar `IF NOT EXISTS`, `ON CONFLICT DO NOTHING` quando possível
- [ ] **Sem perda de dados** — ADD COLUMN com DEFAULT, nunca DROP COLUMN sem migration de dados
- [ ] **Schema de referência atualizado** — após criar migration, atualizar {schema.sql / equivalente}

### Queries no código

- [ ] **Prepared statements** — `$1, $2` / `?` em todas as queries, NUNCA concatenação de string
- [ ] **Transações com cleanup** — `try/catch/finally { client.release() }` ou equivalente
- [ ] **Pool exhaustion** — queries longas ou loops devem usar client do pool, não pool.query diretamente
- [ ] **EXPLAIN ANALYZE** — para queries complexas, verificar plano de execução
- [ ] **SELECT com colunas explícitas** — NUNCA `SELECT *` em código de produção

### Performance

- [ ] **Paginação** — `LIMIT/OFFSET` ou cursor-based em queries que retornam listas
- [ ] **Aggregations** — `COUNT`, `SUM` em tabelas grandes devem ter índice na coluna do WHERE
- [ ] **N+1** — evitar loops que fazem 1 query por item; preferir JOINs ou batch queries
- [ ] **Connection pool** — configurado com timeout e max connections adequados

### Segurança

- [ ] **SQL injection** — verificar visualmente em queries dinâmicas (nomes de tabela, ORDER BY)
- [ ] **Dados sensíveis** — {senhas, tokens, PII} armazenados como hash ou criptografados
- [ ] **Audit trail** — operações privilegiadas gravam em tabela de auditoria

## Schema de referência

`{database/schema.sql}` — DDL completo com índices e constraints.

## Tabelas do projeto

{Manter atualizado conforme o schema cresce.}

| Tabela | PK | Propósito | Append-only? |
|---|---|---|---|
| `{users}` | {UUID} | {Usuários da plataforma} | Não |
| `{sessions}` | {UUID} | {Sessões de uso} | Não |
| `{audit_log}` | {BIGSERIAL} | {Log de ações admin} | **Sim** |
| ... | ... | ... | ... |

## Regras de ouro

1. **Schema é contrato.** Constraints no banco são a última linha de defesa — não confiar só no código.
2. **Migration antes de ALTER.** Nunca rodar DDL direto em produção.
3. **Índice é investimento.** Só criar onde a query é frequente (>10 req/min) ou lenta (>100ms).
4. **Append-only é sagrado.** Tabelas de ledger/audit NUNCA sofrem UPDATE ou DELETE.
