<!-- framework-tag: v2.41.0 framework-file: docs/SECURITY_AUDIT.md -->
# Auditoria de Segurança — {NOME_DO_PROJETO}

**Data:** {YYYY-MM-DD}
**Versão:** {v1.0}
**Escopo:** {Frontend + Backend + Banco + Integrações}
**Auditor:** {Quem fez a auditoria}

---

## Metodologia

Checklist baseado em:
- **OWASP Top 10 (2021)** — riscos web mais comuns
- **OWASP API Security Top 10 (2023)** — riscos específicos de APIs
- {**OWASP LLM Top 10 (2025)** — se usa IA/LLM}

Cada item classificado como: ✅ COBERTO | ⚠️ PARCIAL | ❌ PENDENTE

---

## OWASP Top 10 (Web)

### A01:2021 — Broken Access Control

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Controle de acesso server-side em todo endpoint | {✅/⚠️/❌} | {Arquivo, teste, linha} |
| 2 | Ownership check (IDOR prevenido) | {status} | {WHERE user_id = $1 com ID do JWT} |
| 3 | Roles/permissões verificados no backend | {status} | {Middleware, testes de role} |
| 4 | Rate limiting em endpoints sensíveis | {status} | {Config, limites} |
| 5 | Sessões expiram adequadamente | {status} | {TTL, verificação} |
| 6 | CORS restrito a domínios próprios | {status} | {Config} |

### A02:2021 — Cryptographic Failures

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Senhas armazenadas com bcrypt/scrypt/argon2 | {status} | {Ou: passwordless, sem senha} |
| 2 | Tokens assinados com secret forte (256+ bits) | {status} | {Algoritmo, geração} |
| 3 | Tokens/secrets hasheados no banco (SHA-256) | {status} | {Colunas _hash} |
| 4 | HTTPS obrigatório em produção | {status} | {Config, redirect} |
| 5 | API keys protegidas (env vars, nunca no código) | {status} | {Grep confirma} |
| 6 | Secret de dev não funciona em produção | {status} | {Fail-fast no startup} |

### A03:2021 — Injection

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | SQL injection prevenido (prepared statements) | {status} | {$1, $2 em toda query} |
| 2 | XSS prevenido (escape de HTML em outputs) | {status} | {escapeHtml, sanitize} |
| 3 | Template injection prevenido | {status} | {Sem eval/Function com input} |
| 4 | OS command injection prevenido | {status} | {Sem exec/spawn com input} |
| {5} | {Prompt injection prevenido (se usa LLM)} | {status} | {Delimitadores, scan, sanitize} |

### A04:2021 — Insecure Design

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Rate limit em auth (login, register, verify code) | {status} | {Limites configurados} |
| 2 | Limites de negócio enforced server-side | {status} | {Max calls, max items, etc.} |
| 3 | Dados sensíveis não persistidos (se aplicável) | {status} | {Schema não tem coluna X} |
| 4 | Compensação automática em falhas parciais | {status} | {Try/catch com rollback} |

### A05:2021 — Security Misconfiguration

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Headers de segurança (Helmet/equivalente) | {status} | {Package, config} |
| 2 | Stack traces não expostos em produção | {status} | {Error handler} |
| 3 | .env no .gitignore | {status} | {.gitignore} |
| 4 | Env vars obrigatórias validadas no startup | {status} | {Fail-fast} |
| 5 | Endpoints de debug removidos/protegidos | {status} | {Grep confirma} |

### A06:2021 — Vulnerable Components

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | `npm audit` / equivalente sem críticos | {status} | {Última execução: data} |
| 2 | Lock file commitado | {status} | {package-lock.json} |
| 3 | Runtime em versão LTS | {status} | {Node X / Python X} |

### A07:2021 — Identification and Authentication Failures

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Respostas anti-enumeração (mensagem genérica) | {status} | {Mesmo response para email existe/não existe} |
| 2 | Comparações timing-safe | {status} | {crypto.timingSafeEqual} |
| 3 | JWT com expiração curta | {status} | {TTL definido} |
| 4 | Refresh token rotacionado | {status} | {Revoga antigo + emite novo} |
| 5 | Bloqueio progressivo após falhas | {status} | {N tentativas → delay/bloqueio} |

