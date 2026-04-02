<!-- framework-tag: v2.7.0 framework-file: skills/security-review/README.md -->
# Skill: Security Review

> Use esta skill ao implementar novas features, endpoints ou modificar lógica existente.
> Rode este checklist ANTES de commitar código que toca em rotas, middleware ou services.
>
> **Diferença do agent `security-audit`:** o agent é auditoria read-only do sistema todo.
> Esta skill é checklist para quem está **escrevendo** código — guidance pré-commit.

## Regras absolutas do projeto

{Adaptar: regras inviolaveis de seguranca do projeto. Exemplos comuns:}

1. **Dados sensíveis do usuário NUNCA persistidos em texto claro.** {Adaptar: quais dados sensiveis.}
2. **Prepared statements em toda query SQL.** Zero concatenação de input do usuário em SQL.
3. **Todo input sanitizado antes de processar.** {Função de sanitização do projeto.}
4. **Secrets em variáveis de ambiente.** Nunca hardcodar API keys, JWT secrets ou webhook secrets.

## Checklist por tipo de mudança

### Nova rota/endpoint

- [ ] Rota usa wrapper async (ex: `asyncHandler`) — frameworks como Express 4 não capturam rejected promises sem wrapper
- [ ] Auth middleware aplicado — endpoints sem auth precisam de justificativa documentada
- [ ] Params validados por formato antes de uso: IDs → UUID/formato esperado; outros → regex
- [ ] Body fields validados (tipo, range, obrigatoriedade)
- [ ] Queries SQL usam prepared statements ($1, $2, ?, etc.) — NUNCA concatenação
- [ ] `SELECT` lista colunas explícitas — NUNCA `SELECT *`
- [ ] Colunas frequentes em `WHERE`/`JOIN`/`ORDER BY` têm índice
- [ ] Campos sensíveis removidos da resposta
- [ ] Rate limit aplicado (global ou específico)

### Endpoint que modifica dados

- [ ] Ownership check: `WHERE user_id = $1` com ID do token de auth, não do body
- [ ] Operação admin registrada em audit log
- [ ] Idempotência: `reference_id` ou `ON CONFLICT` para evitar double-processing
- [ ] Transaction para operações multi-tabela
- [ ] Operação de débito/crédito executa ANTES da ação (compensar no catch se falhar)

### Endpoint de autenticação

- [ ] Respostas uniformes — nunca revelar se e-mail/usuário existe (anti-enumeração)
- [ ] Comparações de hash/OTP/token usam comparação timing-safe (`crypto.timingSafeEqual` ou equivalente)
- [ ] Rate limit específico em login/OTP
- [ ] Refresh token rotacionado (revoga antigo + emite novo)
- [ ] Secret de assinatura: fallback inseguro só em development; produção lança erro

### Race conditions (TOCTOU)

- [ ] Operações onde validação e mutação são separadas: usar transaction ou INSERT pendente com UNIQUE
- [ ] `SELECT ... FOR UPDATE` quando precisa ler e modificar no mesmo fluxo
- [ ] Nunca confiar em validação feita em request anterior (re-validar no webhook/callback)
- [ ] Operações concorrentes com recurso limitado: incremento atômico (`UPDATE ... WHERE count < max RETURNING`)
- [ ] Double-submit: `UNIQUE` constraint em campo de referência

### Integração com serviço externo (webhooks, APIs, IA)

- [ ] API key em variável de ambiente, nunca no código
- [ ] Webhook verifica assinatura (HMAC, constructEvent, SNS signature, etc.)
- [ ] Webhook endpoint recebe raw body (antes do JSON parser global)
- [ ] **Webhook metadata validada por formato** — todo campo de metadata validado como UUID/whitelist/regex ANTES de usar em query. Metadata é input externo.
- [ ] Idempotência via `reference_id` ou equivalente
- [ ] Erros de serviço externo não expõem detalhes internos ao cliente
- [ ] **Respostas de serviço externo com limite de tamanho** — arrays truncados com `slice(0, MAX)` antes de processar. Serviço pode retornar payloads enormes.

### Redirect e URLs

- [ ] URLs de redirect validadas contra allowlist hardcoded
- [ ] Retornar erro se base URL não está definida (env var faltando)
- [ ] Parâmetros de domínio/path aceitam apenas valores conhecidos

### Infraestrutura

- [ ] `trust proxy` configurado adequadamente quando atrás de reverse proxy
- [ ] Rate limit funciona com IP real do cliente, não IP do proxy
- [ ] Zero URLs hardcoded — todas vêm de variáveis de ambiente

### Frontend

- [ ] Input sanitizado antes de enviar ao backend
- [ ] URLs de upload validadas (magic bytes, extensão, tamanho)
- [ ] Nenhum dado sensível em `localStorage` ou `sessionStorage`
- [ ] `escapeHtml()` em qualquer valor dinâmico renderizado em HTML
- [ ] Zero URLs/domínios hardcoded — usar variáveis de ambiente do build
- [ ] **Todo fetch() tem timeout** — AbortController com timeout adequado (15s API, 30s operações longas). Fetch sem timeout = tela travada
- [ ] **Botão/ação async tem error handling** — async sem try-catch = UI irresponsiva
- [ ] **Effect/watcher dependencies nunca são expressões** — `[x > 3]` é bug em React/Vue (framework vê boolean, não variável)
- [ ] **Timers com cleanup** — setTimeout/setInterval precisam de cleanup no unmount
- [ ] **Arquivos/dados sensíveis limpos da memória após uso**

## Padrões de sanitização

{Adaptar com as funções de sanitização do projeto:}

```
// Para strings de input
sanitize(inputString)       // remove tags, control chars, limita tamanho

// Para números
sanitizeNumber(inputNumber) // NaN → 0, limita range

// Para HTML em e-mails ou relatórios
escapeHtml(string)          // escapa <, >, &, ", '

// Para comparações timing-safe
timingSafeCompare(a, b)     // evita timing attacks
```

## Campos proibidos em respostas

{Adaptar: campos que NUNCA devem aparecer em respostas JSON:}
- `password_hash`
- `token_hash`
- `api_key`
- `secret`
- {outros campos sensíveis do projeto}

## Quando escalar

Se a mudança envolve:
- Nova tabela que pode armazenar dados sensíveis → **PARE e revise as regras absolutas**
- Novo serviço externo recebendo dados de usuário → **Verificar o que está sendo enviado**
- Mudança em regras de negócio com impacto financeiro → **Conferir em TODOS os lugares**
- Novo role/permissão → **Atualizar documentação de acesso**
