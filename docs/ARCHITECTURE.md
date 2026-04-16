<!-- framework-tag: v2.45.0 framework-file: docs/ARCHITECTURE.md -->
# Arquitetura — {NOME_DO_PROJETO}

> Decisões arquiteturais, integrações, e diagramas do sistema.
> Atualizar sempre que uma decisão for tomada ou uma integração for adicionada.
>
> **Diferença do PROJECT_CONTEXT.md:** lá é um resumo para qualquer LLM. Aqui é o detalhe técnico completo.

---

## Visão geral

```
{Diagrama de alto nível — adaptar ao projeto}

┌──────────┐     HTTPS      ┌──────────────┐     SQL      ┌──────────┐
│ Frontend │ ──────────────→ │   Backend    │ ───────────→ │ Database │
│ {React}  │                 │  {Express}   │              │ {Postgres}│
└──────────┘                 └──────────────┘              └──────────┘
                                    │
                              ┌─────┴─────┐
                              │           │
                         ┌────▼───┐ ┌─────▼────┐
                         │  {IA}  │ │{Payments}│
                         │{provid}│ │{gateway} │
                         └────────┘ └──────────┘
```

---

## Decisões arquiteturais

{Cada decisão no formato: título + contexto + decisão + consequências.}

### DA-001: {Título — ex: API key nunca no frontend}

**Contexto:** {Por que essa decisão foi necessária?}

**Decisão:** {O que foi decidido.}

**Consequências:**
- {Positiva: segurança das chaves garantida}
- {Negativa: toda chamada à IA tem latência extra (passa pelo backend)}
- {Trade-off: mais complexidade no backend}

---

### DA-002: {Título — ex: Dados sensíveis nunca persistidos}

**Contexto:** {O sistema processa dados X mas não deve armazená-los por compliance/regulação.}

**Decisão:** {Nenhuma tabela armazena dado Y. Apenas metadados de sessão são persistidos.}

**Consequências:**
- {Positiva: compliance com regulação de privacidade}
- {Positiva: superfície de ataque reduzida (vazamento de banco não expõe dados de usuário)}
- {Negativa: não é possível fazer replay/debug com dados reais}

---

### DA-003: {Título — ex: Ledger append-only para operações financeiras}

**Contexto:** {Precisa de auditabilidade em operações de crédito/pagamento.}

**Decisão:** {Tabela de movimentações nunca sofre UPDATE/DELETE. Saldo = SUM(amount).}

**Consequências:**
- {Positiva: trilha de auditoria completa — qualquer saldo pode ser recalculado}
- {Positiva: previne manipulação de saldo (não existe UPDATE SET balance)}
- {Negativa: correções exigem lançamento de estorno, não alteração do original}

---

{Adaptar: mais decisoes conforme surgem. Numerar sequencialmente.}

---

## Integrações externas

### {Integração 1 — ex: Provedor de IA}

| Propriedade | Valor |
|---|---|
| Serviço | {Provedor de IA} |
| Tipo | {API REST} |
| Auth | {API Key em header / OAuth / etc.} |
| Arquivo | {services/external-provider.js} |
| Mock mode | {Sim — resposta fixa quando MOCK_MODE=true} |

**Fluxo:**
```
Backend                              IA Provider
  │                                      │
  ├─ sanitize(input)                     │
  ├─ recordUsage() ← ANTES da chamada   │
  ├─ POST /v1/messages ────────────────→ │
  │                                      │
  │  ← response ─────────────────────── │
  ├─ sanitize(response)                  │
  └─ return to client                    │
```

**Pontos de atenção:**
- {API key em env var, nunca no código}
- {Timeout configurado: Xms}
- {Retry com backoff para erros 429/500}
- {Sanitização de input E output}

### {Integração 2 — ex: Gateway de pagamento}

| Propriedade | Valor |
|---|---|
| Serviço | {Gateway de pagamento} |
| Tipo | {Checkout redirect + Webhook} |
| Auth | {API Key (backend) + Webhook signature} |
| Arquivo | {routes/payments.js} |
| Mock mode | {Sim — provisiona direto sem gateway} |

**Fluxo de checkout:**
```
Frontend          Backend              Gateway
  │                  │                    │
  ├─ Seleciona plano │                    │
  ├─ POST /checkout ─▶                    │
  │                  ├─ Cria sessão ──────▶
  │                  │  ← checkout URL ───│
  │  ← redirect URL ─│                    │
  ├─ Redirect ───────────────────────────▶│
  │                  │    Pagamento        │
  │                  │  ← Webhook ────────│
  │                  ├─ Verifica assinatura│
  │                  ├─ Provisiona acesso  │
  │                  └─ 200 OK ──────────▶│
  │  ← Redirect de retorno               │
```

**Pontos de atenção:**
- {Webhook verifica assinatura HMAC antes de processar}
- {Raw body ANTES do JSON parser}
- {Idempotência via reference_id / session_id}
- {Compensação se provisioning falhar após pagamento}

### {Integração 3 — ex: Serviço de e-mail}

| Propriedade | Valor |
|---|---|
| Serviço | {Serviço de e-mail transacional} |
| Tipo | {API REST} |
| Arquivo | {services/email-service.js} |
| Mock mode | {Sim — log no console + grava em email_log} |

**Templates:**

| Template | Trigger | Variáveis |
|---|---|---|
| {welcome} | {Cadastro} | {name, email} |
| {otp} | {Login} | {code, expiry_minutes} |
| {receipt} | {Pagamento aprovado} | {plan, amount, receipt_url} |
| ... | ... | ... |

---

## Schema do banco (resumo)

{Resumo das tabelas — schema completo em `database/schema.sql`}

| Tabela | PK | Propósito | Append-only? |
|---|---|---|---|
| {users} | UUID | Contas de usuário | Não |
| {sessions} | UUID | Sessões de uso | Não |
| {credit_ledger} | BIGSERIAL | Movimentações financeiras | **Sim** |
| {audit_log} | BIGSERIAL | Log de ações admin | **Sim** |
| ... | ... | ... | ... |

**Regras:**
- Tabelas append-only NUNCA sofrem UPDATE/DELETE
- Schema completo em `database/schema.sql`
- Migrations em `database/migrations/`

---

## Ambientes

| Ambiente | URL | Banco | Integrações |
|---|---|---|---|
| Local (dev) | localhost:{porta} | {localhost / Docker} | {Mock mode} |
| Staging | {url} | {staging DB} | {Sandbox dos serviços} |
| Produção | {url} | {prod DB} | {Serviços reais} |

---

## Variáveis de ambiente

{Adaptar: env vars necessarias — sem valores reais.}

| Variável | Obrigatória | Descrição |
|---|---|---|
| `DATABASE_URL` | ✅ | Connection string do PostgreSQL |
| `JWT_SECRET` | ✅ | Secret para assinar JWTs (256+ bits) |
| `{AI_API_KEY}` | ✅ | Chave da API de IA |
| `{PAYMENT_SECRET_KEY}` | ✅ | Chave do gateway de pagamento |
| `{PAYMENT_WEBHOOK_SECRET}` | ✅ | Secret para validar webhooks |
| `{EMAIL_API_KEY}` | ✅ | Chave do serviço de e-mail |
| `{BASE_URL}` | ✅ | URL base da aplicação (para links em emails) |
| `MOCK_MODE` | ❌ | `true` para simular integrações externas |
| `NODE_ENV` | ❌ | `production` / `development` |

**Regra:** em produção, toda variável obrigatória DEVE estar definida. O servidor deve falhar ao iniciar se faltar qualquer uma (fail-fast).
