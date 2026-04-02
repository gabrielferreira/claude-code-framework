# Framework Manifest

> Classifica cada arquivo do framework por estratégia de atualização.
> Usado pelo `/update-framework` para saber como tratar cada arquivo ao atualizar um projeto.

## Estratégias

| Estratégia | Comportamento | Risco |
|---|---|---|
| **overwrite** | Substitui direto. Arquivo não tem customização de projeto. | Nenhum — conteúdo é genérico |
| **structural** | Compara estrutura (seções H2/H3). Mostra seções novas/removidas. Ignora conteúdo dentro das seções (customizado pelo projeto). | Baixo — só adiciona/remove seções |
| **manual** | Mostra diff completo. Nunca aplica sozinho. Requer decisão do usuário. | Médio — arquivo é altamente customizado |
| **skip** | Nunca toca. 100% conteúdo do projeto. | Nenhum — ignorado |

## Arquivos e estratégias

### Agents (overwrite)

Agents são genéricos — sem customização de projeto.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `.claude/agents/security-audit.md` | `agents/security-audit.md` | overwrite |
| `.claude/agents/spec-validator.md` | `agents/spec-validator.md` | overwrite |
| `.claude/agents/coverage-check.md` | `agents/coverage-check.md` | overwrite |
| `.claude/agents/backlog-report.md` | `agents/backlog-report.md` | overwrite |
| `.claude/agents/code-review.md` | `agents/code-review.md` | overwrite |
| `.claude/agents/component-audit.md` | `agents/component-audit.md` | overwrite |
| `.claude/agents/seo-audit.md` | `agents/seo-audit.md` | overwrite |
| `.claude/agents/product-review.md` | `agents/product-review.md` | overwrite |
| `.claude/agents/refactor-agent.md` | `agents/refactor-agent.md` | overwrite |
| `.claude/agents/test-generator.md` | `agents/test-generator.md` | overwrite |

### Skills (structural)

Skills têm `{placeholders}` substituídos por valores do projeto. Atualização preserva customização, adiciona seções novas, remove seções obsoletas.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `.claude/skills/spec-driven/README.md` | `skills/spec-driven/README.md` | structural |
| `.claude/skills/testing/README.md` | `skills/testing/README.md` | structural |
| `.claude/skills/definition-of-done/README.md` | `skills/definition-of-done/README.md` | structural |
| `.claude/skills/code-quality/README.md` | `skills/code-quality/README.md` | structural |
| `.claude/skills/docs-sync/README.md` | `skills/docs-sync/README.md` | structural |
| `.claude/skills/logging/README.md` | `skills/logging/README.md` | structural |
| `.claude/skills/ux-review/README.md` | `skills/ux-review/README.md` | structural |
| `.claude/skills/dba-review/README.md` | `skills/dba-review/README.md` | structural |
| `.claude/skills/mock-mode/README.md` | `skills/mock-mode/README.md` | structural |
| `.claude/skills/security-review/README.md` | `skills/security-review/README.md` | structural |
| `.claude/skills/seo-performance/README.md` | `skills/seo-performance/README.md` | structural |
| `.claude/skills/syntax-check/README.md` | `skills/syntax-check/README.md` | structural |
| `.claude/skills/golden-tests/README.md` | `skills/golden-tests/README.md` | structural |
| `.claude/skills/api-testing/README.md` | `skills/api-testing/README.md` | structural |
| `.claude/skills/dependency-audit/README.md` | `skills/dependency-audit/README.md` | structural |
| `.claude/skills/performance-profiling/README.md` | `skills/performance-profiling/README.md` | structural |
| `.claude/skills/backlog-update/SKILL.md` | `skills/backlog-update/SKILL.md` | structural |
| `.claude/skills/spec-creator/SKILL.md` | `skills/spec-creator/SKILL.md` | structural |
| `.claude/skills/prd-creator/SKILL.md` | `skills/prd-creator/SKILL.md` | structural |

### Docs (structural)

Docs têm conteúdo genérico do framework + customizações do projeto.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `docs/GIT_CONVENTIONS.md` | `docs/GIT_CONVENTIONS.md` | structural |
| `docs/ACCESS_CONTROL.md` | `docs/ACCESS_CONTROL.md` | structural |
| `docs/ARCHITECTURE.md` | `docs/ARCHITECTURE.md` | structural |
| `docs/SECURITY_AUDIT.md` | `docs/SECURITY_AUDIT.md` | structural |
| `docs/README.md` | `docs/README.md` | structural |
| `docs/SETUP_GUIDE.md` | `docs/SETUP_GUIDE.md` | structural |
| `docs/SPEC_DRIVEN_GUIDE.md` | `docs/SPEC_DRIVEN_GUIDE.md` | structural |
| `docs/QUICK_START.md` | `docs/QUICK_START.md` | structural |
| `docs/MIGRATION_GUIDE.md` | `docs/MIGRATION_GUIDE.md` | structural |
| `docs/TROUBLESHOOTING.md` | `docs/TROUBLESHOOTING.md` | structural |
| `docs/SKILLS_MAP.md` | `docs/SKILLS_MAP.md` | structural |
| `docs/NOTION_INTEGRATION.md` | `docs/NOTION_INTEGRATION.md` | structural |

### Scripts (manual)

Scripts podem ter checks evolutivos adicionados pelo projeto.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `scripts/verify.sh` | `scripts/verify.sh` | manual |
| `scripts/reports.sh` | `scripts/reports.sh` | manual |
| `scripts/reports-index.js` | `scripts/reports-index.js` | manual |
| `scripts/backlog-report.cjs` | `scripts/backlog-report.cjs` | manual |

### Scripts do framework (não copiados)

Estes scripts existem apenas no repo do framework. NAO são copiados para projetos.

| Path no framework | Propósito |
|---|---|
| `scripts/install-skills.sh` | Instala skills no ~/.claude/skills/ |
| `VERSION` | Versão atual do framework (semver) |
| `.gitignore` | Git ignore do repo do framework |
| `CHANGELOG.md` | Historico de versoes do framework |
| `scripts/validate-tags.sh` | Validacao de framework-tags pre-release |

### Projeto-específicos (skip)

Nunca tocados pelo update — conteúdo 100% do projeto.

| Path no projeto | Estratégia |
|---|---|
| `CLAUDE.md` | manual (mostrar diff do template, nunca aplicar automaticamente) |
| `PROJECT_CONTEXT.md` | manual (mostrar diff do template, perguntar) |
| `SPECS_INDEX.md` | skip |
| `.claude/specs/backlog.md` | skip |
| `.claude/specs/STATE.md` | skip |
| `.claude/specs/TEMPLATE.md` | overwrite |
| `.claude/specs/DESIGN_TEMPLATE.md` | overwrite |
| `.claude/specs/PRD_TEMPLATE.md` | structural |
| `.claude/specs/*.md` (specs do projeto) | skip |
| `.claude/specs/done/*.md` | skip |
| `.claude/SETUP_REPORT.md` | skip |

### Plugin (overwrite)

Manifesto do plugin para instalação via `claude plugin`.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `.claude-plugin/plugin.json` | `.claude-plugin/plugin.json` | overwrite |

### setup-framework (overwrite)

O próprio setup-framework e seus templates são atualizados direto.

| Path no projeto | Template source | Estratégia |
|---|---|---|
| `.claude/skills/setup-framework/` | `skills/setup-framework/` | overwrite (diretório inteiro) |
