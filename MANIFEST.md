# Framework Manifest

> Classifica cada arquivo do framework por estratégia de atualização e tier.
> Usado pelo `/update-framework` para saber como tratar cada arquivo ao atualizar um projeto.
> Usado pelo `/setup-framework` para filtrar arquivos por modo (light/full).

## Estratégias

| Estratégia | Comportamento | Risco |
|---|---|---|
| **overwrite** | Substitui direto. Arquivo não tem customização de projeto. | Nenhum — conteúdo é genérico |
| **structural** | Compara estrutura (seções H2/H3). Mostra seções novas/removidas. Ignora conteúdo dentro das seções (customizado pelo projeto). | Baixo — só adiciona/remove seções |
| **manual** | Mostra diff completo. Nunca aplica sozinho. Requer decisão do usuário. | Médio — arquivo é altamente customizado |
| **skip** | Nunca toca. 100% conteúdo do projeto. | Nenhum — ignorado |

## Tiers

| Tier | Significado |
|---|---|
| **core** | Instalado em light e full. Essencial para o framework funcionar. |
| **full** | Instalado apenas em full. Features avançadas, orchestration, PRDs, docs extensos. |
| **conditional** | Instalado se detectado (independente do modo). Ex: dba-review se DB detectado. |

## Arquivos e estratégias

### Agents (structural)

Agents podem ter customização de projeto: `{Adaptar:}` preenchidos pelo setup (ex: seo-audit, code-review) e frontmatter `model:` editado pelo projeto. Update preserva conteúdo customizado e adiciona seções novas.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `.claude/agents/security-audit.md` | `agents/security-audit.md` | structural | core |
| `.claude/agents/spec-validator.md` | `agents/spec-validator.md` | structural | core |
| `.claude/agents/coverage-check.md` | `agents/coverage-check.md` | structural | core |
| `.claude/agents/code-review.md` | `agents/code-review.md` | structural (`{Adaptar:}` para constantes de negócio) | core |
| `.claude/agents/test-generator.md` | `agents/test-generator.md` | structural | core |
| `.claude/agents/backlog-report.md` | `agents/backlog-report.md` | structural | full |
| `.claude/agents/component-audit.md` | `agents/component-audit.md` | structural | full |
| `.claude/agents/seo-audit.md` | `agents/seo-audit.md` | structural (`{Adaptar:}` para páginas públicas) | full |
| `.claude/agents/product-review.md` | `agents/product-review.md` | structural | full |
| `.claude/agents/refactor-agent.md` | `agents/refactor-agent.md` | structural | full |
| `.claude/agents/dx-audit.md` | `agents/dx-audit.md` | structural | full |
| `.claude/agents/performance-audit.md` | `agents/performance-audit.md` | structural | full |
| `.claude/agents/infra-audit.md` | `agents/infra-audit.md` | structural | full |
| `.claude/agents/task-runner.md` | `agents/task-runner.md` | structural | full |
| `.claude/agents/stuck-detector.md` | `agents/stuck-detector.md` | structural | full |
| `.claude/agents/debugger.md` | `agents/debugger.md` | structural | full |

### Skills (structural)

Skills têm `{placeholders}` substituídos por valores do projeto. Atualização preserva customização, adiciona seções novas, remove seções obsoletas.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `.claude/skills/spec-driven/README.md` | `skills/spec-driven/README.md` | structural | core |
| `.claude/skills/spec-creator/SKILL.md` | `skills/spec-creator/SKILL.md` | structural | core |
| `.claude/skills/backlog-update/SKILL.md` | `skills/backlog-update/SKILL.md` | structural | core |
| `.claude/skills/testing/README.md` | `skills/testing/README.md` | structural | core |
| `.claude/skills/definition-of-done/README.md` | `skills/definition-of-done/README.md` | structural | core |
| `.claude/skills/code-quality/README.md` | `skills/code-quality/README.md` | structural | core |
| `.claude/skills/logging/README.md` | `skills/logging/README.md` | structural | core |
| `.claude/skills/security-review/README.md` | `skills/security-review/README.md` | structural | core |
| `.claude/skills/pr/SKILL.md` | `skills/pr/SKILL.md` | structural | core |
| `.claude/skills/quick/SKILL.md` | `skills/quick/SKILL.md` | structural | core |
| `.claude/skills/resume/SKILL.md` | `skills/resume/SKILL.md` | structural | core |
| `.claude/skills/ux-review/README.md` | `skills/ux-review/README.md` | structural | conditional |
| `.claude/skills/dba-review/README.md` | `skills/dba-review/README.md` | structural | conditional |
| `.claude/skills/seo-performance/README.md` | `skills/seo-performance/README.md` | structural | conditional |
| `.claude/skills/docs-sync/README.md` | `skills/docs-sync/README.md` | structural | full |
| `.claude/skills/mock-mode/README.md` | `skills/mock-mode/README.md` | structural | full |
| `.claude/skills/golden-tests/README.md` | `skills/golden-tests/README.md` | structural | full |
| `.claude/skills/api-testing/README.md` | `skills/api-testing/README.md` | structural | full |
| `.claude/skills/dependency-audit/README.md` | `skills/dependency-audit/README.md` | structural | full |
| `.claude/skills/prd-creator/SKILL.md` | `skills/prd-creator/SKILL.md` | structural | full |
| `.claude/skills/context-fresh/README.md` | `skills/context-fresh/README.md` | structural | full |
| `.claude/skills/research/README.md` | `skills/research/README.md` | structural | full |
| `.claude/skills/execution-plan/README.md` | `skills/execution-plan/README.md` | structural | full |
| `.claude/skills/bug-investigation/SKILL.md` | `skills/bug-investigation/SKILL.md` | structural | full |
| `.claude/skills/map-codebase/SKILL.md` | `skills/map-codebase/SKILL.md` | structural | full |
| `.claude/skills/discuss/SKILL.md` | `skills/discuss/SKILL.md` | structural | full |
| `.claude/skills/onboarding/SKILL.md` | `skills/onboarding/SKILL.md` | structural | full |

