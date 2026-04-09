# SW7 — Seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md

**Contexto:** formalizar um lugar para restrições não-negociáveis do projeto (stack fixo, padrões obrigatórios, decisões arquiteturais) que toda spec e plan deve respeitar.

**Abordagem:** não criar arquivo separado (constitution file). Adicionar seção `## Restrições inegociáveis` no PROJECT_CONTEXT.md existente. Documentar na skill spec-creator que essa seção deve ser consultada antes de propor mudanças.

**Critérios de aceitação:**
- [ ] `PROJECT_CONTEXT.md` (source + template) tem seção `## Restrições inegociáveis` com exemplos
- [ ] spec-creator instrui a consultar essa seção antes de criar spec
- [ ] update-framework oferece a seção para projetos existentes via structural merge

**Restrições:** separar em arquivo próprio só se crescer demais (DF6 já removido — decisão tomada).
