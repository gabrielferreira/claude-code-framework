<!-- framework-tag: v2.49.2 framework-file: skills/setup-framework/AUDIT_DETAILS.md -->
# Audit Details — setup-framework

> Conteudo condicional carregado pelo SKILL.md na Fase 5b (auditoria de completude).
> Nao editar sem atualizar o SKILL.md principal.

---

## 5b. Auditoria de completude

Apos criar todos os arquivos, rodar uma auditoria automatica para verificar que o setup ficou completo. Adicionar o resultado ao final do SETUP_REPORT.md.

**Filtragem por modo:** se `FRAMEWORK_MODE=light`, a auditoria so verifica arquivos com tier `core` ou `conditional`. Arquivos tier=`full` ausentes nao sao reportados como faltantes — sao esperados. Categorias que dependem de features full-only (ex: Categoria 8 deduplicacao, checks de monorepo) sao automaticamente ignoradas em light (guards de `## Monorepo` e contagem de sub-projetos nao satisfeitos).

### Categoria 1 — Existencia de arquivos

Verificar que todos os arquivos obrigatorios e opcionais existem no projeto:

A severidade depende do modelo de specs escolhido no Bloco 2:

| Arquivo | Modo repo | Modo Notion | Modo externo |
|---|---|---|---|
| `CLAUDE.md` | 🔴 critico | 🔴 critico | 🔴 critico |
| `SPECS_INDEX.md` | 🔴 critico | 🔴 critico (ponte local→Notion) | 🔴 critico |
| `SPECS_INDEX_ARCHIVE.md` | 🟡 medio | 🟡 medio | 🟡 medio |
| `.claude/specs/TEMPLATE.md` | 🔴 critico | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |
| `.claude/specs/backlog.md` | 🔴 critico | ⚪ **desnecessario** — backlog e a database do Notion | ⚪ desnecessario |
| `scripts/verify.sh` | 🔴 critico | 🔴 critico | 🔴 critico |
| `.claude/specs/STATE.md` | 🟠 alto | 🟠 alto | 🟠 alto |
| `.claude/specs/DESIGN_TEMPLATE.md` | 🟡 medio | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |
| `PROJECT_CONTEXT.md` | 🟡 medio |
| `scripts/reports.sh` | 🟡 medio |
| `scripts/backlog-report.cjs` | 🟡 medio |
| `scripts/reports-index.js` | 🟡 medio |
| `docs/README.md` | 🟡 medio |
| `docs/GIT_CONVENTIONS.md` | ⚪ info |
| `docs/SKILLS_GUIDE.md` | ⚪ info |
| `.claude/prds/PRD_TEMPLATE.md` | ⚪ info (so se PRD opt-in) |
| `.claude/prds/PRDS_INDEX.md` | ⚪ info (so se PRD opt-in) |
| `.github/pull_request_template.md` | ⚪ info |

### Categoria 2 — Agents

Para cada agent em `[security-audit, spec-validator, coverage-check, backlog-report, code-review, component-audit, seo-audit, product-review, refactor-agent, test-generator, dx-audit, performance-audit, infra-audit, task-runner, stuck-detector, debugger]`:

1. **Arquivo existe** em `.claude/agents/{nome}.md`? → 🔴 se nao
2. **Frontmatter completo?** Campos: `description`, `model`, `worktree`, `model-rationale` → 🟠 por campo faltante
3. **Framework-tag** presente apos frontmatter? → 🟡 se nao
4. **Secoes obrigatorias?** H1 + "Quando usar" + "Input" + "O que verificar" + "Output" + "Regras" → 🟠 por secao faltante
5. **Referenciado no CLAUDE.md** na secao "Agents"? → 🟠 se nao

### Categoria 3 — Skills

Para cada skill core em `[spec-driven, research, definition-of-done, testing, code-quality, logging, docs-sync, security-review, mock-mode, golden-tests, api-testing, dependency-audit, context-fresh, execution-plan]` + condicionais `[dba-review, ux-review, seo-performance]` + slash commands `[quick, discuss, spec-creator, backlog-update, prd-creator, map-codebase, resume, pr]`:

