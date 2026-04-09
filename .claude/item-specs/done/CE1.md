# CE1 — Context-fresh execution

**Contexto:** execução de tasks em sessões longas acumulava contexto stale — o Claude tomava decisões baseadas em estado desatualizado. A solução foi separar orquestração (sessão principal) de execução (sub-agente com contexto limpo).

**Abordagem:** dois artefatos complementares:
- **`agents/task-runner.md`**: sub-agente que recebe um briefing auto-contido, executa uma única task e retorna relatório estruturado (PASS/PARTIAL/FAIL). Escopo estritamente delimitado — lê só os arquivos do briefing, nunca navega além.
- **`skills/context-fresh/README.md`**: protocolo de orquestração. Sessão principal lê o grafo de dependências, monta briefings focados por task, despacha para sub-agentes em waves (sequencial ou paralelo), rastreia conclusão e integra resultados.

**Decisões chave:**
- Briefing é auto-contido: inclui task, contexto mínimo de spec, arquivos a ler/modificar, escopo negativo, critérios de conclusão e contratos com outras tasks
- Falha com causa clara → re-despacho com briefing corrigido (1 retry); falha 2x → escalar para sessão principal
- STATE.md atualizado após cada task com status e arquivos modificados

**Entregou:** `agents/task-runner.md` + `skills/context-fresh/README.md`
