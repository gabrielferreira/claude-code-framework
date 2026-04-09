# CE2 — Waves paralelas

**Contexto:** execution-plans listavam tasks sem ordem de execução explícita. O Claude precisava inferir quais podiam rodar em paralelo, o que levava a execução sempre sequencial por cautela.

**Abordagem:** formalizar waves de execução derivadas do grafo de dependências. Tasks sem deps formam Wave 1; tasks cujas deps estão na Wave 1 formam Wave 2, etc. Tasks marcadas `[P]` dentro de uma wave podem rodar em paralelo se não compartilham arquivos (overlap analysis).

**Decisões chave:**
- Terminology unificada: "Fase" = agrupamento temático de features, "Wave" = ordem de execução dentro de um execution-plan
- Wave derivation explícito no execution-plan: tabela mostra qual wave cada task pertence e por quê
- Conexão direta com context-fresh: skill lê as waves para despachar sub-agentes na ordem correta
- `[P]` tag na task sinaliza paralelizável; overlap de arquivos impede paralelização mesmo com `[P]`

**Entregou:** atualização em `skills/execution-plan/README.md` e `skills/context-fresh/README.md`
