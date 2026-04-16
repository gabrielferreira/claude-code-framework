# PF6 — Auditoria seletiva

**Contexto:** a Fase 5b (auditoria de completude) roda 8 categorias sempre, em ambos setup e update. Muitas são irrelevantes: Categoria 8 (deduplicação) em single-repo, Categoria 6 (relevância) sem skills condicionais, Categoria 7 (coerência) em setup primeiro-run. Cada categoria consome 30s-2min.

**Abordagem:** adicionar guard explícito (condição de skip) no início de cada categoria. Se guard não satisfeito → skip com nota informativa.

**Guards por categoria:**

| Categoria | Guard (skip se...) | Nota quando skip |
|---|---|---|
| 1 — Existência de arquivos | NUNCA skip | — |
| 2 — Agents | NUNCA skip | — |
| 3 — Skills | NUNCA skip | — |
| 4 — Seções CLAUDE.md | NUNCA skip | — |
| 5 — Integridade de conteúdo | NUNCA skip | — |
| 6 — Relevância de conteúdo | Skip se zero skills condicionais instaladas E zero CODE_PATTERNS detectados | "⚪ Cat. 6: não aplicável (sem skills condicionais nem patterns)" |
| 7 — Coerência de customização | Skip se é primeiro setup (não update/re-run) | "⚪ Cat. 7: não aplicável (primeiro setup, nada customizado)" |
| 8 — Deduplicação de artefatos | Skip se `## Monorepo` não existe E < 2 sub-projetos | "⚪ Cat. 8: não aplicável (single-repo)" |

**Economia estimada:** em setup first-run single-repo sem condicionais: pula Cat 6, 7, 8 = ~3-5 min economizados. Em update de single-repo: pula Cat 8 = ~1-2 min.

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Fase 5b — guard por categoria |
| `skills/update-framework/SKILL.md` | Fase 5b — mesmos guards |
| Mirrors | Sync |

**Critérios de aceitação:**
- [x] Cada categoria tem guard documentado no início
- [x] Guard avaliado ANTES de rodar a categoria (não depois)
- [x] Skip produz nota "⚪ Cat. N: não aplicável ({motivo})" no report
- [x] Categorias 1-5 NUNCA skip (são essenciais)
- [x] Setup e update usam os MESMOS guards (idênticos)
- [x] Zero perda de detecção — guards só eliminam checks impossíveis de produzir findings

**Restrições:**
- Guards são conservadores — na dúvida, rodar a categoria
- Se Categoria 6 tem skills condicionais instaladas mas CODE_PATTERNS vazio → rodar Cat 6 (pode detectar mismatch)

**Deps:** nenhuma (independente)
