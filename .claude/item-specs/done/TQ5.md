# TQ5 — Seções obrigatórias nas skills distribuídas

**Contexto:** skills distribuídas pelo framework não tinham garantia de estrutura mínima. Cada skill definia suas próprias seções, e customizações em projetos divergiam sem padrão. O `validate-structure.sh` (TQ4, v2.30.0) já existia mas só emitia warning — o CI passava mesmo com skill fora do padrão. Resultado: skills novas nasciam incompletas e não havia gate para bloquear.

**Abordagem:** promover a validação de warning para **hard fail** (exit 1) quando skill distribuída não tem as 4 seções obrigatórias:
1. `## Quando usar`
2. `## Quando NÃO usar`
3. `## Checklist` (com checkboxes)
4. `## Regras`

Passos executados:
1. Definir a lista de seções (4 itens — mínimo útil, sem boilerplate desnecessário)
2. Atualizar todas as skills distribuídas (16 na época) para terem as 4 seções
3. Estender `validate-structure.sh` com check hard-fail por skill
4. Confirmar que o CI roda o script e bloqueia PRs não conformes
5. Documentar o padrão em `CLAUDE.md` do framework (seção "Padrão para criar skills")

Alternativas descartadas:
- Manter como warning — a prática provou que warning não corrige divergência; PRs passavam de qualquer forma.
- Lista maior de seções obrigatórias (ex: incluir "Exemplos", "Contexto") — boilerplate em skills simples. Exemplos concretos viraram regra separada (regra 9 do CLAUDE.md, não seção obrigatória).
- Validar **conteúdo** das seções além da presença — inviável mecanicamente; revisão humana cobre.

**Critérios de aceitação:**
- [x] Lista fechada de 4 seções obrigatórias definida e documentada
- [x] `scripts/validate-structure.sh` retorna exit 1 quando skill distribuída não tem as 4 seções
- [x] Todas as 16 skills distribuídas (repo + `templates/`) atualizadas com as seções
- [x] CI (`.github/workflows/ci.yml`) executa `validate-structure.sh` — PR falha se não conforme
- [x] Padrão documentado em `CLAUDE.md` (seção "Padrão para criar skills")
- [x] Sincronia source↔template validada pelo `check-sync.sh`

**Restrições:**
- A validação é de **presença**, não de conteúdo — conteúdo é revisão humana no PR.
- Skills **não distribuídas** (setup-framework, update-framework, upgrade-framework) não seguem este padrão — têm estrutura própria por serem workflows internos.
- Não expandir a lista de 4 seções sem revisão explícita — cada seção nova vira carga em 16+ skills.
- Agents seguem checklist separado (frontmatter obrigatório + "Quando usar" + seção de conteúdo) — padrões distintos por terem propósitos diferentes.
