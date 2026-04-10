# Plano: Simplificação do Framework — Overengineering, Sobreposições e Contradições

## Contexto

O framework cresceu de v0 a v2.34 em ~10 dias, acumulando 22 skills, 17 agents e 20 docs. Uma análise identificou redundâncias, overlap de conteúdo, contradições de guardrails e overengineering. Este plano implementa as correções acordadas com o usuário.

---

## Visão geral das mudanças

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ELIMINAR (redundante)                                    │
│    syntax-check, performance-profiling, plan-checker        │
├─────────────────────────────────────────────────────────────┤
│ 2. REDUZIR OVERLAP                                          │
│    docs pairs, orquestração 3→1, DoD, CLAUDE.template,     │
│    contagens opcionais                                      │
├─────────────────────────────────────────────────────────────┤
│ 3. CORRIGIR CONTRADIÇÕES                                    │
│    agents read-only, TDD obrigatório, coverage,            │
│    "toda mudança tem spec", execução default, STATE.md      │
├─────────────────────────────────────────────────────────────┤
│ 4. BACKLOG                                                  │
│    descartar SW3/OP1/DF4, mover SW10→DF, promover DF13,   │
│    manter DF11/DF12/DF14 em decisões futuras               │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. Eliminações (skills/agents redundantes)

### 1a. Eliminar `syntax-check` skill
- **Motivo:** 100% dos checks já existem em `code-quality`
- **Arquivos a deletar:**
  - `skills/syntax-check/README.md`
  - `skills/setup-framework/templates/skills/syntax-check/README.md`
- **Arquivos a editar:**
  - `MANIFEST.md` — remover linha de syntax-check
  - `skills/setup-framework/templates/CLAUDE.md` — remover linha 14 da tabela de skills (trigger "Vai commitar código?")
  - `docs/SKILLS_MAP.md` — remover entrada
  - `docs/SKILLS_GUIDE.md` — remover seção
  - `skills/setup-framework/SKILL.md` — remover da lista de cópia e da auditoria 5b
  - `skills/update-framework/SKILL.md` — remover da lista e auditoria 5b
  - `scripts/test-setup.sh` — remover check se existir

### 1b. Eliminar `performance-profiling` skill
- **Motivo:** ~90% overlap com agent `performance-audit`
- **Arquivos a deletar:**
  - `skills/performance-profiling/README.md`
  - `skills/setup-framework/templates/skills/performance-profiling/README.md`
- **Arquivos a editar:**
  - `MANIFEST.md` — remover linha
  - `skills/setup-framework/templates/CLAUDE.md` — remover linha 19 da tabela de skills
  - `docs/SKILLS_MAP.md` — remover entrada
  - `docs/SKILLS_GUIDE.md` — remover seção
  - `skills/setup-framework/SKILL.md` — remover da lista de cópia e auditoria 5b
  - `skills/update-framework/SKILL.md` — remover da lista e auditoria 5b
  - `scripts/test-setup.sh` — remover check se existir

### 1c. Eliminar `plan-checker` agent
- **Motivo:** `spec-validator` seção 7 já faz exatamente o mesmo (cobertura spec→plano)
- **Arquivos a deletar:**
  - `agents/plan-checker.md`
  - `skills/setup-framework/templates/agents/plan-checker.md`
- **Arquivos a editar:**
  - `MANIFEST.md` — remover linha
  - `skills/setup-framework/templates/CLAUDE.md` — remover linha 15 da tabela de agents + remover da sub-tabela "Agents custom" na seção "Modelos para sub-agents"
  - `docs/SKILLS_MAP.md` — remover entrada
  - `skills/setup-framework/SKILL.md` — remover da lista de cópia e auditoria 5b
  - `skills/update-framework/SKILL.md` — remover da lista e auditoria 5b
  - `scripts/test-setup.sh` — remover check se existir

---

## 2. Redução de overlap

### 2a. Cerimônia excessiva para itens Pequeno → DF13 (ver seção 4)

A solução vem da promoção do DF13 — ver seção 4 do plano.

### 2b. Definition of Done — simplificar checklists tipo-específicos

**Decisão do usuário:** não usar HTML comments (Claude lê igual). Manter checklist universal + "Feature grande" inline. Os outros ficam como placeholder `{Adaptar}`.

