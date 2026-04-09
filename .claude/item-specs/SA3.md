# SA3 — Agent `debugger`

**Contexto:** quando uma falha acontece, o dev precisa montar manualmente o contexto (erro + arquivos relevantes + última mudança + histórico de tentativas) antes de pedir diagnóstico ao Claude. SA3 automatiza essa coleta — o dev passa o erro e o agent monta o pacote de diagnóstico.

**Abordagem:** agent read-only que, dado um ID de spec ou descrição de erro, coleta:
1. Stack trace / mensagem de erro (passado pelo dev ou lido de log)
2. Arquivos mencionados no erro ou relacionados à task em andamento (via STATE.md "Execução ativa")
3. Últimas mudanças relevantes (`git diff` ou `git log` dos arquivos envolvidos)
4. Tentativas anteriores registradas no STATE.md

Produz diagnóstico estruturado: causa provável, arquivos envolvidos, hipóteses ranqueadas, próximos passos sugeridos.

**Critérios de aceitação:**
- [ ] agent `debugger.md` em `.claude/agents/`
- [ ] coleta contexto automaticamente sem o dev precisar copiar/colar manualmente
- [ ] diagnóstico inclui: causa provável, evidências, hipóteses (ranqueadas), próximos passos
- [ ] funciona mesmo sem STATE.md (fallback para contexto mínimo do erro)
- [ ] CLAUDE.template.md referencia o agent na tabela de agents

**Restrições:** agent read-only (`worktree: false`). Diagnostica — não aplica fix. Se identificou a causa, o dev cria spec/task para corrigir.
