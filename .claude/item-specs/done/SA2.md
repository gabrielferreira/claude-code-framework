# SA2 — Agent `plan-checker`

**Contexto:** o fluxo atual (spec → execution-plan → implementar) não tem gate que valide se o plano cobre os requirements da spec. É possível chegar na implementação com gaps — RFs não endereçados ou critérios de aceitação que nenhuma task vai bater.

**Abordagem:** agent que lê spec + execution-plan e verifica cobertura. Dois pontos de uso:
1. **Integrado ao spec-validator**: spec-validator chama plan-checker automaticamente quando o execution-plan existe — parte do fluxo padrão de validação antes de implementar
2. **Standalone**: chamável diretamente (`/plan-checker {ID}`) quando o dev quiser verificar o plano manualmente sem rodar o spec-validator completo

O agent compara cada RF e critério de aceitação da spec contra as tasks do execution-plan. Reporta: ✅ coberto | ⚠️ parcialmente coberto (qual task, qual gap) | ❌ não coberto.

**Critérios de aceitação:**
- [ ] agent `plan-checker.md` em `.claude/agents/`
- [ ] spec-validator invoca plan-checker quando `{id}-plan.md` existe
- [ ] output: tabela RF/critério × cobertura, com gaps explícitos
- [ ] funciona mesmo sem execution-plan (reporta que não há plano para validar)
- [ ] CLAUDE.template.md referencia o agent na tabela de agents

**Restrições:** agent read-only (`worktree: false`). Reporta gaps — não corrige o plano sozinho.
