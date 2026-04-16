# OP4 — `scripts/release.sh` para automatizar release

**Contexto:** o processo de release descrito em `CLAUDE.md` tem ~14 passos manuais: bumpar VERSION, plugin.json, marketplace.json (três arquivos com a mesma versão), rodar `sed` global em todos os `.md` para atualizar `framework-tag:` (excluindo `migrations/`), sincronizar templates após o `sed` (senão só os sources ficam atualizados), gerar scaffold de migration, commit, tag. Cada release é território de erro humano: esquecer um JSON, esquecer sincronizar template light, rodar `sed` diferente entre macOS e Linux. Auditoria de 2026-04-16 marcou como item fraco mas legítimo (🟡), e o usuário aprovou execução.

**Abordagem:** script único `scripts/release.sh` que reduz o processo manual a 3 passos:
1. `bash scripts/release.sh {major|minor|patch|vX.Y.Z}` — bump + sed + sincronia + migration scaffold + validação
2. Dev revisa o migration gerado e completa partes manuais (content patches, breaking changes)
3. Dev faz commit + tag manualmente (push continua manual, conforme política existente)

O que o script faz:
- Lê `VERSION` atual e calcula `NEW_VERSION` conforme argumento (suporta `major`, `minor`, `patch` ou versão literal `vX.Y.Z`)
- Atualiza `VERSION`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` e as duas cópias em `skills/setup-framework/templates/.claude-plugin/`
- Aplica `sed` em todos `.md` com `framework-tag:`, **excluindo** `migrations/` (regra em CLAUDE.md linha 314)
- Após o `sed`, roda cópia dos sources afetados para `templates/` (resolve o gap mencionado em CLAUDE.md linha 140 — "o sed só atualiza sources, não templates")
- Roda `bash scripts/check-sync.sh` — falha se sincronia não fecha
- Cria `migrations/v{ANTERIOR}-to-v{NOVA}.md` a partir do `migrations/MIGRATION_TEMPLATE.md` pré-preenchendo cabeçalho, diff de arquivos (`git diff --name-status`) e seções vazias para dev completar
- **Não** faz commit, **não** cria tag, **não** faz push — pontos de decisão humana

Guard rails:
- Validar working directory limpo antes de começar (abortar com mensagem clara se não)
- Comparar a última tag com HEAD para confirmar que há commits desde o último release
- Logar cada passo com prefixo `[release]` para rastreabilidade
- Exit 1 em qualquer falha intermediária (`set -euo pipefail`)
- `sed` portátil (macOS vs Linux): usar `sed -i.bak` + `rm *.bak` ou detectar plataforma

Alternativas descartadas:
- Script que também faz commit + tag + push — risco alto de automação cega. O dev precisa revisar o migration e o diff antes do commit; o push fica manual por política.
- Delegar para GitHub Actions — conflita com o fluxo atual (dev bumpa local, revisa, commita, envia PR). Release via CI exigiria mudança maior de processo.
- Script em Node.js — desnecessário; bash resolve e mantém o stack do framework (todos os outros scripts são bash).

**Critérios de aceitação:**
- [x] `scripts/release.sh` criado com `set -euo pipefail` e aceita `major|minor|patch|vX.Y.Z`
- [x] Bumpa VERSION, plugin.json, marketplace.json (raiz + template)
- [x] Aplica `sed` em framework-tags excluindo `migrations/`
- [x] Sincroniza templates afetados após o `sed`
- [x] Roda `check-sync.sh` no final — aborta se falhar
- [x] Cria `migrations/v{ANTERIOR}-to-v{NOVA}.md` com scaffold pré-preenchido
- [x] Valida working directory limpo antes de começar
- [x] Não executa commit/tag/push
- [x] Documentado em `CLAUDE.md` (seção "Versionamento e release")
- [x] `MANIFEST.md` registra `scripts/release.sh` como framework-internal (não distribuído)
- [x] `sed` portátil macOS/Linux

**Restrições:**
- **Não commitar, não taguear, não pushar.** Esses passos continuam manuais. O script é ferramenta de bump, não de publicação.
- **Não executar em branch `main` direta.** Release continua saindo de branch → PR → merge, conforme política de releases via PR.
- Script é framework-internal — não vai no MANIFEST como distribuído, não vai em `templates/`.
- Qualquer mudança no processo de release (CLAUDE.md) deve refletir no script e vice-versa.