1. **Arquivo existe** em `.claude/skills/{nome}/README.md` ou `SKILL.md`? → 🔴 para core, 🟡 para condicionais
2. **Framework-tag** presente? → 🟡 se nao
3. **Secao "Regras"** presente? → 🟡 se nao
4. **Referenciada no CLAUDE.md** na secao "Skills"? → 🟠 se nao

### Categoria 4 — Secoes do CLAUDE.md

Verificar presenca de cada H2 esperada:

| Secao H2 | Severidade se ausente | Skills/agents que dependem |
|---|---|---|
| Skills (mapeamento) | 🔴 critico | Todas as skills |
| Agents | 🔴 critico | Todos os agents |
| Comandos | 🔴 critico | verify.sh, testing |
| Specs e Requisitos | 🔴 critico | spec-creator, backlog-update |
| Regras de operacao | 🟠 alto | Todas |
| Mindset por dominio | 🟠 alto | Todas |
| Regras absolutas de seguranca | 🟠 alto | security-audit |
| Regras de codigo | 🟠 alto | code-quality |
| Testes | 🟠 alto | testing, coverage-check |
| Ordem de precedencia (skills) | 🟡 medio | — |
| Modelos para sub-agents | 🟡 medio | — |
| Verificacao proativa | 🟡 medio | — |
| Antes de commitar | 🟡 medio | definition-of-done |
| Estrutura | 🟡 medio | — |
| Padroes | 🟡 medio | — |
| Worktrees e subagents | 🟡 medio | — |
| Entrega via Pull Request | 🟠 alto | GIT_CONVENTIONS |
| Contexto de negocio | ⚪ info | — |

> O setup preserva secoes customizadas do CLAUDE.md existente. Se o CLAUDE.md ja existe, aplica como manual (diff + merge seletivo).

### Categoria 5 — Integridade de conteudo

1. **`{placeholders}` nao preenchidos** no CLAUDE.md — contar e listar os que ainda tem `{Adaptar:` ou `{placeholder}`. 🟡 cada
2. **Referencias dangling** — paths na secao Skills/Agents do CLAUDE.md que nao existem no disco. 🟠 cada
3. **Scripts sem permissao de execucao** (`verify.sh`, `reports.sh`). 🟡 cada
4. **SPECS_INDEX.md vazio** (sem nenhuma spec registrada). ⚪ info (normal pos-setup)
5. **Secao "Agents" no CLAUDE.md lista agent que nao existe** em `.claude/agents/`. 🟠 cada
6. **`.gitignore` sem entradas do framework** — verificar se `.claude/worktrees/` e `.claude/.update-backup/` estao no `.gitignore`. 🟠 se `.claude/worktrees/` falta (worktrees podem ser committed acidentalmente), 🟡 se `.claude/.update-backup/` falta. Se entradas faltam: sugerir adicionar e pedir confirmacao ao usuario.

### Categoria 6 — Relevancia de conteudo

> **Guard:** SKIP se zero skills condicionais instaladas (dba-review, ux-review, seo-performance) E CODE_PATTERNS esta vazio/null. Sem condicionais nem patterns, nao ha o que validar por relevancia. Registrar "⚪ Categoria 6: nao aplicavel (sem skills condicionais nem CODE_PATTERNS)".

Verificar se o conteudo gerado nas skills, agents, docs e CLAUDE.md **faz sentido para o projeto real**. Usar o perfil do projeto (stack, tipo, CODE_PATTERNS da Fase 1.6) para cruzar com o que foi instalado.

> **Regra critica: NUNCA resetar, limpar ou esvaziar um campo/secao.** Ao detectar conteudo inadequado, o fluxo e sempre:
> 1. Mostrar o conteudo atual (o que esta errado)
> 2. Gerar uma **sugestao concreta de substituicao** baseada no CODE_PATTERNS
> 3. Mostrar a sugestao ao usuario e pedir confirmacao
> 4. Aplicar **somente** se o usuario confirmar
>
> Se nao for possivel gerar sugestao concreta (falta informacao), perguntar ao usuario: "O que deveria estar aqui?" e esperar a resposta antes de tocar no conteudo.

