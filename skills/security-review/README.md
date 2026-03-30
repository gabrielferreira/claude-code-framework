# Skill: Security Review — {NOME_DO_PROJETO}

> Use esta skill ao implementar novas features, endpoints, comandos ou modificar lógica existente.
> Rode este checklist ANTES de commitar código que toca em rotas, middleware, services, CLI handlers ou módulos de infra.

## Regras absolutas do projeto

{Listar regras de segurança invioláveis — adaptar ao domínio.}

1. **{Regra 1 — ex: Dados sensíveis NUNCA persistidos.}**
2. **{Regra 2 — ex: Prepared statements em toda query SQL.}**
3. **{Regra 3 — ex: Todo input sanitizado antes de processar.}**
4. **{Regra 4 — ex: Secrets em variáveis de ambiente, nunca no código.}**

---

## Nota para projetos não-web

O OWASP Top 10 abaixo é focado em aplicações web. Para outros tipos de projeto, adaptar:

| Tipo de projeto | Preocupações principais |
|---|---|
| **CLI / Tool** | Input injection (args, stdin, env vars), path traversal, privilege escalation, secrets em logs/history |
| **Mobile** | Armazenamento inseguro (keychain/keystore), certificate pinning, deep link hijacking, dados em background snapshot |
| **Infra / IaC** | State file com secrets, blast radius excessivo, IAM over-permissive, drift de segurança, módulos não auditados |
| **Library** | Supply-chain (dependências comprometidas), API surface expondo internals, prototype pollution, regex DoS |
| **Desktop** | Auto-update sem verificação de assinatura, IPC inseguro, file system access sem sandbox |

As regras absolutas (acima) e os checks de A01-A10 se aplicam a todos — apenas os exemplos mudam por tipo.

---

## OWASP Top 10 — checklist prático

Os 10 riscos mais comuns em aplicações web. Cada item tem o que verificar no código. Para projetos não-web, ver tabela acima.

### A01: Broken Access Control

**O problema:** usuário acessa recurso que não deveria (outro usuário, admin sem permissão).

- [ ] Todo endpoint tem auth middleware explícito — se é público, justificativa documentada no código
- [ ] Ownership check: `WHERE account_id = $1` com ID vindo do JWT/session, NUNCA do body/query
- [ ] Recursos de outro usuário retornam 404 (não 403) — anti-enumeração
- [ ] Endpoints admin verificam role/permissão, não só "está logado"
- [ ] IDs sequenciais (1, 2, 3...) expostos na URL permitem IDOR — preferir UUIDs
- [ ] Uploads validam tipo/tamanho e não permitem path traversal (`../../etc/passwd`)
- [ ] CORS configurado com allowlist explícita, não `*`

```javascript
// ❌ IDOR — atacante troca o ID na URL e acessa dados de outro usuário
router.get("/users/:id/data", auth, async (req, res) => {
  const data = await db.query("SELECT * FROM data WHERE user_id = $1", [req.params.id]);
  // ...
});

// ✅ Ownership enforced — ID vem do token, não da URL
router.get("/my/data", auth, async (req, res) => {
  const data = await db.query("SELECT col1, col2 FROM data WHERE user_id = $1", [req.user.id]);
  // ...
});
```

### A02: Cryptographic Failures

**O problema:** dados sensíveis expostos por criptografia fraca ou ausente.

- [ ] Senhas armazenadas com bcrypt/scrypt/argon2 — NUNCA MD5/SHA1/plaintext
- [ ] HTTPS obrigatório em produção (redirect HTTP -> HTTPS)
- [ ] Cookies com flags `Secure`, `HttpOnly`, `SameSite=Strict`
- [ ] JWT secrets com entropia alta (256+ bits) — NUNCA "secret", "123", nome do projeto
- [ ] Secrets de dev (`dev-secret`, `test-key`) NUNCA funcionam em produção — fail hard
- [ ] Dados sensíveis em trânsito sempre criptografados (TLS)
- [ ] Dados sensíveis em repouso criptografados se regulação exigir

