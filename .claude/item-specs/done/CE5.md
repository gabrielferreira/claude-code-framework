# CE5 — Refinar critérios de classificação "Pequeno"

**Contexto:** o critério `<30min` para classificar uma spec como "Pequeno" era subjetivo e inconsistente — varia por dev, por familiaridade com o codebase, e o Claude não consegue estimar tempo de forma confiável.

**Abordagem:** substituir `<30min` por critérios estruturais objetivos:
- `≤3 arquivos` modificados
- `sem nova abstração` (sem nova classe, interface, módulo, hook)
- `sem mudança de schema` (sem migration, sem alteração de tipos públicos)
- `sem regra de negócio nova` (em alguns contextos)

**Escopo da mudança:** 23 arquivos atualizados — spec-creator (repo e Notion mode), spec-driven, execution-plan, prd-creator, CLAUDE.template.md (+ 2 mirrors), docs (SPEC_DRIVEN_GUIDE, CONCEPTUAL_MAP, SETUP_GUIDE, WORKFLOW_DIAGRAM), specs/backlog-format.md, README.md.

**Decisões chave:**
- Preservar "Bug urgente em produção (<30min)" — ali o `<30min` é urgência, não classificação de complexidade
- Critério estrutural é verificável pelo Claude antes de começar — não depende de estimativa
- Template de spec Pequeno continua curto; o critério só muda o que determina "Pequeno"

**Entregou:** atualização em 23 arquivos (sources + templates)