#### 6.1 Exemplos de codigo incompativeis com a stack

Ler o conteudo das skills instaladas e verificar se os exemplos de codigo correspondem a stack real:

| Check | Severidade | Exemplo de mismatch |
|---|---|---|
| Skill `logging` usa exemplos de linguagem diferente da stack | 🟠 alto | Projeto Go com exemplos `console.error("[MODULE]", ...)` em JS |
| Skill `code-quality` tem grep patterns de outra linguagem | 🟠 alto | Projeto Python com `grep "function "` (sintaxe JS) |
| Skill `testing` referencia framework de teste errado | 🟠 alto | Projeto com Pytest mas skill menciona Jest |
| Skill `security-review` tem exemplos de validacao de outra stack | 🟡 medio | Projeto Go com exemplos de `express-validator` |
| Blocos de codigo no CLAUDE.md (secao "Padroes") em linguagem errada | 🟠 alto | Secao "Backend" com exemplos JS num projeto Go |

**Acao ao detectar:** gerar a sugestao concreta ANTES de perguntar. O usuario precisa ver exatamente o que vai ficar:

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

**Regras para gerar a sugestao:**
- Usar os exemplos reais encontrados no codigo (CODE_PATTERNS.logging.format, etc.)
- Se CODE_PATTERNS tem o import exato, usar no bloco de codigo
- Se CODE_PATTERNS tem os niveis/metodos, mapear 1:1 com a tabela existente
- Se nao tem informacao suficiente para gerar sugestao completa, **perguntar ao usuario** em vez de gerar parcial: "Detectei que voces usam `elogger`. Como e o formato de chamada? (ex: elogger.Error(ctx, msg, fields))"

#### 6.2 Libs e padroes divergentes dos detectados

Se CODE_PATTERNS foi preenchido na Fase 1.6, verificar se as skills usam as libs corretas:

| Check | Severidade | Exemplo |
|---|---|---|
| Skill `logging` usa lib generica mas projeto tem lib especifica | 🟠 alto | Skill usa `log.Printf` mas projeto usa `elogger` |
| Skill `code-quality` nao menciona lib de erros do projeto | 🟠 alto | Skill sugere `fmt.Errorf` mas projeto usa lib interna `erros` |
| CLAUDE.md "Regras de codigo" nao menciona libs obrigatorias do projeto | 🟡 medio | Nenhuma regra sobre usar `elogger` em vez de `fmt.Println` |
| Skill `security-review` nao conhece lib de validacao do projeto | 🟡 medio | Projeto usa `zod` mas skill tem exemplos de validacao manual |

**Acao ao detectar:** gerar regra concreta e mostrar antes de aplicar:

```
⚠️ A skill "code-quality" sugere `fmt.Errorf` para erros, mas o projeto usa a lib `erros`.
Detectei o padrao: erros.Wrap(err, "contexto") em 8 arquivos.

📄 Conteudo atual no CLAUDE.md "Regras de codigo":
  2. **Error handling explícito.** Erros específicos, nunca genéricos.

✏️ Sugestao — adicionar regras de consistencia ao CLAUDE.md:
  ```
  - **Logging:** usar `elogger` (github.com/your-org/backend-libs/elogger) — nunca `fmt.Println`, `log.Printf`
  - **Erros:** usar `erros.New()` / `erros.Wrap()` (ecommerce/app/src/errors) — nunca `fmt.Errorf()` ou `errors.New()` stdlib
  ```

✏️ Sugestao — adicionar check ao skill "code-quality":
  ```
  # Detectar uso de fmt.Errorf (proibido — usar erros.Wrap/erros.New)
  grep -rn "fmt\.Errorf" internal/ pkg/ --include="*.go" | grep -v _test.go | grep -v vendor
  ```

Opcoes:
1. Aplicar ambas sugestoes
2. Aplicar so CLAUDE.md
3. Aplicar so code-quality
4. Editar antes de aplicar — o que quer mudar?
5. Ignorar (vou configurar depois)
```

