<!-- framework-tag: v2.37.1 framework-file: docs/GIT_CONVENTIONS.md -->
# Git Conventions — {NOME_DO_PROJETO}

## Conventional Commits (obrigatório)

Todo commit segue o formato: `<type>(<scope>): <description>`

### Types

| Type | Quando usar |
|---|---|
| `feat` | Nova funcionalidade visível ao usuário ou ao sistema |
| `fix` | Correção de bug |
| `security` | Correção ou melhoria de segurança |
| `test` | Adição ou correção de testes (sem alterar código de produção) |
| `refactor` | Refatoração sem alterar comportamento |
| `docs` | Documentação (README, CLAUDE.md, docs/) |
| `chore` | Tooling, CI/CD, deps, configs (sem alterar código de produção) |
| `style` | Formatação, lint (sem alterar lógica) |
| `perf` | Melhoria de performance |

### Scopes (opcional mas recomendado)

{Adaptar: scopes relevantes ao projeto. Exemplos:}

`auth`, `security`, `admin`, `payments`, `email`, `frontend`, `backend`, `schema`, `ci`, `deps`

### Exemplos

```
feat(auth): add verification code generation and validation
fix(payments): handle edge case when discount >= price
test(security): add injection scan scenarios for unicode evasion
security(auth): add ownership check in /api/resource
docs(claude): add testing skill with coverage policy
chore(deps): update express to 4.21.0
refactor(auth): extract token validation to middleware
```

---

## Micro commits (obrigatório)

Cada commit deve ser **atômico** — faz exatamente UMA coisa. Se o commit message precisar de "e" ou listar múltiplas mudanças, deve ser quebrado em commits separados.

**Regra:** um commit deve poder ser revertido sem efeitos colaterais em funcionalidades não relacionadas.

**Bom:**
```
feat(security): add sanitize function for string input
feat(security): add sanitizeNumber with range clamping
test(security): add sanitize unit tests (9 scenarios)
```

**Ruim:**
```
feat: add all security functions and tests
```

**Quando quebrar commits:**

| Situação | Commits |
|---|---|
| Nova função | 1 commit |
| Testes para essa função | 1 commit separado (exceto TDD: test primeiro) |
| Bug fix | 1 para fix + 1 para teste que prova |
| Refatoração | 1 commit (testes devem continuar passando) |
| Nova tabela no schema | 1 commit |
| Novo endpoint | 1 commit |
| Documentação | 1 commit por documento ou seção significativa |

---

## Branches

```
main              ← produção, sempre deployável
develop           ← integração, recebe PRs (opcional — projetos menores podem usar main direto)
feat/<nome>       ← funcionalidades novas
fix/<nome>        ← correções de bug
security/<nome>   ← correções de segurança (tratadas como urgentes)
```

**Nomenclatura:** `feat/passwordless-auth`, `fix/edge-case-validation`, `security/ownership-check`

---

## Pull Requests

### Regra de entrega

Toda entrega e via Pull Request. Push direto para `main` (ou branch de integracao) e proibido. Esta regra se aplica a sessoes humanas e a sessoes de IA.

**Título:** segue conventional commits (`feat(auth): implement passwordless login flow`)

**Descrição obrigatória:**
```markdown
## O que muda
Resumo em 1-3 frases.

## Por quê
Contexto do problema ou necessidade.

## Como testar
Passos para validar manualmente (se aplicável).

## Checklist
- [ ] Testes passando (`{comando de teste}`)
- [ ] Coverage nos módulos críticos (`{comando de coverage}`)
- [ ] Sem secrets no código
- [ ] Checklist de segurança aplicado (agent security-audit)
- [ ] Conventional commit no título
```

**Regras de merge:**
- Mínimo 1 review (2 para branches `security/*`)
- CI verde (testes + lint + coverage)
- Squash merge em `develop`, merge commit de `develop` para `main`
- Branch deletada após merge

---

## Tags e releases

```
v1.0.0   ← primeiro release em produção
v1.1.0   ← nova funcionalidade
v1.1.1   ← fix
```

Seguir [semver](https://semver.org/): MAJOR (breaking changes), MINOR (features), PATCH (fixes).
