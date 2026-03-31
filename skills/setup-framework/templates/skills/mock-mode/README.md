<!-- framework-tag: v2.0.0 framework-file: skills/mock-mode/README.md -->
# Skill: Mock Mode — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ao adicionar nova integração externa, novo endpoint ou nova feature que depende de serviço externo.

## Quando usar

- Ao criar endpoint que chama serviço externo (pagamento, IA, email, SMS)
- Ao adicionar nova tabela ou dados que precisam de seed
- Ao modificar fluxo que depende de serviço externo
- Ao revisar se o mock mode cobre a plataforma toda

## Como funciona o mock mode

```
{ENV_VAR}=true  → backend simula serviços externos
```

{Definir o que o mock mode substitui e o que NÃO substitui.}

**Exemplo:**
> PostgreSQL é SEMPRE obrigatório — não existe DB stub. Mock mode substitui apenas chamadas a APIs externas (pagamento, email, IA).

## Setup mock mode

```bash
# 1. Banco precisa estar rodando + schema aplicado
{comando para setup do banco}

# 2. Seed dados de demo
{comando para seed — ex: node scripts/seed-demo.js}

# 3. Backend com mock mode
{ENV_VAR}=true {comando para iniciar backend}

# 4. Credenciais de teste
# {credenciais de teste para demo}
```

## Checklist de cobertura mock

### Toda nova integração externa DEVE ter mock

| Integração | Arquivo | Mock handler | Seed data |
|---|---|---|---|
| {Pagamento} | {payments.js} | `if (MOCK_MODE)` → {simula sucesso} | — |
| {Email} | {email-service.js} | `if (MOCK_MODE)` → {log + skip envio} | — |
| {IA/LLM} | {external-provider.js} | `if (MOCK_MODE)` → {resposta fixa} | — |
| {Auth externo} | {auth.js} | `if (MOCK_MODE)` → {aceita credencial fixa} | {contas seedadas} |

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

{Listar arquivos de dados mock/demo do projeto.}

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
