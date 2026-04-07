<!-- framework-tag: v2.14.0 framework-file: skills/mock-mode/README.md -->
# Skill: Mock Mode — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ao adicionar nova integração externa, novo endpoint ou nova feature que depende de serviço externo.

## Quando usar

- Ao criar endpoint que chama serviço externo (pagamento, IA, email, SMS)
- Ao adicionar nova tabela ou dados que precisam de seed
- Ao modificar fluxo que depende de serviço externo
- Ao revisar se o mock mode cobre a plataforma toda

## Como funciona o mock mode

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Variavel de ambiente tipica:
  MOCK_MODE=true    # Node.js / Express
  MOCK_SERVICES=1   # Django / Flask
  RAILS_MOCK=true   # Ruby on Rails
-->

```
{ENV_VAR}=true  → backend simula servicos externos
```

<!-- Exemplo concreto — adaptar ou remover -->
<!-- O que mock mode substitui vs NAO substitui:
  SUBSTITUI (APIs externas):
    - Stripe/pagamentos  -> resposta fixa de sucesso/falha
    - SendGrid/email     -> log no console, nao envia
    - OpenAI/LLM         -> resposta hardcoded
    - Twilio/SMS         -> log no console, nao envia
    - S3/upload          -> salva em /tmp local

  NAO SUBSTITUI (infra local obrigatoria):
    - PostgreSQL/MySQL   -> banco real, sempre
    - Redis              -> real (ou use fakeredis em dev)
    - Migrations         -> rodam normalmente
-->

{Adaptar: o que o mock mode substitui e o que NAO substitui.}

**Exemplo:**
> PostgreSQL é SEMPRE obrigatório — não existe DB stub. Mock mode substitui apenas chamadas a APIs externas (pagamento, email, IA).

## Setup mock mode

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Setup completo para projeto Node.js + PostgreSQL:
```bash
# 1. Banco
docker compose up -d postgres
npx knex migrate:latest

# 2. Seed
node scripts/seed-demo.js

# 3. Backend com mock mode
MOCK_MODE=true STRIPE_API_KEY=sk_test_fake npm run dev

# 4. Credenciais de teste
# Email: demo@example.com / Senha: demo123
# Admin: admin@example.com / Senha: admin123
# Cartao mock Stripe: 4242 4242 4242 4242 (qualquer data/cvv)
```
-->
<!-- Setup completo para projeto Django + PostgreSQL:
```bash
# 1. Banco
docker compose up -d postgres
python manage.py migrate

# 2. Seed
python manage.py loaddata fixtures/demo.json

# 3. Backend com mock mode
MOCK_SERVICES=1 python manage.py runserver

# 4. Credenciais de teste
# Email: demo@example.com / Senha: demo123
```
-->

```bash
# 1. Banco precisa estar rodando + schema aplicado
{comando para setup do banco}

# 2. Seed dados de demo
{comando para seed -- ex: node scripts/seed-demo.js}

# 3. Backend com mock mode
{ENV_VAR}=true {comando para iniciar backend}

# 4. Credenciais de teste
# {credenciais de teste para demo}
```

## Checklist de cobertura mock

### Toda nova integração externa DEVE ter mock

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Tabela de exemplo para SaaS com pagamento + email + IA:
| Integracao   | Arquivo              | Mock handler                                    | Seed data         |
|---|---|---|---|
| Stripe       | services/stripe.js   | `if (MOCK_MODE)` -> retorna `{id: "pi_mock_123", status: "succeeded"}` | — |
| SendGrid     | services/email.js    | `if (MOCK_MODE)` -> `console.log("[MOCK EMAIL]", {to, subject})` e retorna ok | — |
| OpenAI       | services/llm.js      | `if (MOCK_MODE)` -> retorna `{content: "Mock AI response", tokens: 10}` | — |
| Google OAuth | services/auth.js     | `if (MOCK_MODE)` -> aceita `token=mock_token_123` | `fixtures/users.json` |
-->

<!-- Exemplo de mock handler em Node.js:
  // services/stripe.js
  async function createPaymentIntent(amount, currency) {
    if (process.env.MOCK_MODE === 'true') {
      return {
        id: `pi_mock_${Date.now()}`,
        status: 'succeeded',
        amount,
        currency,
        client_secret: 'mock_secret_123',
      };
    }
    // Chamada real ao Stripe
    return stripe.paymentIntents.create({ amount, currency });
  }
-->

<!-- Exemplo de mock handler em Python/Django:
  # services/email_service.py
  def send_email(to, subject, body):
      if settings.MOCK_MODE:
          logger.info(f"[MOCK EMAIL] to={to} subject={subject}")
          return {"status": "mocked", "message_id": f"mock_{uuid4()}"}
      # Chamada real ao SendGrid
      return sg.send(Mail(to=to, subject=subject, html_content=body))
-->

| Integracao | Arquivo | Mock handler | Seed data |
|---|---|---|---|
| {Pagamento} | {payments.js} | `if (MOCK_MODE)` -> {simula sucesso} | -- |
| {Email} | {email-service.js} | `if (MOCK_MODE)` -> {log + skip envio} | -- |
| {IA/LLM} | {external-provider.js} | `if (MOCK_MODE)` -> {resposta fixa} | -- |
| {Auth externo} | {auth.js} | `if (MOCK_MODE)` -> {aceita credencial fixa} | {contas seedadas} |

### Ao adicionar nova integração

- [ ] Adicionou `if (MOCK_MODE)` ou equivalente no ponto de chamada externa?
- [ ] O mock retorna dados **no mesmo formato** que a integração real?
- [ ] O mock provisiona os **efeitos colaterais** necessários? (ex: checkout mock deve criar sessão)
- [ ] Se precisa de seed data → adicionou no script de seed?
- [ ] Frontend funciona com a resposta mock? (testar fluxo completo)
- [ ] Tabela acima atualizada com a nova integração?

### Ao adicionar nova tabela

- [ ] Script de seed insere dados de exemplo na nova tabela?
- [ ] Rotas que usam a nova tabela funcionam com dados seedados?

### Ao adicionar novo endpoint

- [ ] Endpoint funciona com dados seedados?
- [ ] Se endpoint chama serviço externo → tem mock handler?
- [ ] Se endpoint depende de fluxo anterior (ex: pagamento) → fluxo anterior está mockado?

## Fixtures

{Adaptar: arquivos de dados mock/demo do projeto.}

| Arquivo | Conteúdo | Usado por |
|---|---|---|
| {`fixtures/demo/accounts.json`} | {Contas de teste} | {seed script} |
| {`fixtures/demo/sample-data.json`} | {Dados fictícios} | {Frontend pre-fill} |
| ... | ... | ... |

## Verificação de integridade do mock

```bash
# Rodar periodicamente para verificar que mock mode funciona end-to-end

# 1. Seed
{comando seed}

# 2. Start mock mode
{comando start com MOCK_MODE}

# 3. Testar fluxo principal
{curl ou script de smoke test}
```

## Regras

1. **Toda integração externa tem mock handler.** Se não tem mock, não está pronto.
2. **Mock retorna o mesmo formato.** Se o shape muda, o frontend quebra.
3. **Seed cobre todos os fluxos.** Se o seed não cobre, o fluxo quebra.
4. **Mock NÃO substitui banco.** PostgreSQL (ou equivalente) é sempre necessário.
5. **Credenciais de mock são fixas e conhecidas.** Documentar aqui e no README.