**Mudança no `skills/definition-of-done/README.md`:**
- Manter: "Checklist universal" (linhas 19-68) — sem mudança
- Manter: "Feature grande ou complexa" (linhas 120-132) — sem mudança
- Substituir as seções: "Nova feature" (77-84), "Bugfix" (88-93), "Novo endpoint" (97-100), "Mudança em auth" (102-109), "Webhook" (112-118), "Novo comando CLI" (135-141), "Mudança em infra" (143-150), "Publicação de library" (152-159), "Tipo customizado" (161-164) por:

```markdown
### Checklists por tipo de entrega

Os checklists acima (universal + feature grande) cobrem o caso mais complexo. Para tipos específicos, adicionar checks relevantes ao projeto:

{Adaptar: criar seções para os tipos de entrega relevantes ao projeto. Exemplos de tipos e checks típicos:
- Nova feature: docs do projeto, guia/FAQ, E2E para fluxo crítico
- Bugfix: teste reproduz bug ANTES do fix, root cause no commit
- Novo endpoint: OWASP, testes de integração (200/400/401/403/404/500), rate limit, docs API
- Auth/permissões: timing-safe, anti-enumeração, token rotation, bloqueio progressivo
- Webhook: assinatura verificada, idempotência, timeout
- CLI: --help, exit codes, stdout/stderr
- Infra: plan sem drift, rollback, secrets via vault
- Library: semver, CHANGELOG, migration guide}
```

### 2c. Overlap entre docs — auditar pares

**Pares a auditar (manter separados, remover conteúdo duplicado):**

1. **SKILLS_MAP ↔ SKILLS_GUIDE**: remover ordem de precedência/exemplos de fluxo repetidos no menos específico, adicionar referência cruzada
2. **CONCEPTUAL_MAP ↔ SPEC_DRIVEN_GUIDE**: remover tabela de sizing duplicada do CONCEPTUAL_MAP (já existe no SPEC_DRIVEN_GUIDE), manter só glossário + diagrama visual
3. **QUICK_START ↔ SETUP_GUIDE**: garantir que QUICK_START é resumo com referência, não mini-cópia
4. **SECURITY_AUDIT doc ↔ security-audit agent ↔ security-review skill**: verificar que SECURITY_AUDIT.md não duplica checks do agent

**Arquivos a editar:**
- `docs/SKILLS_MAP.md` + template
- `docs/SKILLS_GUIDE.md` + template
- `docs/CONCEPTUAL_MAP.md` + template
- `docs/SPEC_DRIVEN_GUIDE.md` + template (referência)
- `docs/QUICK_START.md` + template
- `docs/SETUP_GUIDE.md` + template (referência)
- `docs/SECURITY_AUDIT.md` + template

### 2d. CLAUDE.template.md — reduzir para ~200 linhas

**Decisão do usuário:** a seção "Modelos para sub-agents" é sobre como escolher modelo ao despachar *qualquer* sub-agent (built-in: Explore, Plan, general-purpose), não é duplicação da tabela de agents custom. Manter a tabela de decisão + hierarquia. Remover só a sub-tabela "Agents custom deste projeto" (linhas 251-269 do template) que duplica a tabela de agents acima (linhas 156-174).

**Mudanças no `skills/setup-framework/templates/CLAUDE.md`:**
- **Skills**: manter tabela mas compactar — remover skills eliminadas (syntax-check, performance-profiling)
- **Agents**: remover plan-checker da tabela. Manter tabela compacta (nome + quando + obrigatório). Remover coluna "Modelo" da tabela de agents (modelo vive no frontmatter)
- **Seção "Modelos para sub-agents"**: manter "Hierarquia de decisão" + "Tabela de decisão" + "Agents built-in". **Remover** sub-tabela "Agents custom deste projeto" (é duplicação)
- **Worktrees**: mover detalhes (tabela de tipos de subagent, regras detalhadas) para um doc separado, manter só regra resumida no CLAUDE.md

### 2e. Contagem de testes opcional

**Decisão do usuário:** o verify.sh já tem checks de contagem (comentados). Tornar opcional.

**Mudanças:**
- `skills/docs-sync/README.md` — tornar seção "Contagens a manter sincronizadas" e regra 2 opcionais: `{Adaptar: se o projeto mantém contagens no CLAUDE.md, sincronizar aqui. Opcional — contagens podem ser consultadas sob demanda via verify.sh}`
- Template correspondente

### 2f. Refactor da tríade de orquestração (spec-driven / execution-plan / context-fresh)

Cada skill repete a lógica de waves/despacho/sub-agents. Consolidar para uma fonte de verdade cada:

- **spec-driven** (roteador): remover ~60 linhas que repetem protocolo de waves e ~30 linhas de regras de delegação. Manter classificação, state machine, gates. Na fase `plan`: "criar execution-plan seguindo skill execution-plan". Na fase `execute`: "se sub-agents → seguir context-fresh; senão → implementar sequencialmente seguindo o plan". Adicionar referências.
- **execution-plan** (planejador): remover regras 3-7 que repetem como despachar sub-agents. Manter formato do plano, decomposição, waves (1 parágrafo curto). Adicionar referência: "Para protocolo de despacho → context-fresh."
- **context-fresh** (despachador): sem mudança — já é a fonte de verdade.

**Arquivos a editar:**
- `skills/spec-driven/README.md` + template
- `skills/execution-plan/README.md` + template
- (context-fresh sem mudança)

---

## 3. Correção de contradições

### 3a. "Agents são read-only" vs task-runner/refactor-agent

**Mudança na regra do `skills/setup-framework/templates/CLAUDE.md` (linha 176):**

De: `"Agents sao para auditoria e report — NAO para implementacao direta."`

Para:
```
**Agents de auditoria** (read-only: security-audit, code-review, spec-validator, etc.) devolvem relatórios — nunca aplicar fix direto do report sem passar pelo fluxo spec-driven. **Agents de execução** (task-runner, refactor-agent) são infraestrutura de orquestração e operam em worktree isolada.
```

### 3b. "⛔ TDD obrigatório" — obrigatório por default

**Decisão do usuário:** TDD é obrigatório por default. O `{Adaptar}` só se aplica se o CLAUDE.md do projeto já disser o contrário. No update, respeitar o que o projeto já definiu.

**Mudança no `skills/setup-framework/templates/CLAUDE.md` seção "⛔ TDD obrigatório":**

Manter título `## ⛔ TDD obrigatório` e conteúdo como está. Ajustar o `{Adaptar}` no final para:

```
{Adaptar: TDD estrito é o default do framework. Se o projeto já define política de testes diferente no CLAUDE.md (ex: "testes obrigatórios sem exigência de ordem"), respeitar. Caso contrário, manter TDD obrigatório.}
```

### 3c. Coverage "100% Statements" → adaptável

**Mudança no `skills/setup-framework/templates/CLAUDE.md` tabela de coverage (linhas 347-350):**

De: `Backend | 100% | ≥95%` e `Frontend | 100% | ≥90%`

Para:
```
| Backend | {X}% | {Y}% | {Adaptar: módulos críticos (auth, payments) → cobertura alta. Módulos internos → cobertura funcional} |
| Frontend | {X}% | {Y}% | {Adaptar: componentes de negócio → cobertura alta. UI pura → cobertura funcional} |
```

### 3d. "Toda mudança tem spec" → fast-path para triviais

Resolvido pelo DF13 (ver seção 4). Adicionar exceção explícita no spec-driven:

```
> **Fast-path:** Correções triviais (typo, bump de dependência, ajuste de mensagem, config simples) não precisam de spec. Commitar direto com mensagem descritiva. Se a mudança toca lógica de negócio, não é trivial.
```

### 3e. "Sessão principal nunca implementa" como default → inverter

**Mudança no spec-driven e CLAUDE.template.md:**

Inverter a estrutura — default: implementar seguindo o execution-plan. Se sub-agents: delegar.

De (spec-driven linha 38):
```
não implementar no mesmo contexto — delegar cada parte para sub-agents [...] Se o projeto não usa sub-agents: implementar sequencialmente
```

Para:
```
Implementar sequencialmente seguindo a ordem do execution-plan. Se o projeto usa sub-agents: delegar cada parte seguindo context-fresh (sessão principal planeja, orquestra e integra; sub-agents executam).
```

Mesma inversão no CLAUDE.template.md seção "Modo de execução".

### 3f. STATE.md — simplificar

**Mudança nos templates que definem STATE.md** (spec-driven, definition-of-done, CLAUDE.template.md):

Simplificar para 3 seções:
1. **Em andamento** — spec + fase atual + o que falta (exit criteria)
2. **Próximos passos** — o que fazer quando retomar
3. **Notas** — blockers, ideias adiadas

**Remover:** log de transições de fase (overhead sem valor), decisões arquiteturais (vão na spec ou design doc), tracking detalhado de tasks (vive no execution-plan).

Ajustar referências no definition-of-done que exigem "Log de transições no STATE.md" (linha 37) e "Decisões arquiteturais registradas no STATE.md (AD-NNN)" (linha 124).

---

## 4. Atualização do backlog

### Descartar

