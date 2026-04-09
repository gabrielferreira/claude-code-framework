# SW5 — Task graph com dependências

**Contexto:** execution-plans listavam tasks como lista plana sem dependências explícitas. O Claude não sabia quais tasks bloqueavam quais, o que impedia paralelização segura e gerava execução sempre sequencial.

**Abordagem:** adicionar seção "Grafo de dependências" no TEMPLATE.md com tabela estruturada:

| Task | Depende de | Arquivos | Tipo | Paralelizável? |
|---|---|---|---|---|
| T1 | — | `src/auth.ts` | implementação | não |
| T2 | T1 | `src/auth.ts`, `tests/auth.test.ts` | teste | sim (com T3) |

**Decisões chave:**
- IDs de task (T1, T2...) referenciáveis entre si — explícito quem bloqueia quem
- Arquivos listados por task: permite detectar overlap antes de paralelizar
- Tipo distingue implementação / teste / integração / config — útil para ordenar (testes depois de impl)
- `Paralelizável?` field é a entrada para wave assignment no execution-plan
- Grafo alimenta context-fresh: skill lê o grafo para montar waves de despacho para sub-agentes

**Entregou:** atualização em `specs/TEMPLATE.md` e `skills/execution-plan/README.md`
