# Framework de Documentação para Claude Code

Guia para aplicar o sistema de specs, skills e verificação em qualquer projeto.

---

## Visão geral

Este framework organiza o trabalho com Claude Code em 6 camadas:

```
┌─────────────────────────────────────────────┐
│  CLAUDE.md                                  │  ← Regras, convenções, contexto
│  (cérebro do projeto)                       │
├─────────────────────────────────────────────┤
│  SPECS_INDEX.md + .claude/specs/            │  ← O que fazer e por quê
│  (specs + backlog)                          │
├─────────────────────────────────────────────┤
│  .claude/skills/                            │  ← Como fazer (checklists)
│  (checklists por domínio)                   │
├─────────────────────────────────────────────┤
│  scripts/verify.sh                          │  ← Validação automatizada
│  (checks evolutivos)                        │
├─────────────────────────────────────────────┤
│  Slash commands (SKILL.md)                  │  ← Automação de processos
│  (/backlog-update, /spec)                   │
├─────────────────────────────────────────────┤
│  docs/GIT_CONVENTIONS.md                    │  ← Padrões de commit e PR
│  (conventional commits)                     │
└─────────────────────────────────────────────┘
```

### Por que funciona

1. **Spec antes de código** — o Claude nunca implementa sem entender o contexto
2. **Skills como checklists** — cada domínio tem sua lista de verificação, evitando esquecimentos
3. **verify.sh evolui com o projeto** — cada regra nova vira um check automatizado
4. **Backlog como fonte de verdade** — tudo que precisa ser feito está num lugar só
5. **Definition of Done** — nenhuma entrega passa sem verificação contra a spec

---

## Estrutura de diretórios

```
{projeto}/
├── CLAUDE.md                    # Regras e contexto do projeto
├── SPECS_INDEX.md               # Índice de todas as specs
├── scripts/
│   └── verify.sh                # Verificação pré-commit
├── docs/
│   ├── GIT_CONVENTIONS.md       # Padrão de commits
│   └── {outros docs}
└── .claude/
    ├── skills/                  # Skills (checklists por domínio)
    │   ├── testing/README.md
    │   ├── security-review/README.md
    │   ├── definition-of-done/README.md
    │   ├── docs-sync/README.md
    │   ├── logging/README.md
    │   ├── code-quality/README.md
    │   ├── backlog-update/SKILL.md      # Slash command
    │   └── spec-creator/SKILL.md        # Slash command
    └── specs/                   # Specs de features
        ├── TEMPLATE.md          # Template de spec
        ├── backlog.md           # Backlog unificado
        ├── {feature-x.md}      # Specs ativas
        └── done/                # Specs concluídas
            └── {feature-y.md}
```

---

## Como montar — passo a passo

### 1. CLAUDE.md (comece por aqui)

O CLAUDE.md é a **primeira coisa que o Claude lê** em cada sessão. É o "cérebro" do projeto.

**Template:** `CLAUDE.template.md`

**Seções essenciais (em ordem):**

| Seção | Propósito | Prioridade |
|---|---|---|
| O que é este projeto | Contexto em 1-2 frases | Obrigatória |
| Mindset por domínio | Postura por área (backend, frontend, UX, DB, security) | Obrigatória |
| Comandos | Dev, test, build, migrations | Obrigatória |
| Specs e Requisitos | Fluxo: backlog -> spec -> código -> verificação | Obrigatória |
| Skills | Mapa: "vai fazer X? leia skill Y" | Obrigatória |
| Antes de commitar | Checklist pré-commit | Obrigatória |
| Estrutura | Árvore de diretórios | Recomendada |
| Regras de segurança | Regras invioláveis | Recomendada |
| Regras de código | Padrões técnicos | Recomendada |
| Testes | Política de cobertura | Recomendada |
| Contexto de negócio | Regras de domínio que afetam código | Recomendada |

**Dica:** comece com as obrigatórias e vá adicionando conforme o projeto cresce. CLAUDE.md evolui — não precisa ficar perfeito no dia 1.

### 2. Specs e Backlog

**O fluxo é:**

```
Ideia → Backlog → Spec → Implementação → Testes → Docs → Verificação → done/
```

**Quando precisa de spec completa:**
- Altera mais de 1 arquivo
- Muda regra de negócio
- Mudança significativa num mesmo arquivo
- Tópico de segurança
- Visível ao usuário

