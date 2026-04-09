# SW2 — Spec state machine

**Contexto:** specs não tinham status formal — uma spec "em andamento" era indistinguível de uma "rascunho" ou "concluída" a não ser lendo o conteúdo. Isso dificultava saber o que estava ativo e impedia gates explícitos antes de implementar.

**Abordagem:** formalizar ciclo de vida da spec com 5 estados e gates de transição:
- `rascunho` → `aprovada`: spec revisada, execution-plan criado se necessário
- `aprovada` → `em andamento`: gate confirma que spec está aprovada antes de implementar
- `em andamento` → `concluída`: verify passou, critérios de aceitação satisfeitos
- Edge states: `parcial` (implementação incompleta interrompida), `descontinuada` (cancelada com motivo)

**Decisões chave:**
- Tamanho determina fases obrigatórias: Pequeno pode ir direto `rascunho → em andamento → concluída`; Grande exige `rascunho → aprovada` com review explícito
- Status fica no header da spec (campo `status:`) — visível sem abrir o arquivo inteiro
- SPECS_INDEX.md reflete o status — permite ver o que está ativo de relance
- Transições registradas no STATE.md "Log de transições"

**Entregou:** atualização em `skills/spec-driven/README.md` e `specs/TEMPLATE.md`