### Docs (structural)

Docs têm conteúdo genérico do framework + customizações do projeto.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `docs/README.md` | `docs/README.md` | structural | core |
| `docs/GIT_CONVENTIONS.md` | `docs/GIT_CONVENTIONS.md` | structural | core |
| `docs/QUICK_START.md` | `docs/QUICK_START.md` | structural | core |
| `docs/SPEC_DRIVEN_GUIDE.md` | `docs/SPEC_DRIVEN_GUIDE.md` | structural | core |
| `docs/ACCESS_CONTROL.md` | `docs/ACCESS_CONTROL.md` | structural | full |
| `docs/ARCHITECTURE.md` | `docs/ARCHITECTURE.md` | structural | full |
| `docs/SECURITY_AUDIT.md` | `docs/SECURITY_AUDIT.md` | structural | full |
| `docs/SETUP_GUIDE.md` | `docs/SETUP_GUIDE.md` | structural | full |
| `docs/MIGRATION_GUIDE.md` | `docs/MIGRATION_GUIDE.md` | structural | full |
| `docs/TROUBLESHOOTING.md` | `docs/TROUBLESHOOTING.md` | structural | full |
| `docs/SKILLS_MAP.md` | `docs/SKILLS_MAP.md` | structural | full |
| `docs/NOTION_INTEGRATION.md` | `docs/NOTION_INTEGRATION.md` | structural | full |
| `docs/CONCEPTUAL_MAP.md` | `docs/CONCEPTUAL_MAP.md` | structural | full |
| `docs/SPEC_EXAMPLE.md` | `docs/SPEC_EXAMPLE.md` | structural | full |
| `docs/PRD_PORTABLE_PROMPT.md` | `docs/PRD_PORTABLE_PROMPT.md` | structural | full |
| `docs/BUG_INVESTIGATION_PORTABLE_PROMPT.md` | `docs/BUG_INVESTIGATION_PORTABLE_PROMPT.md` | structural | full |
| `docs/WORKFLOW_DIAGRAM.md` | `docs/WORKFLOW_DIAGRAM.md` | structural | full |
| `docs/PROTECT_BACKLOG_HOOK.md` | `docs/PROTECT_BACKLOG_HOOK.md` | structural | full |
| `docs/VERIFY_HOOK.md` | `docs/VERIFY_HOOK.md` | structural | full |
| `docs/SKILLS_GUIDE.md` | `docs/SKILLS_GUIDE.md` | structural | full |

### GitHub configs (structural)

Configuracoes do GitHub distribuidas para projetos. Projeto pode customizar conteudo dentro das secoes.

| Path no projeto | Template source | Estrategia | Tier |
|---|---|---|---|
| `.github/pull_request_template.md` | `.github/pull_request_template.md` | structural | core |

### Renames

Arquivos renomeados entre versões. O update-framework aplica automaticamente: migra customizações do path antigo para o novo via merge structural, depois remove o antigo.

| Desde | Path antigo no projeto | Path novo no projeto | Motivo |
|-------|----------------------|---------------------|--------|
| v2.34.0 | `.claude/skills/resume/README.md` | `.claude/skills/resume/SKILL.md` | Convertido para slash command `/resume` |

### Scripts (manual)

Scripts podem ter checks evolutivos adicionados pelo projeto.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `scripts/verify.sh` | `scripts/verify.sh` | manual | core |
| `scripts/reports.sh` | `scripts/reports.sh` | manual | full |
| `scripts/reports-index.js` | `scripts/reports-index.js` | manual | full |
| `scripts/backlog-report.cjs` | `scripts/backlog-report.cjs` | manual | full |