```javascript
// ❌ Secret fraco — adivinhável
const JWT_SECRET = process.env.JWT_SECRET || "secret";

// ✅ Secret forte com fail em produção
const JWT_SECRET = process.env.JWT_SECRET || (
  process.env.NODE_ENV === "production"
    ? (() => { throw new Error("JWT_SECRET obrigatório em produção"); })()
    : "dev-secret-only-for-local"
);
```

### A03: Injection

**O problema:** input do usuário executado como código (SQL, NoSQL, OS, LDAP).

- [ ] Queries SQL usam prepared statements (`$1, $2`) — NUNCA concatenação
- [ ] `SELECT` com colunas explícitas — NUNCA `SELECT *`
- [ ] Nomes de tabela/coluna dinâmicos validados contra allowlist (não parametrizáveis)
- [ ] Inputs de usuário sanitizados antes de uso (strip tags, control chars, limitar tamanho)
- [ ] Dados do usuário em prompts de IA isolados em delimitadores (`<user_data>...</user_data>`)
- [ ] Nenhum `eval()`, `Function()`, ou template literal com input do usuário
- [ ] Comandos OS (`exec`, `spawn`) NUNCA recebem input do usuário sem escaping

**JavaScript:**
```javascript
// ❌ SQL Injection
db.query(`SELECT * FROM users WHERE email = '${req.body.email}'`);

// ✅ Prepared statement
db.query("SELECT id, email FROM users WHERE email = $1", [sanitize(req.body.email)]);
```

**Go:**
```go
// ❌ SQL Injection
db.Query("SELECT * FROM users WHERE email = '" + email + "'")

// ✅ Prepared statement
db.QueryRow("SELECT id, email FROM users WHERE email = $1", sanitize(email))
```

```javascript
// ❌ Prompt injection — dados misturados com instruções
const prompt = `Analise: ${userData}`;

// ✅ Dados isolados em delimitadores
const prompt = `Analise os dados abaixo.\n<user_data>\n${userData}\n</user_data>`;
```

### A04: Insecure Design

**O problema:** falhas de arquitetura, não de implementação.

- [ ] Rate limit em endpoints de autenticação (login, signup, reset password, verify code)
- [ ] Rate limit em endpoints públicos (busca, validação, API aberta)
- [ ] Bloqueio progressivo após falhas de auth (3, 5, 10 tentativas -> delay crescente)
- [ ] Fluxos financeiros validam server-side — frontend é UX, backend é verdade
- [ ] Operações sensíveis exigem re-autenticação (mudar email, deletar conta)
- [ ] Limites de negócio enforced no backend (max items, max size, max calls)
- [ ] Feature flags para funcionalidades em rollout parcial

### A05: Security Misconfiguration

**O problema:** configurações default inseguras ou exposição de informação.

- [ ] Headers de segurança configurados (Helmet.js ou equivalente)
- [ ] Stack traces NUNCA expostos em produção — erros genéricos para o cliente
- [ ] Listagem de diretórios desabilitada no web server
- [ ] Endpoints de debug/admin protegidos ou removidos em produção
- [ ] Variáveis de ambiente documentadas — todas as obrigatórias validadas no startup
- [ ] `.env`, `credentials.json`, `*.pem` no `.gitignore`
- [ ] Docker images sem packages desnecessários
- [ ] CORS, CSP, X-Frame-Options configurados adequadamente

```javascript
// ❌ Stack trace em produção
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message, stack: err.stack });
});

// ✅ Erro genérico para o cliente, detalhe nos logs
app.use((err, req, res, next) => {
  console.error("[ERROR]", { path: req.path, error: err.message });
  res.status(500).json({ error: "internal_error", message: "Erro interno. Tente novamente." });
});
```

### A06: Vulnerable and Outdated Components

**O problema:** dependências com vulnerabilidades conhecidas.

- [ ] `npm audit` (ou equivalente) sem vulnerabilidades críticas/altas
- [ ] Dependências atualizadas periodicamente (Dependabot, Renovate, ou manual)
- [ ] Lock file (`package-lock.json`, `yarn.lock`) commitado — builds reproduzíveis
- [ ] Pacotes abandonados (>2 anos sem update) avaliados para substituição
- [ ] Runtime (Node, Python, etc.) em versão LTS com suporte ativo