**Regras para gerar regras de consistencia:**
- Incluir o import path completo da lib (se detectado)
- Listar explicitamente o que e proibido (alternativas da stdlib)
- Se a lib tem alias ou padrao de inicializacao, documentar
- Se nao tem certeza se o uso e obrigatorio ou convencao, **perguntar**: "O uso de `erros` e obrigatorio (proibir `fmt.Errorf`) ou apenas recomendado?"

#### 6.3 Skills e agents irrelevantes para o tipo de projeto

Cruzar o perfil detectado (tipo de projeto, stack, features) com o que foi instalado:

| Check | Severidade | Condicao |
|---|---|---|
| `ux-review` instalada mas nao tem frontend | 🟠 alto | Tipo = backend/API/CLI/library sem frontend |
| `seo-performance` instalada mas nao tem frontend publico | 🟠 alto | Sem pages/, sem SSR, sem sitemap |
| `component-audit` agent instalado mas nao tem componentes | 🟠 alto | Sem React/Vue/Svelte/Angular |
| `seo-audit` agent instalado mas nao tem frontend publico | 🟡 medio | Backend puro |
| `dba-review` instalada mas nao tem DB | 🟡 medio | Sem migrations, sem ORM, sem schema |
| `product-review` agent instalado mas PRD nao ativo | 🟡 medio | Sem `.claude/prds/` |
| `golden-tests` skill mas nao tem golden tests | ⚪ info | Sem arquivos de golden test detectados |
| `mock-mode` skill mas nao tem integracoes externas | ⚪ info | Sem chamadas HTTP externas detectadas |

**Acao ao detectar:** perguntar com contexto:
```
⚠️ A skill "ux-review" foi instalada, mas o projeto parece ser backend puro (Go API).

Opcoes:
1. Remover — nao se aplica a este projeto
2. Manter — temos planos de frontend futuro
3. Manter — temos um frontend em outro repo que consome esta API
```

#### 6.4 Secoes do CLAUDE.md irrelevantes

Verificar se secoes do CLAUDE.md fazem sentido para o projeto:

| Check | Severidade | Condicao |
|---|---|---|
| Secao "TDD obrigatorio" com padrao e2e mas projeto e backend API | 🟡 medio | Backend sem browser/UI |
| Secao "Mindset Frontend" presente mas nao tem frontend | 🟡 medio | Tipo = backend/CLI |
| Secao "Mindset Banco de dados" presente mas nao tem DB | 🟡 medio | Sem DB detectado |
| Secao "Mindset UX" presente mas nao tem frontend | 🟡 medio | Tipo = backend/CLI/library |
| Padroes de "Frontend" na secao "Padroes" mas nao tem frontend | 🟡 medio | Tipo = backend |
| Padroes de "SQL" na secao "Padroes" mas nao tem DB | 🟡 medio | Sem DB |

**Acao ao detectar:** oferecer opcoes claras:
```
⚠️ O CLAUDE.md tem a secao "Mindset Frontend" e padroes de e2e testing,
mas o projeto parece ser backend Go puro.

Opcoes:
1. Remover secoes de frontend e e2e (recomendado para backend puro)
2. Manter — o projeto vai ter frontend em breve
3. Manter apenas "Mindset Frontend" mas remover e2e patterns
```

#### 6.5 Docs irrelevantes

| Check | Severidade | Condicao |
|---|---|---|
| `docs/ARCHITECTURE.md` instalado mas projeto e muito simples (1-2 dirs) | ⚪ info | Menos de 5 diretorios no src |
| `docs/ACCESS_CONTROL.md` instalado mas nao tem auth | ⚪ info | Sem middleware de auth, sem JWT, sem session |
| `docs/SECURITY_AUDIT.md` instalado mas nao tem endpoints publicos | ⚪ info | CLI/library sem API |

**Acao:** apenas informar (⚪), nao perguntar. O usuario decide se quer remover.

#### 6.6 Procedimento de remocao

