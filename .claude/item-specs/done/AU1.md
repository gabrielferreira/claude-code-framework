# AU1 — Stuck detection

**Contexto:** sem mecanismo explícito de detecção de loop, o Claude pode repetir a mesma ação N vezes sem progresso. AU1 força uma parada com diagnóstico quando isso acontece.

**Abordagem:** instrução no task-runner (CE1 ✅) — se a mesma ação foi tentada ≥3 vezes sem mudança de estado, interromper e reportar o blocker ao invés de continuar.

**Critérios de aceitação:**
- [ ] task-runner detecta loop (≥3 tentativas sem progresso) e para com diagnóstico estruturado
- [ ] diagnóstico inclui: o que foi tentado, quantas vezes, por que não avançou, próximos passos sugeridos
- [ ] comportamento testado em cenário de loop real

**Status:** dev em andamento (2026-04-09).