### A07: Identification and Authentication Failures

**O problema:** falhas no fluxo de autenticação que permitem impersonation.

- [ ] Respostas de auth uniformes — "credenciais inválidas" sem revelar qual campo errou
- [ ] Comparações de secrets usam timing-safe (`crypto.timingSafeEqual`)
- [ ] Tokens JWT com expiração curta (15-30min access, 7-30d refresh)
- [ ] Refresh tokens rotacionados a cada uso (revoga antigo + emite novo)
- [ ] Session fixation prevenido (novo session ID após login)
- [ ] Força de senha validada (ou usar passwordless/MFA)
- [ ] Logout invalida tokens server-side (não só no client)

**JavaScript:**
```javascript
// ❌ Timing attack — comparação curto-circuita no primeiro byte diferente
if (userToken === storedToken) { grant(); }

// ✅ Timing-safe — tempo constante independente de onde difere
const a = Buffer.from(userToken);
const b = Buffer.from(storedToken);
if (a.length === b.length && crypto.timingSafeEqual(a, b)) { grant(); }
```

**Go:**
```go
// ❌ Timing attack
if userToken == storedToken { grant() }

// ✅ Timing-safe
if subtle.ConstantTimeCompare([]byte(userToken), []byte(storedToken)) == 1 { grant() }
```

### A08: Software and Data Integrity Failures

**O problema:** código ou dados modificados sem verificação de integridade.

- [ ] Webhooks verificam assinatura (HMAC, constructEvent, etc.)
- [ ] Webhook endpoint recebe raw body ANTES do JSON parser global
- [ ] Idempotência em operações de webhook (via reference_id, event_id, ou ON CONFLICT)
- [ ] CI/CD pipeline protegido — PRs requerem review, secrets não expostos em logs
- [ ] Dependências instaladas via lock file, não `latest`
- [ ] Subresource Integrity (SRI) para CDN assets (se aplicável)

```javascript
// ❌ Webhook sem verificação de assinatura
app.post("/webhook", express.json(), (req, res) => {
  processEvent(req.body);  // qualquer um pode enviar eventos fake
});

// ✅ Webhook com verificação de assinatura
app.post("/webhook", express.raw({ type: "application/json" }), (req, res) => {
  const event = verifySignature(req.body, req.headers["x-signature"], WEBHOOK_SECRET);
  processEvent(event);
});
```

### A09: Security Logging and Monitoring Failures

**O problema:** ataques acontecem e ninguém percebe.

- [ ] Falhas de autenticação logadas (IP, timestamp, email tentado)
- [ ] Ações sensíveis logadas em audit trail (quem fez o que, quando)
- [ ] Rate limit violations logadas (potencial brute force)
- [ ] Logs NÃO contêm dados sensíveis (senhas, tokens, PII)
- [ ] Logs estruturados (JSON) para facilitar análise automatizada
- [ ] Alertas configurados para padrões anômalos (spike de 401, spike de 500)
- [ ] Logs retidos por tempo suficiente para investigação (30-90 dias)

```javascript
// ✅ Log de evento de segurança
console.warn("[AUTH] Login failed:", {
  ip: req.ip,
  email: sanitize(req.body.email),
  reason: "invalid_otp",
  attempts: failedAttempts,
  timestamp: new Date().toISOString()
});
```

### A10: Server-Side Request Forgery (SSRF)

**O problema:** atacante faz o servidor acessar recursos internos.

- [ ] URLs fornecidas pelo usuário validadas contra allowlist de domínios
- [ ] Requests a URLs do usuário não acessam rede interna (127.0.0.1, 10.x, 172.x, 192.168.x)
- [ ] Redirect responses não são seguidos automaticamente para URLs internas
- [ ] Serviços internos não são acessíveis via URL pública
- [ ] Se precisa acessar URL do usuário, usar proxy dedicado com timeout e size limit

