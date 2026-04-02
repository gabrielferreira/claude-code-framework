<!-- framework-tag: v2.7.0 framework-file: docs/ACCESS_CONTROL.md -->
# Controle de Acesso — {NOME_DO_PROJETO}

> Documentar fluxos de autenticação, autorização, sessões e roles.
> Atualizar este doc sempre que mudar middleware auth, adicionar role, ou alterar fluxo de login.

## Princípio fundamental

O frontend é DECORATIVO. A fonte da verdade é SEMPRE o backend/banco de dados.
Todo limite, permissão e verificação de acesso é feito server-side.

---

## Domínios de autenticação

{Adaptar: dominios separados de auth se houver. Ex: usuarios vs admins.}

| Domínio | Tabela | Tipo de auth | JWT issuer |
|---|---|---|---|
| {Usuários} | {users} | {Passwordless / Email+Senha / OAuth} | {`iss: "meu-app"`} |
| {Admins} | {admin_users} | {Email+Senha / MFA} | {`iss: "meu-app-admin"`} |

**Regra:** tokens de domínios diferentes são REJEITADOS se usados no domínio errado.

---

## Fluxo de autenticação

### {Fluxo 1 — ex: Passwordless com código por e-mail}

```
1. Usuário informa e-mail
     │
2. Backend verifica se conta existe
     │  ├─ Não existe → cria conta (auto-register) OU rejeita
     │  └─ Existe → continua
     │
3. Gera código de verificação (6 dígitos) → hash → salva no banco
     │  └─ TTL: {10 minutos}
     │  └─ Max tentativas: {5}
     │
4. Envia código por e-mail
     │
5. Usuário informa código
     │
6. Backend valida:
     │  ├─ Código correto (timing-safe) → emite JWT + refresh token
     │  ├─ Código errado → incrementa attempts
     │  └─ Código expirado ou max attempts → rejeita
     │
7. JWT retornado com:
     │  ├─ sub: {user_id}
     │  ├─ iss: {issuer}
     │  └─ exp: {4h / 15min / etc.}
```

### {Fluxo 2 — ex: OAuth / Email+Senha}

{Documentar outro fluxo se houver.}

---

## Tokens e sessões

### JWT (Access Token)

| Propriedade | Valor |
|---|---|
| Algoritmo | {HS256 / RS256} |
| Expiração | {4h / 15min / 30min} |
| Payload | `{ sub, iss, iat, exp, {custom claims} }` |
| Armazenamento (client) | {httpOnly cookie / memory / Authorization header} |

### Refresh Token

| Propriedade | Valor |
|---|---|
| Formato | {Random bytes hex / UUID / JWT} |
| Expiração | {30 dias / 7 dias} |
| Armazenamento (server) | {tabela refresh_tokens, hash SHA-256 do token} |
| Rotação | {A cada uso, revoga antigo + emite novo} |

### Session Token (se aplicável)

{Se o sistema tem sessões de uso com duração limitada, documentar aqui.}

| Propriedade | Valor |
|---|---|
| Finalidade | {Sessão de uso com duração limitada} |
| TTL | {4h / 1h / etc.} |
| Armazenamento | {Hash no banco, token no client} |
| Limites | {Max X ações por sessão} |

---

## Roles e permissões (RBAC)

{Se o sistema tem roles de admin ou diferentes níveis de acesso.}

### Roles definidos

| Role | Permissões | Quem atribui |
|---|---|---|
| {admin} | {Acesso total — CRUD de tudo} | {Outro admin} |
| {viewer} | {Leitura — dashboards, relatórios} | {Admin} |
| {sales} | {Leitura + vendas + leads} | {Admin} |
| {user} | {Recursos próprios apenas} | {Auto-registro} |

### Matriz de permissões por endpoint

