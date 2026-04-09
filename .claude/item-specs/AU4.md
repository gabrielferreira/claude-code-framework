# AU4 — Crash recovery / skill `/resume`

**Contexto:** quando uma sessão cai no meio de uma task (crash, timeout, context limit), a nova sessão precisa reconstruir o contexto manualmente. O STATE.md existe (CE3 ✅) mas não há protocolo explícito de retomada — o Claude "adivinha" onde estava.

**Abordagem:** criar skill `/resume` que executa um roteiro fixo:
1. Ler STATE.md seção "Execução ativa" — fase atual, entry/exit criteria, log de transições
2. Ler execution-plan (`{id}-plan.md`) se existir — tasks concluídas vs pendentes
3. Listar o que foi feito, o que falta e qual era o próximo passo
4. Perguntar ao dev se pode continuar ou se precisa de ajuste antes

Avaliar durante implementação se STATE.md precisa de campos extras (ex: último arquivo editado, último comando rodado). Se precisar, atualizar STATE.md e documentar como `⚠️ Migrável`.

**Critérios de aceitação:**
- [ ] skill `/resume` existe em `.claude/skills/resume/README.md`
- [ ] protocolo de 4 passos implementado conforme abordagem acima
- [ ] funciona mesmo quando execution-plan não existe (só STATE.md)
- [ ] setup-framework e update-framework cientes da skill (auditoria de completude)

**Restrições:** não reconstruir contexto inventando — se STATE.md estiver incompleto, perguntar ao dev em vez de assumir.