---

## Checklist por tipo de mudança

### Nova rota / endpoint

- [ ] Handler async tem error boundary (asyncHandler, try/catch, middleware)
- [ ] Auth middleware aplicado — endpoints sem auth precisam de justificativa documentada
- [ ] Params validados por formato antes de uso (UUID regex, prefixos esperados, etc.)
- [ ] Body fields validados (tipo, range, obrigatoriedade)
- [ ] Queries SQL usam prepared statements — NUNCA concatenação
- [ ] `SELECT` lista colunas explícitas — NUNCA `SELECT *`
- [ ] Novas queries frequentes têm índice nas colunas filtradas
- [ ] Campos sensíveis removidos da resposta (senhas, hashes, tokens internos)
- [ ] Rate limit aplicado (global + específico se necessário)
- [ ] Response não contém informação que ajude enumeração

### Endpoint que modifica dados

- [ ] Ownership check: ID do recurso vem do JWT/session, não do body
- [ ] Operação registrada em audit log (para ações admin/privilegiadas)
- [ ] Idempotência garantida (ON CONFLICT, reference_id, etc.)
- [ ] Transaction para operações multi-tabela
- [ ] Compensação no catch se houver operação parcial
- [ ] Validação de limites de negócio (max amount, max quantity, etc.)

### Endpoint de autenticação

- [ ] Respostas uniformes — nunca revelar se e-mail/usuário existe (anti-enumeração)
- [ ] Comparações de segredo usam timing-safe comparison
- [ ] Rate limit específico (mais restritivo que global)
- [ ] Bloqueio progressivo após falhas consecutivas
- [ ] Tokens rotacionados adequadamente
- [ ] Secrets em produção nunca usam fallback de dev

### Endpoint de cupons / desconto / créditos

- [ ] Valores validados com limites máximos server-side
- [ ] Incremento atômico de uso (`UPDATE ... WHERE uses < max RETURNING`)
- [ ] UNIQUE constraint previne uso duplicado por usuário
- [ ] Compra gratuita (desconto >= preço) trata o fluxo sem gateway de pagamento
- [ ] Rate limit no endpoint público de validação — previne enumeração de códigos

### Race conditions (TOCTOU)

**Time-of-Check to Time-of-Use** — o estado muda entre a validação e a ação.

- [ ] Validação e mutação separadas -> usar transaction ou INSERT com UNIQUE
- [ ] SELECT ... FOR UPDATE quando lê e modifica no mesmo fluxo
- [ ] Nunca confiar em validação feita em request anterior (re-validar no webhook/callback)
- [ ] Contadores atômicos: `UPDATE ... SET count = count + 1 WHERE count < max RETURNING`

**JavaScript:**
```javascript
// ❌ TOCTOU — entre o SELECT e o UPDATE, outro request pode consumir o recurso
const item = await db.query("SELECT * FROM resources WHERE uses < max_uses AND id = $1", [id]);
// ... tempo passa ...
await db.query("UPDATE resources SET uses = uses + 1 WHERE id = $1", [id]);

// ✅ Atômico — check e update na mesma query
const result = await db.query(
  "UPDATE resources SET uses = uses + 1 WHERE id = $1 AND uses < max_uses RETURNING *",
  [id]
);
if (result.rows.length === 0) throw new Error("resource_exhausted");
```

**Go:**
```go
// ❌ TOCTOU
var uses int
err := db.QueryRow("SELECT uses FROM resources WHERE id = $1", id).Scan(&uses)
if uses >= maxUses { return ErrExhausted }
// ... outro goroutine pode incrementar aqui ...
_, err = db.Exec("UPDATE resources SET uses = uses + 1 WHERE id = $1", id)

// ✅ Atômico
result, err := db.Exec(
    "UPDATE resources SET uses = uses + 1 WHERE id = $1 AND uses < max_uses", id,
)
rows, _ := result.RowsAffected()
if rows == 0 { return ErrExhausted }
```

### Redirect e URLs

