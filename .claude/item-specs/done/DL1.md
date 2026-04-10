# DL1 — Skill `/pr`

**Contexto:** Specs têm contexto rico (motivação, critérios, restrições) que raramente aparece nas descrições de PR porque o dev preenche manualmente. Uma skill que lê spec + diff e preenche o template automaticamente reduz atrito na entrega e garante rastreabilidade spec → PR.

**Abordagem:** Skill em `skills/pr/SKILL.md`. Fluxo: detecta template → lê diff/spec → propõe preenchimento → abre PR via `gh pr create` após confirmação. Setup-framework distribui `.github/pull_request_template.md` como arquivo `structural` (preserva customizações); skill usa o formato de `docs/GIT_CONVENTIONS.md` como fallback se o template estiver ausente.

Fonte de spec: `STATE.md` seção "Execução ativa" (quando CE3 ✅ está em uso) ou busca em `.claude/specs/` pela spec mais recente modificada na branch atual.

Alternativas descartadas:
- Exigir template como pré-condição → UX ruim para projetos que deletaram o arquivo ou ainda não rodaram setup
- Usar só o diff sem spec → perde o "por quê", que é o valor principal da rastreabilidade spec → PR

**Critérios de aceitação:**
- [x] Skill detecta `.github/pull_request_template.md` e preenche cada seção com contexto de spec/diff
- [x] Quando template ausente, usa formato de `GIT_CONVENTIONS.md` como fallback sem erro
- [x] Título proposto segue Conventional Commits (ex: `feat(auth): adicionar login via SSO`)
- [x] Setup-framework inclui `.github/pull_request_template.md` (strategy: `structural`)
- [x] `MANIFEST.md` atualizado com o novo arquivo
- [x] Skill listada em `CLAUDE.template.md` na seção "Skills"
- [x] Skill listada em `docs/SKILLS_MAP.md`

**Restrições:**
- Nunca executar `gh pr create` sem confirmação explícita do usuário
- Não inventar conteúdo sem base em spec ou diff — se spec não disponível, informar e usar só o diff
- Template distribuído deve ter seções em português, simples o suficiente para qualquer projeto adaptar
