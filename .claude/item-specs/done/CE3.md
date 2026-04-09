# CE3 — Resume/state machine

**Contexto:** ao retomar trabalho após interrupção, o Claude reconstruía contexto do zero — o que levava a duplicação de trabalho ou decisões inconsistentes com o que já havia sido feito.

**Abordagem:** dois artefatos:
- **`specs/STATE.md`**: memória persistente entre sessões. Seção "Execução ativa" registra item em andamento, fase atual, entry/exit criteria, contagem de tasks e log de transições. Seções auxiliares: decisões arquiteturais, blockers, lições aprendidas, ideias adiadas.
- **Gates em `skills/spec-driven/README.md`**: transições de fase explícitas (research → plan → execute → verify → done) com critérios de entrada e saída verificáveis. Tamanho da spec determina quais fases são obrigatórias.

**Decisões chave:**
- STATE.md é single file — fácil de ler inteiro no início de sessão
- Log de transições (De/Para/Quando/Motivo) resolve ambiguidade sobre onde se está no fluxo
- Ideias fora do escopo vão para "Ideias adiadas" — não são implementadas nem descartadas silenciosamente
- Entry/exit criteria por fase: evita avançar sem evidência de que a fase anterior está completa

**Entregou:** `specs/STATE.md` + atualização em `skills/spec-driven/README.md`
