# {NOME_DO_PROJETO} — Índice de Documentação

> Para setup e execução do projeto, veja o [`README.md`](../README.md) na raiz.
> Para briefing completo (usar com qualquer LLM), veja o [`PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md).
> Para regras de desenvolvimento, veja o [`CLAUDE.md`](../CLAUDE.md).

---

## Documentos nesta pasta

### Templates incluídos (com conteúdo)

| Documento | Descrição | Público |
|---|---|---|
| [`GIT_CONVENTIONS.md`](GIT_CONVENTIONS.md) | Conventional Commits, micro commits, branches, PRs, tags | Dev |
| [`ACCESS_CONTROL.md`](ACCESS_CONTROL.md) | Auth, sessões, tokens, refresh, roles, RBAC, rate limit | Dev |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Decisões arquiteturais, integrações, schema, env vars | Dev |
| [`SECURITY_AUDIT.md`](SECURITY_AUDIT.md) | Checklist OWASP Top 10 + API Security + LLM Top 10 | Dev/Sec |

### Docs adicionais sugeridos (criar conforme necessidade)

| Documento | Quando criar |
|---|---|
| {`GUIA_USUARIO.md`} | {Quando tiver interface de usuário final} |
| {`GUIA_ADMIN.md`} | {Quando tiver painel administrativo} |
| {`API.md`} | {Quando tiver API REST/GraphQL pública} |
| {`TERMS_OF_SERVICE.md`} | {Quando tiver termos de uso / privacidade / contrato} |
| {`EMAIL_SERVICE.md`} | {Quando tiver templates transacionais de e-mail} |

{Remover linhas entre {} que não se aplicam ao projeto. Adicionar linhas para docs específicos do domínio.}

---

## Onde encontrar cada tipo de informação

| Preciso de... | Veja |
|---|---|
| Como rodar o projeto localmente | [`../README.md`](../README.md) |
| Como fazer deploy em produção | [`../README.md`](../README.md) → seção Deploy |
| Contexto do projeto para um LLM | [`../PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md) |
| Regras de código e segurança | [`../CLAUDE.md`](../CLAUDE.md) |
| Specs de features | [`../.claude/specs/`](../.claude/specs/) + [`../SPECS_INDEX.md`](../SPECS_INDEX.md) |
| Backlog (o que falta fazer) | [`../.claude/specs/backlog.md`](../.claude/specs/backlog.md) |
| Skills de desenvolvimento | [`../.claude/skills/`](../.claude/skills/) |
| Convenções de git | [`GIT_CONVENTIONS.md`](GIT_CONVENTIONS.md) |

---

## Convenção de manutenção

1. **Novos docs** — adicionar nesta tabela com descrição e público-alvo
2. **Contagens** — manter sincronizadas com o código real (verify.sh valida)
3. **Docs removidos** — remover da tabela (não deixar links quebrados)
4. **Fonte da verdade** — `CLAUDE.md` é a fonte para regras de dev; esta pasta é para documentação expandida e guias