### A08:2021 — Software and Data Integrity Failures

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Webhooks verificam assinatura | {status} | {HMAC, constructEvent} |
| 2 | Webhook recebe raw body antes do JSON parser | {status} | {express.raw} |
| 3 | Idempotência em webhooks | {status} | {reference_id, ON CONFLICT} |
| 4 | CI/CD protegido | {status} | {PRs, review, secrets} |

### A09:2021 — Security Logging and Monitoring Failures

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | Falhas de auth logadas | {status} | {IP, email, reason} |
| 2 | Ações sensíveis em audit trail | {status} | {Tabela audit_log} |
| 3 | Logs NÃO contêm dados sensíveis | {status} | {Grep confirma} |
| 4 | Logs estruturados (JSON) | {status} | {Format} |

### A10:2021 — Server-Side Request Forgery (SSRF)

| # | Verificação | Status | Evidência |
|---|---|---|---|
| 1 | URLs de usuário validadas contra allowlist | {status} | {Ou: não aceita URLs de usuário} |
| 2 | Rede interna não acessível via URLs externas | {status} | {Config} |

---

## OWASP API Security Top 10 (2023)

{Preencher se o projeto expõe API REST/GraphQL.}

| # | Risco | Status | Evidência |
|---|---|---|---|
| API1 | Broken Object Level Authorization (BOLA) | {status} | {Ownership check em todo endpoint} |
| API2 | Broken Authentication | {status} | {Ver A07 acima} |
| API3 | Broken Object Property Level Authorization | {status} | {SELECT com colunas explícitas, sem campos sensíveis} |
| API4 | Unrestricted Resource Consumption | {status} | {Rate limit, max payload, pagination} |
| API5 | Broken Function Level Authorization | {status} | {Roles verificados por endpoint} |
| API6 | Unrestricted Access to Sensitive Business Flows | {status} | {Rate limit + limites de negócio} |
| API7 | Server Side Request Forgery | {status} | {Ver A10 acima} |
| API8 | Security Misconfiguration | {status} | {Ver A05 acima} |
| API9 | Improper Inventory Management | {status} | {Endpoints documentados, sem endpoints shadow} |
| API10 | Unsafe Consumption of APIs | {status} | {Respostas de APIs externas sanitizadas} |

---

## OWASP LLM Top 10 (2025)

{Preencher apenas se o projeto usa IA/LLM. Remover se não usa.}

| # | Risco | Status | Evidência |
|---|---|---|---|
| LLM01 | Prompt Injection | {status} | {Deep scan, delimitadores, sanitize input/output} |
| LLM02 | Insecure Output Handling | {status} | {sanitizeAIResponse em todo retorno} |
| LLM03 | Training Data Poisoning | {status} | {Não faz fine-tuning / controle de dados} |
| LLM04 | Model Denial of Service | {status} | {Max tokens, rate limit, timeout} |
| LLM05 | Supply Chain Vulnerabilities | {status} | {Providers confiáveis, sem modelos custom} |
| LLM06 | Sensitive Information Disclosure | {status} | {Output sanitizado, sem PII no response} |
| LLM07 | Insecure Plugin Design | {status} | {Sem plugins / tools controlados} |
| LLM08 | Excessive Agency | {status} | {LLM não executa ações, só analisa} |
| LLM09 | Overreliance | {status} | {Disclaimer, não é conselho profissional} |
| LLM10 | Model Theft | {status} | {API key protegida, sem acesso direto} |

---

## Gaps identificados e plano de ação

{Adaptar: itens PARCIAL e PENDENTE com plano de correcao.}

| # | Gap | Severidade | Plano | Prazo |
|---|---|---|---|---|
| {1} | {Descrição do gap} | {Crítico/Alto/Médio/Baixo} | {O que fazer para resolver} | {Data} |
| {2} | {Descrição} | {severidade} | {Plano} | {Data} |

---

## Histórico de auditorias

| Data | Versão | Itens verificados | Gaps encontrados | Status |
|---|---|---|---|---|
| {YYYY-MM-DD} | v1.0 | {N} | {N gaps} | {Em andamento / Concluída} |

---

## Próxima auditoria

**Data prevista:** {YYYY-MM-DD}
**Trigger:** {A cada N meses / Antes de cada release major / Após mudança em auth}
