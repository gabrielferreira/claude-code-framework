# TQ4 — Validação estrutural de skills e agents

**Contexto:** test-setup.sh verifica que os diretórios e alguns arquivos existem, mas não verifica se cada skill e agent tem a estrutura mínima correta. Um agent sem frontmatter obrigatório ou uma skill sem seções obrigatórias passaria no CI hoje.

**Abordagem:** Script `scripts/validate-structure.sh` que valida estaticamente cada arquivo de skill e agent — sem precisar do Claude Code. Roda no CI junto com validate-tags.sh e check-sync.sh.

**Critérios de aceitação:**
- [ ] Agents: frontmatter com os 4 campos obrigatórios (description, model, worktree, model-rationale)
- [ ] Agents: seções obrigatórias presentes (Quando usar, Input, O que verificar, Output, Regras)
- [ ] Skills: seções obrigatórias presentes (Quando usar, Quando NAO usar, Checklist, Regras)
- [ ] MANIFEST coverage: todo agent/skill no MANIFEST existe no template; todo arquivo no template está no MANIFEST
- [ ] Cross-ref: agents referenciados no CLAUDE.template.md existem como arquivo em agents/
- [ ] Script integrado ao CI (ci.yml)

**Restrições:** testes estáticos apenas — sem mock de MCP, sem execução real de skills.