### Migrations (overwrite)

Guias de migracao manual entre versoes — como migrations de banco de dados, mas para o framework. Gerados automaticamente durante o release.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `migrations/README.md` | `migrations/README.md` | overwrite | core |

> **Nota:** Setup copia apenas `migrations/README.md`. Arquivos `v{X}-to-v{Y}.md` NAO sao copiados pelo setup — projeto novo nao tem historico a migrar. O update copia seletivamente os migrations do gap atual (versao instalada → versao nova) e remove migrations antigas do projeto.

### Scripts do framework (não copiados)

Estes scripts existem apenas no repo do framework. NAO são copiados para projetos.

| Path no framework | Propósito |
|---|---|
| `scripts/install-skills.sh` | Instala skills no ~/.claude/skills/ |
| `VERSION` | Versão atual do framework (semver) |
| `.gitignore` | Git ignore do repo do framework |
| `CHANGELOG.md` | Historico de versoes do framework |
| `BACKLOG.md` | Backlog de evolução do framework |
| `scripts/validate-tags.sh` | Validacao de framework-tags pre-release |
| `scripts/check-sync.sh` | Validacao de sincronia source-template |
| `scripts/test-setup.sh` | Teste automatizado de simulacao do setup |
| `.claude/item-specs/` | Specs detalhadas de itens do backlog — interno do repo do framework |
| `CLAUDE.template.md` | Fonte do template de CLAUDE.md — distribuido para projetos como `CLAUDE.md` |
| `SPECS_INDEX.template.md` | Fonte do template de SPECS_INDEX — distribuido para projetos como `SPECS_INDEX.md` |
| `SPECS_INDEX_ARCHIVE.template.md` | Fonte do template de SPECS_INDEX_ARCHIVE — distribuido para projetos como `SPECS_INDEX_ARCHIVE.md` |
| `migrations/MIGRATION_TEMPLATE.md` | Template para criar migrations — apenas para devs do framework, nao distribuido |
| `migrations/v{X}-to-v{Y}.md` | Gerados por release — distribuidos seletivamente pelo update (gap da versao atual) |

### Projeto-específicos (skip)

Nunca tocados pelo update — conteúdo 100% do projeto.

| Path no projeto | Estratégia | Tier |
|---|---|---|
| `CLAUDE.md` | manual (mostrar diff do template, nunca aplicar automaticamente) | core |
| `PROJECT_CONTEXT.md` | manual (mostrar diff do template, perguntar) | core |
| `SPECS_INDEX.md` | skip | core |
| `SPECS_INDEX_ARCHIVE.md` | skip | core |
| `.claude/specs/backlog.md` | skip | core |
| `.claude/specs/STATE.md` | manual (mostrar diff da estrutura nova, nunca aplicar automaticamente — contém estado do projeto) | core |
| `.claude/specs/TEMPLATE.md` | structural (projeto pode ter adicionado seções custom ao template) | core |
| `.claude/specs/DESIGN_TEMPLATE.md` | structural (projeto pode ter adicionado seções custom ao template) | full |
| `.claude/specs/backlog-format.md` | structural (projeto customiza Fases, Camadas e pode adicionar colunas) | full |
| `.claude/specs/*.md` (specs do projeto) | skip | — |
| `.claude/specs/done/*.md` | skip | — |
| `.claude/prds/PRD_TEMPLATE.md` | structural | full |
| `.claude/bugs/BUG_REPORT_TEMPLATE.md` | structural | full |
| `.claude/bugs/*.md` (reports do projeto) | skip | — |
| `.claude/prds/PRDS_INDEX.md` | skip | full |
| `.claude/prds/*.md` (PRDs do projeto) | skip | — |
| `.claude/prds/done/*.md` | skip | — |
| `.claude/SETUP_REPORT.md` | skip | — |

### Plugin (overwrite)

Manifesto do plugin para instalação via `claude plugin`.

| Path no projeto | Template source | Estratégia | Tier |
|---|---|---|---|
| `.claude-plugin/plugin.json` | `.claude-plugin/plugin.json` | overwrite | core |
| `.claude-plugin/marketplace.json` | `.claude-plugin/marketplace.json` | overwrite | core |

### Skills de gestao do framework (NAO copiadas para o projeto)

`setup-framework` e `update-framework` sao skills de gestao do framework — servem para configurar/atualizar, nao fazem parte do dia a dia do projeto. **NAO devem ser copiadas para `.claude/skills/` do projeto.**

Ficam disponiveis via:
- `~/.claude/skills/` (pessoal, via `install-skills.sh`)
- Plugin compartilhado (`.claude-plugin/plugin.json` referencia `skills/` do framework)
