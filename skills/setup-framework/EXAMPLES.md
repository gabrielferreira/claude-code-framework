<!-- framework-tag: v2.49.2 framework-file: skills/setup-framework/EXAMPLES.md -->
# Examples — setup-framework

> Exemplos longos de output referenciados pelo SKILL.md.
> Nao editar sem atualizar o SKILL.md principal.

---

## DETECTION_SUMMARY — Exemplo completo

```
📋 Deteccao automatica — {nome do repo}

  Stack:      {stacks detectadas}
  Tipo:       {monorepo | single repo} / {frontend | backend | fullstack}
  DB:         {se detectado, qual}
  Testes:     {ferramentas de teste}
  CI/CD:      {ferramenta}
  Docker:     {sim/nao}

  Comandos detectados:
    dev:      {comando}
    test:     {comando}
    build:    {comando}
    coverage: {comando}

  Padroes de codigo (CODE_PATTERNS):
    Logging:    {lib} — {formato}
    Erros:      {lib} — {padrao}
    HTTP:       {lib}
    Validacao:  {lib}
    ORM/DB:     {lib}
    Config:     {lib}

  Skills condicionais:
    {✅ dba-review (DB detectado) | ❌ dba-review (sem DB)}
    {✅ ux-review (frontend detectado) | ❌ ux-review (sem frontend)}
    {✅ seo-performance (frontend publico) | ❌ seo-performance (sem SSR/SSG)}

  Defaults inferidos:
    Nome:       {nome do package.json ou diretorio}
    Modo:       {FRAMEWORK_MODE ja escolhido na Fase 0}
    Specs:      repo (default)
    Coverage:   80%
    PRD:        nao
    TDD:        sim (default do framework)
```

---

## CODE_PATTERNS — Exemplo single-repo

```
CODE_PATTERNS = {
  logging: {
    lib: "elogger",                           // nome da lib real
    import: 'import "company/pkg/elogger"',   // import exato
    levels: ["Debug", "Info", "Warn", "Error"],// niveis usados
    format: "elogger.Error(ctx, msg, fields)", // formato de chamada
    structured: true                           // se usa campos estruturados
  },
  errors: {
    lib: "erros",                              // nome da lib real
    import: 'import "company/pkg/erros"',      // import exato
    wrap: "erros.Wrap(err, msg)",              // padrao de wrap
    new: "erros.New(msg)",                     // padrao de criacao
    types: ["NotFoundError", "ValidationError"] // tipos customizados
  },
  http_client: {
    lib: "internal/httpclient",
    pattern: "httpclient.Do(ctx, req)"
  },
  validation: { lib: "zod", pattern: "schema.parse(input)" },
  orm: { lib: "sqlx", pattern: "db.QueryContext(ctx, query, args...)" },
  config: { lib: "viper", pattern: "viper.GetString(key)" }
}
```

---

## Customizacao logging — Exemplo projeto Go com elogger

```markdown
| Nivel | Quando usar | Exemplo |
|---|---|---|
| `elogger.Error(ctx, msg, fields)` | Erro que precisa de acao | `elogger.Error(ctx, "payment failed", elogger.F("order_id", id))` |
| `elogger.Info(ctx, msg, fields)` | Evento de negocio relevante | `elogger.Info(ctx, "order created", elogger.F("order_id", id))` |
| `elogger.Warn(ctx, msg, fields)` | Condicao degradada | `elogger.Warn(ctx, "pool connections high", elogger.F("pct", 80))` |
| `elogger.Debug(ctx, msg, fields)` | **NUNCA em producao.** | Somente local com nivel DEBUG ativo. |
```

---

## Regra de consistencia — Exemplo projeto Go com lib interna

```markdown
## Regra de consistencia

- **Logging:** usar `elogger` — nunca `fmt.Println`, `log.Printf` ou `fmt.Fprintf(os.Stderr, ...)`
- **Erros:** usar `erros.New()` / `erros.Wrap()` — nunca `fmt.Errorf()` ou `errors.New()` da stdlib
- **HTTP client:** usar `httpclient.Do()` — nunca `http.Get()` direto
```

---

## SETUP_REPORT.md — Exemplo completo

