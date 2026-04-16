# PF7 — Instrução compacta (reduzir tokens de leitura)

**Contexto:** o SKILL.md do setup tem 2.295 linhas. O do update tem 1.254 linhas. Claude gasta ~10-15% do tempo total só lendo as instruções antes de começar a agir. Muitas seções contêm exemplos longos de output (50+ linhas), edge cases detalhados, e lógica de monorepo (~300 linhas) que só se aplica em ~20% dos projetos.

**Abordagem:** extrair conteúdo condicional e exemplos para arquivos auxiliares. SKILL.md principal fica com o happy path (~1.200 linhas, -50%). Claude só lê auxiliares quando relevante.

**Estrutura proposta:**

```
skills/setup-framework/
├── SKILL.md                   ← instrução principal (~1.200 linhas)
├── EXAMPLES.md                ← exemplos de output (CLAUDE.md, SETUP_REPORT, etc.)
├── MONOREPO_DETAILS.md        ← cenários A-E, L0/L2/L3+, deduplicação, docs por sub-projeto
├── NOTION_DETAILS.md          ← setup de Notion: fetch, schema, templates, fields
└── templates/                 ← (já existe)

skills/update-framework/
├── SKILL.md                   ← instrução principal (~800 linhas)
├── STRUCTURAL_MERGE_DETAILS.md ← receita completa com edge cases
└── NOTION_UPDATE_DETAILS.md    ← sync de Notion, field changes
```

**Regra de referência no SKILL.md:**
```
Se monorepo detectado → Ler MONOREPO_DETAILS.md antes de continuar
Se Notion escolhido → Ler NOTION_DETAILS.md
```
Claude só carrega o auxiliar quando a condição é verdadeira.

**O que sai do SKILL.md principal:**

| Conteúdo | Para onde vai | Linhas economizadas |
|---|---|---|
| Exemplos de output (CLAUDE.md gerado, SETUP_REPORT) | EXAMPLES.md | ~200 |
| Cenários A-E monorepo + L0/L2/L3+ + deduplicação + docs por sub-projeto | MONOREPO_DETAILS.md | ~300 |
| Setup Notion (fetch database, schema analysis, template mapping, field creation) | NOTION_DETAILS.md | ~200 |
| Explicações longas de edge cases | Colapsadas em 1-2 frases + referência | ~100 |
| **Total** | | **~800 linhas** |

**O que NÃO sai:**
- Fases 0-5 (estrutura principal) — ficam no SKILL.md
- Regras — ficam no SKILL.md
- Guards e condições — ficam no SKILL.md
- CODE_PATTERNS (curto) — fica no SKILL.md

**Impacto no framework:**

| Arquivo | Mudança |
|---|---|
| `skills/setup-framework/SKILL.md` | Refactor: -800 linhas, referências a auxiliares |
| `skills/setup-framework/EXAMPLES.md` | NOVO |
| `skills/setup-framework/MONOREPO_DETAILS.md` | NOVO |
| `skills/setup-framework/NOTION_DETAILS.md` | NOVO |
| `skills/update-framework/SKILL.md` | Refactor: referências a auxiliares |
| `skills/update-framework/STRUCTURAL_MERGE_DETAILS.md` | NOVO |
| `skills/update-framework/NOTION_UPDATE_DETAILS.md` | NOVO |
| Mirrors | Sync todos |

**Critérios de aceitação:**
- [ ] SKILL.md do setup: ≤1.300 linhas (de 2.295)
- [ ] SKILL.md do update: ≤900 linhas (de 1.254)
- [ ] Zero funcionalidade perdida — tudo que existia está nos auxiliares
- [ ] Claude lê auxiliar APENAS quando condição é verdadeira (não sempre)
- [ ] Projeto single-repo sem Notion: Claude não lê MONOREPO_DETAILS.md nem NOTION_DETAILS.md
- [ ] Re-run, update, upgrade: mesmos resultados
- [ ] check-sync.sh valida auxiliares (framework-tag presente)

**Restrições:**
- Auxiliares NÃO vão para o projeto (não estão no MANIFEST) — são internos da skill
- Auxiliares têm framework-tag para versionamento
- Não dividir lógica que precisa de contexto cruzado (ex: Fase 1 informa Fase 3 — ambas ficam no principal)

**Deps:** PF1, PF2 (SKILL.md precisa estar estável após PF1+PF2 antes de refatorar)
