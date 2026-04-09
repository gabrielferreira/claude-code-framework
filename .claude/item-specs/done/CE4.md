# CE4 — Research phase

**Contexto:** para features grandes ou com domínio desconhecido, o Claude planejava sem investigar o codebase — gerando execution-plans com pressupostos errados sobre código existente, padrões e riscos.

**Abordagem:** skill `/research` com investigação estruturada em 6 eixos antes de planejar:
1. Stack e convenções do projeto
2. Código existente relevante para a feature
3. Padrões reutilizáveis
4. Dependências externas e integrações
5. Riscos e restrições
6. Gaps de conhecimento que precisam de decisão

Produz `{id}-research.md` salvo em `.claude/specs/` — artefato temporário que alimenta spec, design doc e execution-plan.

**Decisões chave:**
- Research é descartável: serve para planejamento, não é documentação permanente do projeto
- Escopo: investigar o necessário para planejar, não mapear o projeto inteiro (~40% do budget de contexto)
- Não toma decisões finais — sugere com alternativas; decisões ficam na spec
- Bugs encontrados durante research vão para STATE.md "Blockers", não são corrigidos no meio da investigação
- Integração com spec-driven: fase `research` é obrigatória para specs Grande e Complexo

**Entregou:** `skills/research/README.md`