Quando o usuario escolher "Remover" em qualquer check acima, a remocao deve ser **completa** — nao basta deletar o arquivo, todas as referencias tambem devem ser limpas:

1. **Deletar o arquivo** (skill, agent ou doc)
2. **Remover a linha correspondente na tabela de Skills ou Agents do CLAUDE.md** — nao deixar referencia dangling
3. **Remover de `SETUP_REPORT.md`** (se existir) — mover para secao "Removidos"
4. **Se a skill era referenciada em `verify.sh`** — remover ou comentar o check correspondente
5. **Se o agent era referenciado em outra skill** (ex: security-audit referenciado em security-review) — avisar que a referencia sera quebrada

**Antes de executar**, mostrar resumo do que sera removido:
```
Removendo skill "ux-review":
  - Deletar .claude/skills/ux-review/README.md
  - Remover linha 10 da tabela Skills no CLAUDE.md
  - Remover check "ux-review" do verify.sh (se existir)

Confirmar? [Sim/Nao]
```

**Regra:** nunca remover silenciosamente. Sempre listar tudo que sera afetado e pedir confirmacao.

#### Resumo da Categoria 6

Apos todos os checks, apresentar consolidado:

```
## Relevancia de conteudo

Encontrei {N} items que podem nao fazer sentido para o projeto:

### 🟠 Acao recomendada
1. Skill "logging" tem exemplos JS — projeto usa Go com elogger
2. Skill "code-quality" sugere fmt.Errorf — projeto usa lib erros
3. Skill "ux-review" instalada — projeto e backend puro

### 🟡 Revisar
4. CLAUDE.md tem secao "Mindset Frontend" — projeto e backend
5. CLAUDE.md tem padroes e2e — projeto e API

### ⚪ Informativo
6. docs/ARCHITECTURE.md pode nao ser necessario ainda

Quer resolver agora item por item? [Sim/Pular para depois]
```

Se "Sim": percorrer cada item 🟠 e 🟡, perguntar ao usuario com as opcoes descritas acima.
Se "Pular": registrar como pendencias manuais no SETUP_REPORT.md.

### Categoria 7 — Coerencia de customizacao

> **Guard:** SKIP se e primeiro setup (nao re-run nem update). No primeiro setup nada foi customizado — nao ha remocoes ou adaptacoes para validar. Registrar "⚪ Categoria 7: nao aplicavel (primeiro setup)".

Verificar que remocoes ou customizacoes feitas pelo projeto nao deixam referencias orfas:

#### 7.1 Se CLAUDE.md nao tem secao "TDD obrigatorio"

Verificar que skills `spec-driven`, `definition-of-done` e `execution-plan` nao exigem TDD incondicionalmente. Se exigem, avisar: "Projeto nao usa TDD, mas skills ainda referenciam TDD. Considerar ajustar as skills."

#### 7.2 Se CLAUDE.md nao tem secao "Worktrees e subagents" ou "Execucao por agents"

Verificar que skills `execution-plan` e `spec-driven` nao exigem delegacao a sub-agents incondicionalmente. Se exigem, avisar: "Projeto nao usa sub-agents, mas skills ainda referenciam delegacao. Confirmar se execution-plan deve ser seguido em modo sequencial."

#### 7.3 Para cada agent listado na tabela "Agents" do CLAUDE.md

Verificar que o arquivo `.claude/agents/{nome}.md` existe. Se nao existe, avisar: "Agent {nome} listado no CLAUDE.md mas arquivo nao encontrado."

#### 7.4 Para cada skill listada na tabela "Skills" do CLAUDE.md

Verificar que o path referenciado existe. Se nao existe, avisar: "Skill {path} listada no CLAUDE.md mas arquivo nao encontrado."

#### 7.5 Skills que referenciam agents removidos

Verificar que definition-of-done nao referencia agents que o projeto nao possui (ex: `security-audit` removido mas DoD ainda menciona).

### Categoria 8 — Deduplicacao de artefatos entre sub-projetos