```markdown
# Relatorio de Setup — {NOME_DO_PROJETO}

> Data: {YYYY-MM-DD}
> Modo: {FRAMEWORK_MODE}
> Modelo spec-driven: {modelo escolhido}
> Stack: {stack detectada}

## Arquivos criados

| Arquivo | Descricao | Status |
|---|---|---|
| `CLAUDE.md` | Regras e convencoes | {status} |
| `PROJECT_CONTEXT.md` | Briefing portatil | {status} |
| `SPECS_INDEX.md` | Indice de specs | {status} |
| `.claude/specs/TEMPLATE.md` | Template de spec | {status} |
| `.claude/specs/backlog.md` | Backlog unificado | {status} |
| `.claude/specs/STATE.md` | Memoria persistente entre sessoes | {status} |
| `.claude/specs/DESIGN_TEMPLATE.md` | Template de design doc | {status} |
| `scripts/verify.sh` | Verificacao pre-commit | {status} |
| `scripts/reports.sh` | Orquestrador de reports (auto-deteccao) | {status} |
| `scripts/reports-index.js` | Pagina consolidada de reports | {status} |
| `scripts/backlog-report.cjs` | Report HTML do backlog | {status} |
| `docs/README.md` | Indice de docs | {status} |
| `docs/GIT_CONVENTIONS.md` | Convencoes de git | {status} |
| `migrations/README.md` | Índice de migrations do framework | {status} |
| ... | ... | ... |

Status: Criado | Atualizado (merge) | Pulado (ja existia) | N/A (modelo externo)

## Skills instaladas

| Skill | Tipo | Motivo |
|---|---|---|
| spec-driven | Core | Sempre incluida |
| definition-of-done | Core | Sempre incluida |
| testing | Core | Sempre incluida |
| code-quality | Core | Sempre incluida |
| dba-review | Recomendada | DB/ORM detectado |
| ... | ... | ... |

## Agents instalados

| Agent | Modelo | Motivo |
|---|---|---|
| security-audit | opus | Analise profunda OWASP |
| spec-validator | sonnet | Comparacao spec vs codigo |
| coverage-check | sonnet | Gaps de cobertura |
| backlog-report | haiku | Leitura e formatacao |
| code-review | sonnet | Qualidade de codigo |
| component-audit | sonnet | Arquitetura de componentes |

> Modelos dos agents podem ser ajustados editando o campo `model:` no frontmatter de cada `.claude/agents/*.md`.
> Para sub-agents built-in (Explore, Plan), o Claude segue as diretrizes da secao "Modelos para sub-agents" no CLAUDE.md.

## Configuracoes aplicadas

- **Coverage global:** {threshold}%
- **Modulos 100%:** {lista}
- **Modelo spec-driven:** {modelo} — {detalhes}
- **Fases do roadmap:** {lista}
- **Dominio:** {dominio}

## Estrutura do projeto

- **Tipo:** {single repo | monorepo}

{SE SINGLE REPO: omitir o restante desta secao.}

{SE MONOREPO: ver MONOREPO_DETAILS.md secao "Fase 5 — Estrutura do projeto"}
```

---

## Categoria 6 — Exemplos de output de mismatch

### Exemplo de mismatch de logging (elogger)

```
⚠️ A skill "logging" tem exemplos em JavaScript, mas o projeto usa Go.
CODE_PATTERNS detectou: elogger (github.com/your-org/backend-libs/elogger)

📄 Conteudo atual (trecho):
  | `console.error("[MODULE]", ...)` | Erro que precisa de ação | `console.error("[STRIPE]...` |

✏️ Sugestao de substituicao:
  | `elogger.Error(ctx, msg, fields)` | Erro que precisa de ação | `elogger.Error(ctx, "payment failed", elogger.F("order_id", id))` |
  | `elogger.Info(ctx, msg, fields)` | Evento de negócio | `elogger.Info(ctx, "order created", elogger.F("order_id", id))` |
  | `elogger.Warn(ctx, msg, fields)` | Condição degradada | `elogger.Warn(ctx, "pool high", elogger.F("pct", 80))` |
  | `elogger.Debug(ctx, msg, fields)` | NUNCA em produção | Somente local com nível DEBUG ativo |

Opcoes:
1. Aplicar esta sugestao
2. Editar antes de aplicar — o que quer mudar?
3. Manter como esta (vou customizar depois)
```

### Exemplo de mismatch de lib de erros

```
⚠️ A skill "code-quality" sugere `fmt.Errorf` para erros, mas o projeto usa a lib `erros`.
Detectei o padrao: erros.Wrap(err, "contexto") em 8 arquivos.

📄 Conteudo atual no CLAUDE.md "Regras de codigo":
  2. **Error handling explícito.** Erros específicos, nunca genéricos.

✏️ Sugestao — adicionar regras de consistencia ao CLAUDE.md:
  - **Logging:** usar `elogger` (github.com/your-org/backend-libs/elogger) — nunca `fmt.Println`, `log.Printf`
  - **Erros:** usar `erros.New()` / `erros.Wrap()` (ecommerce/app/src/errors) — nunca `fmt.Errorf()` ou `errors.New()` stdlib

✏️ Sugestao — adicionar check ao skill "code-quality":
  # Detectar uso de fmt.Errorf (proibido — usar erros.Wrap/erros.New)
  grep -rn "fmt\.Errorf" internal/ pkg/ --include="*.go" | grep -v _test.go | grep -v vendor

Opcoes:
1. Aplicar ambas sugestoes
2. Aplicar so CLAUDE.md
3. Aplicar so code-quality
4. Editar antes de aplicar — o que quer mudar?
5. Ignorar (vou configurar depois)
```

### Exemplo de skill irrelevante

```
⚠️ A skill "ux-review" foi instalada, mas o projeto parece ser backend puro (Go API).

Opcoes:
1. Remover — nao se aplica a este projeto
2. Manter — temos planos de frontend futuro
3. Manter — temos um frontend em outro repo que consome esta API
```

### Exemplo de remocao completa

```
Removendo skill "ux-review":
  - Deletar .claude/skills/ux-review/README.md
  - Remover linha 10 da tabela Skills no CLAUDE.md
  - Remover check "ux-review" do verify.sh (se existir)

Confirmar? [Sim/Nao]
```

### Exemplo de secao CLAUDE.md irrelevante

```
⚠️ O CLAUDE.md tem a secao "Mindset Frontend" e padroes de e2e testing,
mas o projeto parece ser backend Go puro.

Opcoes:
1. Remover secoes de frontend e e2e (recomendado para backend puro)
2. Manter — o projeto vai ter frontend em breve
3. Manter apenas "Mindset Frontend" mas remover e2e patterns
```

---

## Confirmacao de DETECTION_SUMMARY — AskUserQuestion

```json
{
  "questions": [{
    "question": "A deteccao acima esta correta?",
    "header": "Confirmar",
    "options": [
      {"label": "Sim, continuar (Recomendado)", "description": "Usar tudo detectado como default — pular questionario"},
      {"label": "Ajustar", "description": "Abrir questionario para corrigir pontos especificos"}
    ],
    "multiSelect": false
  }]
}
```
