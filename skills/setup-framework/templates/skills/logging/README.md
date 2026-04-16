<!-- framework-tag: v2.48.0 framework-file: skills/logging/README.md -->
# Skill: Logging & Error Handling — {NOME_DO_PROJETO}

> Use esta skill ao adicionar logs, tratar erros, ou escrever try/catch.

## Quando usar

- Ao adicionar logs em rota, serviço ou módulo
- Ao escrever try/catch ou tratar erros
- Ao integrar com serviço externo (que pode falhar)
- Ao revisar código existente que tem `console.log` em código de produção

## Quando NÃO usar

- Para depuração temporária durante desenvolvimento — usar debugger ou `console.log` marcado com `// DEBUG`
- Para scripts descartáveis que não vão para produção
- Se o framework de log centralizado já captura automaticamente (verificar antes de duplicar)

## Níveis de log

| Nível | Quando usar | Exemplo |
|---|---|---|
| `console.error("[MODULE]", ...)` | Erro que precisa de ação — falha de DB, API, assinatura | `console.error("[STRIPE] Assinatura inválida:", err.message)` |
| `console.info("[MODULE]", ...)` | Evento de negócio relevante — pagamento, sessão criada | `console.info("[AUTH] Login OK:", { accountId })` |
| `console.warn("[MODULE]", ...)` | Condição degradada — rate limit próximo, retry | `console.warn("[DB] Pool connections at 80%")` |
| `console.log` | **NUNCA em produção.** Exceções: scripts CLI e startup. |

## Formato obrigatório

```javascript
// ✅ Correto — prefixo [MODULE], dados estruturados
console.error("[AUTH] Token refresh falhou:", { accountId, reason: "expired" });

// ❌ Errado — texto livre, sem módulo, dados sensíveis
console.log("Erro ao processar para " + email);
console.error(err);  // stack trace em produção
```

## O que NUNCA logar

- {Dados sensíveis do domínio — PII, cartão, senha, tokens, etc.}
- API keys, tokens, secrets, hashes
- Stack traces em produção (global handler cuida)
- {Outros dados sensíveis específicos do projeto}

## O que SEMPRE logar

- IDs de correlação (session_id, request_id, account_id)
- `err.message` (nunca `err.stack` direto)
- `req.ip`, `req.path`, `req.method`
- Status HTTP e código de erro
- Eventos de negócio

## Padrões de error handling

### Rota simples (sem serviço externo)

{Se usa asyncHandler ou equivalente, o error handler global já cuida.}

```javascript
// ✅ OK — asyncHandler propaga para global handler
router.get("/resource/:id", auth, asyncHandler(async (req, res) => {
  const result = await db.query("SELECT id FROM resources WHERE id = $1", [id]);
  if (result.rows.length === 0) return res.status(404).json({ error: "not_found" });
  res.json(result.rows[0]);
}));
```

### Rota com serviço externo

Try/catch OBRIGATÓRIO — para log contextual e status específico (502/503).

```javascript
try {
  const result = await externalService.call(data);
  res.json(result);
} catch (err) {
  console.error("[SERVICE] Erro:", { context, error: err.message });
  res.status(502).json({ error: "service_unavailable", message: "Serviço temporariamente indisponível." });
}
```

### Fallback no catch (compensação)

Se o catch executa operação que pode falhar, DEVE ter try/catch próprio.

```javascript
} catch (err) {
  try {
    await compensate(resourceId);  // protegido — não esconde erro original
  } catch (compErr) {
    console.error("[MODULE] Falha ao compensar:", { resourceId, error: compErr.message });
  }
  console.error("[MODULE] Erro principal:", { error: err.message });
  res.status(502).json({ error: "service_error" });
}
```

### Transaction

SEMPRE: `try/catch/finally` com `BEGIN`, `COMMIT`, `ROLLBACK`, `client.release()`.

```javascript
const client = await db.connect();
try {
  await client.query("BEGIN");
  // ... queries com client (não db) ...
  await client.query("COMMIT");
} catch (err) {
  await client.query("ROLLBACK");
  throw err;
} finally {
  client.release();  // SEMPRE — mesmo se ROLLBACK falhar
}
```

## Módulos registrados

{Adaptar: prefixos para consistencia no projeto:}

| Prefixo | Módulo |
|---|---|
| `[SERVER]` | Startup, shutdown |
| `[ERROR]` | Global error handler |
| `[AUTH]` | Autenticação, tokens |
| `[DB]` | Pool, migrations |
| {`[MÓDULO]`} | {descrição} |

## Checklist

- [ ] Nenhum `console.log` em código de produção
- [ ] Todo `console.error` tem prefixo `[MODULE]`
- [ ] Nenhum dado sensível nos logs
- [ ] Rotas com serviço externo têm try/catch com log + status específico
- [ ] Operações de fallback no catch têm try/catch próprio
- [ ] Operações multi-query atômicas usam transaction
- [ ] Transactions têm `finally { client.release() }`

## Regras

1. **Nunca logar dados sensíveis** — PII, cartão, senha, tokens, API keys
2. **Prefixo `[MODULE]` obrigatório** em todo log — facilita filtrar por módulo em produção
3. **`err.message` apenas** — nunca `err.stack` diretamente em produção (handler global cuida)
4. **`console.log` proibido em produção.** Exceções: scripts CLI e startup
5. **IDs de correlação sempre** — session_id, request_id ou account_id em todo log de rota
