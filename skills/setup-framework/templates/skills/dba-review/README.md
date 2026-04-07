<!-- framework-tag: v2.14.0 framework-file: skills/dba-review/README.md -->
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

<!-- Exemplo concreto — adaptar ou remover -->
<!-- PostgreSQL exemplo:
  - PKs: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
  - Timestamps: `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
  - Strings: `email VARCHAR(255) NOT NULL`, `bio TEXT`
  - Check: `status VARCHAR(20) NOT NULL CHECK (status IN ('active','suspended','deleted'))`
-->
<!-- MySQL exemplo:
  - PKs: `id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
  - Timestamps: `created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)`
  - Strings: `email VARCHAR(255) NOT NULL`, `bio LONGTEXT`
-->

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
<!-- Exemplo concreto — adaptar ou remover -->
<!-- Indice parcial PostgreSQL:
  CREATE INDEX CONCURRENTLY idx_users_email_active
    ON users(email)
    WHERE deleted_at IS NULL;
  -- Cobre apenas rows ativas, muito menor que indice full
-->
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

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Migration reversivel (Knex/Node.js):
  // 20240315_add_phone_to_users.js
  exports.up = (knex) =>
    knex.schema.alterTable('users', (t) => {
      t.string('phone', 20).nullable();
      t.index('phone', 'idx_users_phone');
    });
  exports.down = (knex) =>
    knex.schema.alterTable('users', (t) => {
      t.dropIndex('phone', 'idx_users_phone');
      t.dropColumn('phone');
    });
-->
<!-- Migration reversivel (Django/Python):
  # 0042_add_phone_to_users.py
  operations = [
      migrations.AddField('User', 'phone', models.CharField(max_length=20, null=True)),
      migrations.AddIndex('User', models.Index(fields=['phone'], name='idx_users_phone')),
  ]
  # Django gera down automaticamente para AddField/AddIndex
-->

- [ ] **Incremental** — nunca ALTER direto em producao, sempre via migration numerada
- [ ] **Idempotente** — usar `IF NOT EXISTS`, `ON CONFLICT DO NOTHING` quando possivel
- [ ] **Sem perda de dados** — ADD COLUMN com DEFAULT, nunca DROP COLUMN sem migration de dados
- [ ] **Schema de referencia atualizado** — apos criar migration, atualizar {schema.sql / equivalente}

### Queries no código

- [ ] **Prepared statements** — `$1, $2` / `?` em todas as queries, NUNCA concatenação de string
- [ ] **Transações com cleanup** — `try/catch/finally { client.release() }` ou equivalente
- [ ] **Pool exhaustion** — queries longas ou loops devem usar client do pool, não pool.query diretamente
<!-- Exemplo concreto — adaptar ou remover -->
<!-- EXPLAIN ANALYZE — output esperado para query otimizada:
  EXPLAIN ANALYZE SELECT u.id, u.email, COUNT(o.id) as order_count
    FROM users u
    JOIN orders o ON o.user_id = u.id
    WHERE u.status = 'active' AND o.created_at > '2024-01-01'
    GROUP BY u.id, u.email;

  -- BOM (usa indices):
  HashAggregate (cost=245.12..267.34 rows=890) (actual time=3.2..4.1 rows=847)
    -> Hash Join (cost=89.00..234.00 rows=890) (actual time=1.1..2.8 rows=847)
         -> Index Scan using idx_users_status on users u (actual time=0.02..0.5 rows=1200)
         -> Index Scan using idx_orders_user_created on orders o (actual time=0.03..1.2 rows=5600)
  Planning Time: 0.3 ms / Execution Time: 4.5 ms

  -- RUIM (Seq Scan em tabela grande = falta indice):
  Seq Scan on orders o (cost=0.00..125000.00 rows=500000) (actual time=0.01..890.00 rows=500000)
    Filter: (created_at > '2024-01-01')  -- Seq Scan aqui = precisa de indice em created_at
  Planning Time: 0.1 ms / Execution Time: 1240.0 ms
-->
- [ ] **EXPLAIN ANALYZE** — para queries complexas, verificar plano de execucao
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
