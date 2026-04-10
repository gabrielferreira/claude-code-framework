# SA4 — Skill `/discuss`

**Contexto:** o fluxo atual vai direto de "quero fazer X" para `/spec`. Para features com gray areas ou domínio novo, isso gera specs mal definidas ou que precisam de muita iteração. SA4 é um passo anterior estruturado — não só conversa, mas scout + decisões + spec gerada ao final.

**Abordagem:** inspirado no `discuss-phase` do GSD, adaptado para o nosso fluxo:

1. Carregar `PROJECT_CONTEXT.md` + spec existente (se houver) para não re-discutir o que já está decidido
2. Scout rápido no codebase — padrões existentes, código reutilizável relacionado ao tema
3. Identificar gray areas automaticamente (ambiguidades, alternativas abertas, dependências não resolvidas)
4. Usuário escolhe quais gray areas explorar
5. Deep-dive em cada área selecionada até decisão clara
6. **Gerar spec direto** ao final — não um CONTEXT.md intermediário, mas o arquivo `.claude/specs/{id}.md` (ou página Notion) com as decisões já incorporadas

**Critérios de aceitação:**
- [x] skill `/discuss {ID} {Título}` em `.claude/skills/discuss/SKILL.md`
- [x] carrega PROJECT_CONTEXT.md e specs existentes antes de perguntar
- [x] faz scout no codebase para surfaçar padrões relevantes
- [x] apresenta gray areas e deixa o dev escolher o que explorar
- [x] gera spec completa ao final (dual-mode: repo + Notion)
- [x] spec gerada segue o mesmo fluxo do `/spec` (classificação de complexidade, validação pós-criação)

**Restrições:** não inventar decisões — se o dev não quis discutir uma gray area, deixar como placeholder na spec.