| ID | Motivo |
|----|--------|
| **SW3** | Overhead acadêmico. Claude entende linguagem natural — formato EARS não agrega valor mensurável |
| **DF4** | Decisão sobre adotar EARS — descartada junto com SW3 |
| **OP1** | Framework-internal sem valor para usuários. GitHub Action para detectar releases de concorrentes é overhead de manutenção sem retorno |

### Mover para decisões futuras

| ID | Motivo |
|----|--------|
| **SW10** | Campos customizados por projeto adiciona superfície de configuração. `{Adaptar:}` no setup já cobre a maioria dos casos. Reavaliar quando projetos reportarem que `{Adaptar:}` é insuficiente |

### Manter em decisões futuras (sem mudança)

DF11, DF12, DF14 — ficam onde estão, sem descartar.

### Promover de decisão futura para pendente

**DF13 → item pendente** (Discovery Routing)

Gatilho atingido: CE5 concluído em v2.25.0.

**O que o DF13 deve fazer (detalhamento):**

O Discovery Routing é uma etapa de classificação **antes** do spec-driven que roteia o trabalho incoming para o fluxo certo, evitando overhead de spec completa para tasks triviais.

**Fluxo proposto:**

```
Trabalho incoming
       │
       ▼
┌─────────────────┐
│ Classificar tipo │
│ (Discovery)      │
└───────┬─────────┘
        │
   ┌────┼────────────────┐
   ▼    ▼                ▼
Quick  Spec única    Multi-spec
task   (spec-driven) (PRD → specs)
   │        │              │
   ▼        ▼              ▼
Implementar Fluxo      /prd →
direto      normal     /spec ×N
```

**Quick task (fast-path):** Critérios — typo, bump de dependência, ajuste de mensagem/config, rename, fix de 1-2 linhas sem nova lógica de negócio. Fluxo: implementar → testar → verify.sh → commit → PR. Sem spec, sem STATE.md, sem DoD completo. Backlog pós-facto se relevante.

**Spec única:** Fluxo normal do spec-driven (classificar Pequeno/Médio/Grande/Complexo).

**Multi-spec decomposition:** Quando o incoming é uma iniciativa que claramente precisa de 2+ specs. Rotear para `/prd` para decomposição antes de criar specs individuais.

**Onde implementar:** Como pergunta inicial no spec-driven. Antes da classificação de complexidade atual (Pequeno/Médio/Grande/Complexo), adicionar gate de triagem: "Isso é uma quick task, uma spec única, ou uma iniciativa maior?" Se quick task → fast-path. Se spec única → fluxo atual. Se iniciativa → `/prd`.

**Impacto nos arquivos:**
- `skills/spec-driven/README.md` — adicionar seção de triagem antes do fluxo atual
- `skills/definition-of-done/README.md` — DoD para quick tasks: verify.sh + Conventional Commits + PR (sem spec verification)
- `skills/setup-framework/templates/CLAUDE.md` — ajustar regra 1 "Spec-driven obrigatório" para mencionar fast-path
- Templates correspondentes

---

## 5. Ordem de implementação

Os grupos são independentes e podem ser PRs separados:

1. **Eliminações** (1a, 1b, 1c) — menor risco, ganho imediato
2. **Redução de overlap docs** (2c) — auditoria de conteúdo repetido
3. **Correção de contradições** (3a-3f) + fast-path DF13 (3d + seção 4)
4. **Simplificação CLAUDE.template.md** (2d) + DoD (2b) + contagens (2e)
5. **Refactor tríade** (2f) — spec-driven / execution-plan / context-fresh
6. **Backlog** (seção 4) — descartar SW3/OP1/DF4, mover SW10→DF, promover DF13

> Grupo 6 (backlog) pode ser feito junto com qualquer outro grupo.

---

## 6. Verificação

Após todas as mudanças:

```bash
bash scripts/validate-tags.sh    # tags consistentes
bash scripts/check-sync.sh       # source ↔ template em sincronia
bash scripts/test-setup.sh       # setup simula corretamente
```

Validar manualmente:
- [ ] MANIFEST reflete as remoções (3 skills, 1 agent a menos)
- [ ] Nenhuma referência órfã a syntax-check, performance-profiling, plan-checker nos docs/skills
- [ ] CLAUDE.template.md < 250 linhas (alvo ~200)
- [ ] BACKLOG.md tem SW3/OP1 em descartados, DF4 em descartados, SW10 em decisões futuras, DF13 em pendentes
- [ ] Tríade de orquestração: cada conceito (waves, despacho, briefing) existe em 1 lugar só