- [ ] URLs de redirect validadas contra allowlist hardcoded
- [ ] Retornar 400 se URL base não está definida (env var missing)
- [ ] Zero URLs/domínios hardcoded no código — todas vêm de variáveis de ambiente
- [ ] Open redirect prevenido — `returnUrl` validado contra domínios próprios

### Integração com serviço externo

- [ ] API key em variável de ambiente, NUNCA no código
- [ ] Webhook verifica assinatura antes de processar
- [ ] Webhook recebe raw body (antes do JSON parser global)
- [ ] Erros do serviço externo não expõem detalhes internos ao cliente
- [ ] Respostas do serviço externo sanitizadas antes de retornar ao usuário
- [ ] Timeout configurado para evitar hang indefinido
- [ ] Retry com backoff exponencial para erros transitórios

### Frontend

- [ ] Dados sensíveis ficam em state — nunca enviados para analytics/logs
- [ ] Input sanitizado antes de enviar ao backend
- [ ] Nenhum dado sensível em localStorage/sessionStorage
- [ ] `escapeHtml()` em qualquer valor dinâmico renderizado em HTML
- [ ] Zero URLs hardcoded — usar variáveis de ambiente
- [ ] Tokens armazenados em httpOnly cookies (preferível) ou memory (aceitável) — NUNCA localStorage
- [ ] CSP headers previnem inline scripts e carregamento de scripts de terceiros
- [ ] Formulários com CSRF token se usar cookies para auth

---

## Padrões de sanitização

```javascript
// {ADAPTAR à stack do projeto}

// Strings de input — remover tags, control chars, limitar tamanho
function sanitize(str, maxLen = 500) {
  if (typeof str !== "string") return "";
  return str
    .replace(/[<>]/g, "")           // remove tags básicas
    .replace(/[\x00-\x1f]/g, "")    // remove control chars
    .trim()
    .slice(0, maxLen);
}

// Números — NaN vira 0
function sanitizeNumber(val) {
  const n = Number(val);
  return Number.isFinite(n) ? n : 0;
}

// HTML em outputs (emails, relatórios)
function escapeHtml(s) {
  return String(s).replace(/[<>&"']/g, c =>
    ({ "<": "&lt;", ">": "&gt;", "&": "&amp;", '"': "&quot;", "'": "&#39;" }[c])
  );
}

// Comparações timing-safe
function timingSafeCompare(a, b) {
  const bufA = Buffer.from(String(a));
  const bufB = Buffer.from(String(b));
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}

// Deep scan para injection em objetos (prompt injection, XSS em JSON)
function deepScanForInjection(obj) {
  const suspicious = /(<script|javascript:|on\w+=|IGNORE PREVIOUS|SYSTEM:)/i;
  JSON.stringify(obj, (key, val) => {
    if (typeof val === "string" && suspicious.test(val)) {
      throw new Error(`injection_detected: field "${key}"`);
    }
    return val;
  });
}
```

---

## Campos proibidos em respostas

{Definir campos que NUNCA devem aparecer em respostas JSON, mesmo em rotas admin.}

```javascript
const FORBIDDEN_RESPONSE_FIELDS = [
  "password_hash",
  "token_hash",
  "session_token",
  "api_key",
  "secret",
  // {adicionar campos específicos do projeto}
];

// Middleware ou helper para filtrar
function stripSensitiveFields(obj) {
  const clean = { ...obj };
  FORBIDDEN_RESPONSE_FIELDS.forEach(f => delete clean[f]);
  return clean;
}
```

---

## Quando escalar

Se a mudança envolve:
- **Nova tabela que armazena dados sensíveis** -> PARE e revise a política de retenção
- **Novo serviço externo recebendo dados do usuário** -> Verificar exatamente quais dados são enviados
- **Mudança em regras de negócio que envolvem dinheiro** -> Conferir em TODOS os lugares (frontend, backend, testes)
- **Novo role ou permissão** -> Atualizar docs de controle de acesso
- **Mudança em fluxo de autenticação** -> Review por segundo par de olhos (ou checklist completo)
- **Integração com IA/LLM** -> Verificar prompt injection, sanitização de input E output
