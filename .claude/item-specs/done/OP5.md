# OP5 — STATE.md gitignored por padrão (isolamento multi-dev)

**Plano:** [/Users/gabrielferreira/.claude/plans/como-o-framework-lida-drifting-cocoa.md](../../../../../.claude/plans/como-o-framework-lida-drifting-cocoa.md) (pessoal — não distribuído)

**Contexto:** `.claude/specs/STATE.md` é memória persistente da sessão (item em andamento, fase, próximos passos). Hoje o setup copia o template e o arquivo é commitado, pois não está no gitignore distribuído. Em projetos com vários devs, isso gera conflito de merge garantido (toda PR mexe no mesmo arquivo) e contaminação de contexto (o Claude do dev A pode agir sobre o item em andamento do dev B ao iniciar sessão). `.claude/plans/` já é gitignored desde versões anteriores; o princípio só precisa ser estendido a STATE.md e documentado uma vez.

**Abordagem:**
1. Adicionar `.claude/specs/STATE.md` ao bloco de entradas obrigatórias do gitignore no `setup-framework/SKILL.md`.
2. No `update-framework/SKILL.md`: nova subseção 1.2b detecta `git ls-files .claude/specs/STATE.md` e marca como migração pendente; subseção 3.7 faz append da entrada no `.gitignore` do projeto sem executar `git rm --cached` (coordenação social, não automação).
3. Atualizar regra #6 do `CLAUDE.template.md` (e mirrors em `templates/` e `templates-light/`) explicitando que STATE.md e `.claude/plans/` são pessoais por dev.
4. Atualizar MANIFEST.md descrevendo a nova estratégia (mantém `manual` + nota sobre gitignore).

**Alternativas descartadas:**
- STATE por dev (`STATE.{git-user}.md`) ou por branch — adiciona complexidade de naming sem benefício real, já que o arquivo é local e ephemeral por natureza.
- Gerar o conteúdo via tooling externo — escopo de framework, não de produto.
- Aplicar o mesmo princípio ao próprio repo do framework — escopo limitado a projetos downstream; o repo do framework mantém `.claude/plans/` commitados como referência de design (público restrito ao mantenedor).

**Critérios de aceitação:**
- [ ] `setup-framework/SKILL.md` lista `.claude/specs/STATE.md` no bloco de entradas obrigatórias do gitignore
- [ ] `update-framework/SKILL.md` tem subseção 1.2b (detecção) e 3.7 (append no gitignore + comandos manuais de migração)
- [ ] `MANIFEST.md` linha de STATE.md descreve estratégia atualizada
- [ ] `CLAUDE.template.md` + `templates/CLAUDE.md` + `templates-light/CLAUDE.md` regra #6 menciona "pessoal por dev (gitignored)" para STATE.md e `.claude/plans/`
- [ ] `bash scripts/check-sync.sh` passa
- [ ] `bash scripts/validate-tags.sh` passa
- [ ] Smoke test em projeto novo: STATE.md criado e em `.gitignore`; `git status` não lista
- [ ] Smoke test em projeto antigo (STATE.md trackeado): update reporta migração pendente, mostra `git rm --cached` sem executar, appenda no `.gitignore`

**Restrições:**
- `/update-framework` **não executa** `git rm --cached` automaticamente — afeta a working tree de outros devs, exige coordenação manual
- Não alterar o conteúdo do STATE.md em si — segue `manual` no MANIFEST
- Não tocar no repo do framework (`.gitignore` local, política de plans interna do mantenedor)
- Migration `v{ANT}-to-v{NOVA}.md` e bump de versão são feitos no commit de release separado (após merge), conforme padrão do projeto