| Endpoint | admin | viewer | sales | user | Público |
|---|---|---|---|---|---|
| {GET /api/users} | ✅ | ✅ | ❌ | ❌ | ❌ |
| {POST /api/users} | ✅ | ❌ | ❌ | ❌ | ❌ |
| {GET /api/sales} | ✅ | ✅ | ✅ | ❌ | ❌ |
| {POST /api/resource} | ✅ | ❌ | ❌ | ✅ | ❌ |
| {GET /api/public/info} | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Middleware de autenticação

### Funções principais

{Adaptar: funcoes do middleware auth com breve descricao.}

| Função | Descrição | Arquivo |
|---|---|---|
| {`userAuth`} | {Valida JWT de usuário, extrai user_id} | {middleware/auth.js} |
| {`adminAuth`} | {Valida JWT de admin, verifica role} | {middleware/auth.js} |
| {`requireRole(roles)`} | {Verifica se admin tem role necessário} | {middleware/auth.js} |
| {`generateCode(email)`} | {Gera e envia código de verificação} | {middleware/auth.js} |
| {`verifyCode(email, code)`} | {Valida código timing-safe} | {middleware/auth.js} |

### Fluxo do middleware

```
Request
  │
  ├─ Authorization header presente?
  │    ├─ Não → 401 { error: "token_required" }
  │    └─ Sim → extrair token
  │
  ├─ Token válido?
  │    ├─ Expirado → 401 { error: "token_expired" }
  │    ├─ Issuer errado → 401 { error: "invalid_token" }
  │    └─ Válido → extrair payload
  │
  ├─ Usuário existe e ativo?
  │    ├─ Não → 401 { error: "account_not_found" }
  │    └─ Sim → req.user = { id, email, role }
  │
  └─ next()
```

---

## Segurança de autenticação

### Anti-enumeração

Todas as respostas de auth retornam a **mesma mensagem genérica**, independente do estado:
- Email não existe → `"Credenciais inválidas"`
- Email existe, senha errada → `"Credenciais inválidas"`
- Conta desativada → `"Credenciais inválidas"`

**Nunca** retornar "Usuário não encontrado" ou "Senha incorreta".

### Timing-safe comparison

Toda comparação de secret (código de verificação, token, hash) usa comparação timing-safe:

```javascript
const a = Buffer.from(String(userInput));
const b = Buffer.from(String(storedHash));
if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
  throw new Error("invalid_credentials");
}
```

### Rate limiting

| Endpoint | Limite | Janela |
|---|---|---|
| {POST /auth/login} | {5 req} | {15 min} |
| {POST /auth/verify-code} | {10 req} | {15 min} |
| {POST /auth/register} | {3 req} | {1 hora} |
| {Rotas de API (geral)} | {100 req} | {15 min} |

### Bloqueio progressivo

{Se aplicável — bloqueio após N tentativas erradas.}

| Tentativas erradas | Ação |
|---|---|
| {3} | {Delay de 30s} |
| {5} | {Bloqueio por 15min} |
| {10} | {Bloqueio por 1h + alerta admin} |

---

## Schema de autenticação

{DDL das tabelas de auth — resumido. Schema completo em `database/schema.sql`.}

```sql
-- {Adaptar ao schema do projeto}

CREATE TABLE {users} (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) UNIQUE NOT NULL,
    -- {password_hash VARCHAR(255), -- se usar senha}
    -- {Campos específicos}
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE {refresh_tokens} (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES {users}(id),
    token_hash  VARCHAR(255) NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- {Tabelas adicionais: otp_codes, admin_users, audit_log, etc.}
```

---

## Endpoints públicos (sem auth)

{Adaptar: endpoints que NAO exigem autenticacao, com justificativa.}

| Endpoint | Justificativa |
|---|---|
| {POST /auth/register} | {Cadastro — usuário ainda não tem token} |
| {POST /auth/login} | {Login — usuário precisa se autenticar} |
| {POST /auth/verify-code} | {Validação de código — pré-autenticação} |
| {GET /api/public/*} | {Informações públicas da plataforma} |

**Regra:** todo endpoint sem auth DEVE ter justificativa documentada. Se não tem justificativa, precisa de auth.
