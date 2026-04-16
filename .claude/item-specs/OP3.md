# OP3 — Unificar templates-light em versão condicional

**Contexto:** MO9 (Light Edition) cria `templates-light/` com 4 skills simplificadas (spec-driven, spec-creator, backlog-update, definition-of-done) que são versões alternativas das mesmas skills em `templates/`. Manter dois conjuntos separados cria risco de divergência silenciosa — quando a versão full é atualizada, a versão light pode ficar desatualizada sem ninguém perceber. É o mesmo problema que MR6 resolve para sub-projetos, mas agora dentro do próprio framework.

**Problema concreto:**
- Ao editar `skills/spec-creator/SKILL.md` (full), o dev precisa lembrar de atualizar `templates-light/.claude/skills/spec-creator/SKILL.md` manualmente
- `check-sync.sh` valida source↔template, mas não valida templates-light↔templates (seções compartilhadas)
- Com o tempo, as versões light divergem das full em comportamento — bugs corrigidos no full podem não ser propagados para o light

**Abordagem proposta:** migrar de 2 arquivos separados para 1 arquivo com lógica condicional por modo. Cada skill detecta o modo (via `<!-- framework-mode: light -->` no CLAUDE.md ou `> Modo:` no SETUP_REPORT.md) e ajusta comportamento:

```
Se modo = light:
  - Pular passos de Notion, monorepo, delta markers, sub-agents
  - Usar formato simplificado (5 colunas no backlog, 6 seções na spec)
  - Classificação só Pequeno/Médio (sem Grande/Complexo)
Senão:
  - Comportamento full atual
```

**Alternativas descartadas:**
- Manter duplicado com check-sync estendido — resolve detecção mas não resolve o trabalho manual de sync
- Gerar templates-light automaticamente a partir do full — complexidade de tooling vs benefício

**Critérios de aceitação:**
- [ ] 4 skills (spec-driven, spec-creator, backlog-update, definition-of-done) existem em versão única
- [ ] Cada skill detecta modo e ajusta comportamento condicionalmente
- [ ] `templates-light/` removido ou reduzido a apenas arquivos que são completamente diferentes (CLAUDE.md, TEMPLATE.md, backlog.md, STATE.md)
- [ ] Comportamento idêntico ao atual em ambos os modos (regressão zero)
- [ ] check-sync.sh não precisa mais validar skills duplicadas

**Restrições:**
- Skills condicionais não devem ficar ilegíveis — usar seções claras `### Modo light` / `### Modo full` ou guards no início de cada passo
- Arquivos que são 100% diferentes entre modos (CLAUDE.md, TEMPLATE.md, backlog.md, STATE.md) continuam em templates-light/ — esses não têm lógica compartilhada suficiente para justificar merge

**Deps:** MO9 (precisa existir para ter o que unificar)