**Quando NÃO precisa:**
- Fix de typo, 1 linha
- Mudança trivial < 30min em 1 arquivo

**Templates:** `specs/TEMPLATE.md`, `specs/backlog.md`, `SPECS_INDEX.template.md`

**Backlog — 4 seções fixas:**

1. **Pendentes** — tabela com 12 colunas (ID, Fase, Item, Sev, Impacto, Tipo, Camadas, Compl, Est, Deps, Origem, Spec)
2. **Concluídos** — tabela compacta (ID, Item, Data)
3. **Decisões futuras** — parking lot para itens que dependem de contexto externo
4. **Notas** — contexto opcional

**Spec — seções obrigatórias:**
- Contexto (por que)
- Requisitos Funcionais (RF-001, RF-002...)
- Escopo (checkboxes verificáveis)
- Critérios de aceitação (afirmações testáveis)
- Arquivos afetados
- Não fazer (fora do escopo)
- Verificação pós-implementação

### 3. Skills (checklists)

Skills são **checklists especializados por domínio**. Vivem em `.claude/skills/{nome}/README.md`.

**Skills essenciais (recomendo começar com estas):**

| Skill | Arquivo | Quando usar | Destaques |
|---|---|---|---|
| Definition of Done | `definition-of-done/README.md` | Antes de finalizar QUALQUER entrega | Checklists por tipo (feature, bugfix, endpoint, webhook, auth) |
| Testing | `testing/README.md` | Ao escrever/modificar testes | Pirâmide (unitário/integração/E2E/carga/golden), cobertura por risco, anti-patterns |
| Security Review | `security-review/README.md` | Ao criar/modificar endpoints | OWASP Top 10 com exemplos de código, TOCTOU, sanitização |
| Docs Sync | `docs-sync/README.md` | Antes de commitar | Matriz feature->docs, contagens sincronizadas |
| Logging | `logging/README.md` | Ao adicionar logs ou error handling | Níveis, prefixos [MODULE], patterns de try/catch/finally |
| Code Quality | `code-quality/README.md` | Ao criar módulos ou refatorar | Code smells, thresholds, componentização |

**Skills específicas do domínio (criar conforme necessidade):**

| Domínio | Exemplo de skill |
|---|---|
| Regras de domínio / compliance | `domain-rules/README.md`, `compliance/README.md` |
| UX / Design | `ux-review/README.md` |
| Banco de dados | `dba-review/README.md` |
| IA / LLM | `ai-prompts/README.md` |
| Mock mode / Dev tools | `mock-mode/README.md` |
| Syntax check | `syntax-check/README.md` |

**Anatomia de uma skill:**

```markdown
# Skill: {Nome} — {Projeto}

> Quando usar (1 frase)

## Regras absolutas
{O que nunca pode acontecer}

## Checklist por tipo de mudança

### {Tipo 1}
- [ ] Check 1
- [ ] Check 2

### {Tipo 2}
- [ ] Check 1

## Padrões / exemplos de código
{Exemplos ✅ correto e ❌ errado}

## Quando escalar
{Situações que precisam de atenção especial}
```

### 4. verify.sh (verificação automatizada)

O verify.sh roda **antes de cada commit** e valida automaticamente o que a atenção humana pode falhar.

**Template:** `scripts/verify.sh`

**Seções do script:**

1. **Testes** — testes passam, build passa, contagens nos docs batem, zero test.only/skip
2. **Segurança** — zero console.log em prod, asyncHandler, prepared statements (A03), secrets hardcoded (A02), SELECT * (A01), XSS em outputs (A03), dados sensíveis nos logs (A09), URLs hardcoded
3. **Docs sync** — contagens (tabelas, rotas, testes) batem entre código e docs
4. **Checks evolutivos** — seção que cresce com o projeto (specs indexadas, specs em done/ com status correto)

Cada check de segurança referencia o código OWASP correspondente (A01-A10) para rastreabilidade.

**Regra de ouro:** toda regra nova que você adicionar ao projeto deve virar um check no verify.sh. O script evolui junto com o CLAUDE.md.

**Como adicionar um check:**

```bash
# N. Descrição do check
RESULTADO=$(comando que verifica | wc -l | tr -d ' ')
if [ "$RESULTADO" = "0" ]; then
  pass "Descrição do sucesso"
else
  fail "Descrição do problema ($RESULTADO ocorrências)"
  comando que mostra detalhes | head -5
fi
```