> Para detalhes completos da Categoria 8, ver `MONOREPO_DETAILS.md` secao "Auditoria Categoria 8".

### Formato do output no SETUP_REPORT.md

```markdown
## Auditoria de completude

### Resumo
- 🔴 {N} criticos
- 🟠 {N} altos
- 🟡 {N} medios
- ⚪ {N} info

### Findings

#### 🔴 Criticos
{lista numerada dos findings criticos, se houver}

#### 🟠 Altos
{lista numerada dos findings altos, se houver}

#### 🟡 Medios
{lista numerada dos findings medios, se houver}

#### ⚪ Info
{lista numerada dos findings info, se houver}
```

Se houver 0 criticos e 0 altos: "✅ Setup completo — nenhum finding critico ou alto."

### Auto-fix

Apos listar os findings, oferecer correcao automatica para os que sao corrigiveis:

```
Posso corrigir automaticamente {N} dos {M} findings:
- Copiar {X} arquivos faltantes do framework source
- Inserir {Y} secoes faltantes no CLAUDE.md
- Adicionar {Z} referencias de agents/skills no CLAUDE.md
- Corrigir permissoes de {W} scripts

Aplicar correcoes? [Sim/Nao/Selecionar]
```

**Ordem de aplicacao:** (1) copiar arquivos faltantes do source, (2) inserir secoes faltantes no CLAUDE.md, (3) atualizar referencias de agents/skills, (4) corrigir permissoes de scripts.

Apos aplicar, re-rodar os checks afetados para confirmar resolucao.

**O que NAO corrige automaticamente** (precisa de input humano):
- `{placeholders}` — o usuario precisa preencher com dados reais do projeto
- Conteudo customizado ausente (regras de seguranca especificas, mindset por dominio)
- Esses ficam listados como "Pendencias manuais" no relatorio

### Pendencias manuais

Apos a auditoria e auto-fix, listar o que so o usuario pode resolver:

```markdown
## Pendencias manuais

### Prioridade alta
- [ ] Preencher {N} placeholders restantes no CLAUDE.md (listados acima)
- [ ] Revisar e customizar `scripts/verify.sh` para o projeto
- [ ] Criar primeira spec para feature em andamento

### Prioridade media
- [ ] Adicionar regras de seguranca especificas do dominio no CLAUDE.md
- [ ] Customizar mindset por dominio no CLAUDE.md
- [ ] Preencher docs/ com conteudo real do projeto

### Proximos passos recomendados

> ⚠️ **IMPORTANTE:** Skills instaladas durante esta sessao so ficam disponiveis como slash commands apos iniciar uma **nova sessao** (ou usar `/clear`). Isso e uma limitacao do Claude Code — ele carrega a lista de skills ao iniciar a sessao. Inicie uma sessao nova antes de usar `/spec`, `/backlog-update` ou qualquer outro slash command instalado.

1. **Agora:** revisar CLAUDE.md gerado e ajustar placeholders restantes
2. **Iniciar nova sessao** (ou `/clear`) para ativar os slash commands instalados
3. **Semana 1:** criar backlog inicial, primeira spec, rodar verify.sh
4. **Semana 2:** adicionar 2-3 skills de dominio, customizar checks
5. **Semana 3+:** evoluir progressivamente
6. **Quando o framework atualizar:** usar `/update-framework`
```

### 5c. Opcao de desfazer

Ao final, listar todos os arquivos criados/modificados e oferecer:

```
Arquivos criados neste setup:
- CLAUDE.md (novo)
- PROJECT_CONTEXT.md (novo)
- SPECS_INDEX.md (novo)
- .claude/specs/TEMPLATE.md (novo)
- .claude/specs/backlog.md (novo)
- .claude/skills/definition-of-done/README.md (novo)
- ... (lista completa)

Opcoes:
1. Manter tudo (recomendado)
2. Desfazer tudo (remover todos os arquivos criados)
3. Desfazer parcial (selecionar o que manter)
```

Se "desfazer tudo": remover todos os arquivos criados neste setup.
Se "desfazer parcial": perguntar quais manter e remover o resto.
