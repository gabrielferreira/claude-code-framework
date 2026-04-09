# TQ2 — Validate-tags em CI

**Contexto:** framework-tags (`<!-- framework-tag: vX.Y.Z -->`) já existiam nos arquivos distribuídos, mas não havia validação automática — era possível publicar uma release com tags inconsistentes ou desatualizadas.

**Abordagem:** confirmar e documentar que `scripts/validate-tags.sh` já rodava em PRs via `ci.yml`. O CI tem 6 jobs sequenciais:
1. **validate-tags**: verifica que todos os framework-tags apontam para a mesma versão que `VERSION`
2. **version-sync**: `VERSION` == `plugin.json` (raiz) == `plugin.json` (template)
3. **check-sync**: sources e templates em sincronia + completeness do MANIFEST
4. **test-setup**: simulação completa do setup (TQ1)
5. **migration-exists**: em tags `v*`, verifica que migration file existe desde a tag anterior
6. **notify**: em tag com sucesso, posta release notes no Google Chat webhook

**Decisões chave:**
- `fetch-depth: 0` no checkout para ter histórico de tags (necessário para migration-exists)
- Jobs sequenciais: falha em validate-tags não roda os jobs subsequentes
- Notify só dispara em push de tag (não em PR) — evita notificação em cada commit

**Entregou:** documentação do comportamento existente + confirmação no `ci.yml`