### 5. Slash commands (SKILL.md com frontmatter)

Slash commands são skills invocáveis pelo usuário com `/nome`.

**Diferença de skill normal vs slash command:**

| | Skill normal | Slash command |
|---|---|---|
| Arquivo | `README.md` | `SKILL.md` |
| Frontmatter | Não tem | `name`, `description`, `user_invocable: true` |
| Invocação | Claude consulta sozinho | Usuário digita `/nome` |
| Uso | Checklist de referência | Automação de processo |

**Templates incluídos:**
- `/backlog-update` — adicionar, concluir ou editar itens no backlog
- `/spec` — criar nova spec a partir do template

**Como criar um slash command:**

```markdown
---
name: {nome-kebab}
description: {Descrição curta da ação}
user_invocable: true
---

# /{nome} — {Título}

{Descrição do que faz.}

## Uso

\`\`\`
/{nome} {argumentos}
\`\`\`

## Instruções

{Passo a passo que o Claude segue ao executar.}

## Regras

{Invariantes que devem ser respeitados.}
```

**Registrar no CLAUDE.md:** adicionar na seção "Skills" para que o Claude saiba que existe.

---

## Fluxo completo de trabalho

```
1. Usuário pede feature/fix
     │
2. Claude consulta SPECS_INDEX.md
     │  ↓ spec encontrada?
     ├─ Sim → lê spec, valida contra código atual
     └─ Não → /spec {ID} {Título} (cria spec + backlog)
     │
3. Claude lê skills relevantes (testing, security, etc.)
     │
4. Implementa seguindo spec
     │
5. Roda npm test + verify.sh
     │
6. Aplica Definition of Done:
     │  - Verifica cada critério de aceitação no código
     │  - Marca checkboxes da spec
     │  - Atualiza docs (docs-sync)
     │
7. Commit (conventional commits)
     │
8. /backlog-update {ID} done
     │  - Move spec para done/
     │  - Atualiza SPECS_INDEX
     │  - Atualiza backlog
```

---

## Dicas de implantação

### Começando do zero

1. Crie o `CLAUDE.md` com seções obrigatórias
2. Crie `.claude/specs/TEMPLATE.md` e `backlog.md`
3. Crie `SPECS_INDEX.md`
4. Adicione a skill `definition-of-done`
5. Crie o `verify.sh` básico (testes + build)
6. Adicione skills conforme a necessidade surgir

### Projeto existente

1. Comece pelo `CLAUDE.md` — documente o que já existe
2. Mova itens pendentes para o `backlog.md`
3. Crie specs retroativas para features complexas em andamento
4. Adicione `verify.sh` com checks do que já é regra
5. Crie skills para os domínios onde mais ocorrem erros

### Evolução progressiva

O framework não precisa ser completo no dia 1. A ideia é:

- **Semana 1:** CLAUDE.md + backlog + verify.sh básico
- **Semana 2:** 2-3 skills essenciais (DoD, testing, security)
- **Semana 3+:** Skills de domínio, slash commands, checks evolutivos

Cada vez que algo falha ou é esquecido:
1. Adicione um check no `verify.sh`
2. Adicione um item na skill relevante
3. Documente a regra no `CLAUDE.md`

---

## Arquivos incluídos neste framework

```
templates/claude-code-framework/
├── GUIA.md                          # Esta documentação
├── CLAUDE.template.md               # Template do CLAUDE.md
├── SPECS_INDEX.template.md          # Template do índice de specs
├── specs/
│   ├── TEMPLATE.md                  # Template de spec
│   └── backlog.md                   # Template de backlog
├── scripts/
│   └── verify.sh                    # Template do verify.sh
└── skills/
    ├── definition-of-done/README.md # Skill: Definition of Done
    ├── testing/README.md            # Skill: Testing
    ├── security-review/README.md    # Skill: Security Review
    ├── docs-sync/README.md          # Skill: Docs Sync
    ├── logging/README.md            # Skill: Logging & Error Handling
    ├── code-quality/README.md       # Skill: Code Quality
    ├── backlog-update/SKILL.md      # Slash command: /backlog-update
    └── spec-creator/SKILL.md        # Slash command: /spec
```

Para usar: copiar para o novo projeto, substituir os `{placeholders}` pelos valores reais, e ir evoluindo.
