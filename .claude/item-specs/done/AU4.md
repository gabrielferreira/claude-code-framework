# AU4 — Crash recovery / skill `/resume`

**Plano:** [.claude/plans/vivid-brewing-rose.md](../plans/vivid-brewing-rose.md)

**Contexto:** quando uma sessão cai no meio de uma task (crash, timeout, context limit), a nova sessão precisa reconstruir o contexto manualmente. O STATE.md existe (CE3 ✅) mas não havia protocolo explícito de retomada — o Claude "adivinhava" onde estava.

**Abordagem:** skill `/resume` como slash command (`user_invocable: true`) com roteiro fixo de 4 passos:
1. Ler STATE.md seção "Execução ativa" — fase atual, entry/exit criteria, log de transições
2. Ler execution-plan (`{id}-plan.md`) se existir — tasks concluídas vs pendentes
3. Listar o que foi feito, o que falta e qual era o próximo passo
4. Perguntar ao dev se pode continuar ou se precisa de ajuste antes

Adicionalmente, foi criada lógica de "Renames" no update-framework e MANIFEST para migrar projetos existentes que tinham `resume/README.md` para `resume/SKILL.md` preservando customizações.

STATE.md não precisou de campos extras — a seção "Execução ativa" + "TODOs entre sessões" já cobrem o necessário para retomada.

**Critérios de aceitação:**
- [x] skill `/resume` existe em `.claude/skills/resume/SKILL.md` com `user_invocable: true`
- [x] protocolo de 4 passos implementado conforme abordagem acima
- [x] funciona mesmo quando execution-plan não existe (só STATE.md)
- [x] setup-framework e update-framework cientes da skill (auditoria de completude)
- [x] lógica de rename no update-framework para migração de projetos existentes

**Restrições:** não reconstruir contexto inventando — se STATE.md estiver incompleto, perguntar ao dev em vez de assumir.
