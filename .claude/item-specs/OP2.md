# OP2 — Remover arquivos dead-weight distribuídos para projetos

**Contexto:** O setup copia para o projeto uma série de arquivos que se tornam inúteis após a instalação inicial. Eles acumulam, criam confusão e, no caso das migrations, crescem indefinidamente a cada release. A lista foi identificada em análise do `skills/setup-framework/templates/`.

**Abordagem:** Auditar cada arquivo distribuído e remover do MANIFEST (ou mudar para `skip`) os que não têm utilidade no projeto após o setup. Para projetos existentes, o update-framework deve informar quais arquivos podem ser deletados (migration guide).

**Arquivos candidatos a remover da distribuição:**

| Arquivo no projeto | Problema |
|---|---|
| `CLAUDE.template.md` | Cópia idêntica ao `CLAUDE.md` inicial — ninguém consulta depois. Não aparece no MANIFEST como estratégia explícita. |
| `SPECS_INDEX.template.md` | Mesmo caso: referência que ninguém usa pós-setup. |
| `.claude/skills/setup-framework/SKILL.md` | Skill de setup — roda uma vez, depois é lixo. O projeto não precisa do setup depois de configurado. |
| `migrations/MIGRATION_TEMPLATE.md` | Template para criar migrations — só relevante para quem desenvolve o framework, não para quem usa. |
| `migrations/v{X}-to-v{Y}.md` históricos | Migrations já aplicadas acumulam indefinidamente. Projeto só precisa das migrations que ainda não aplicou. |

**Efeito colateral positivo no repo-fonte:** Se `CLAUDE.template.md` parar de ir pro projeto, `templates/` só precisa de `templates/CLAUDE.md`. A duplicação `templates/CLAUDE.md` + `templates/CLAUDE.template.md` (os "dois mirrors" do TASK_CHECKLIST) some — vira um só mirror.

**Alternativas descartadas:**
- Manter tudo: gera ruído acumulado e projetos cada vez mais inchados
- Só documentar: não resolve — devs não limpam o que não sabem que pode sumir

**Critérios de aceitação:**
- [ ] `CLAUDE.template.md` removido da distribuição — MANIFEST atualizado, `templates/CLAUDE.template.md` deletado do repo-fonte, TASK_CHECKLIST atualizado (remover nota "dois mirrors")
- [ ] `SPECS_INDEX.template.md` removido da distribuição — verificar se setup ainda usa para gerar `SPECS_INDEX.md` ou se pode ser eliminado por completo
- [ ] `skills/setup-framework/SKILL.md` removido da distribuição — MANIFEST atualizado
- [ ] `migrations/MIGRATION_TEMPLATE.md` removido da distribuição — MANIFEST atualizado
- [ ] Migrations históricas: setup copia todas (comportamento atual, ok para setup limpo); update-framework para de copiar migrations já existentes no projeto (evitar acúmulo)
- [ ] Migration guide para projetos existentes: listar arquivos que podem ser deletados com segurança
- [ ] `check-sync.sh` e `test-setup.sh` atualizados para refletir o novo conjunto de arquivos distribuídos

**Restrições:**
- Não remover arquivos que o update-framework usa como referência para diff (ex: se `CLAUDE.template.md` for usado para comparar com `CLAUDE.md` do projeto — verificar antes)
- Migrations novas (ainda não aplicadas) devem continuar chegando ao projeto via update-framework
