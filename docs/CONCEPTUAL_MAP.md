<!-- framework-tag: v2.35.0 framework-file: docs/CONCEPTUAL_MAP.md -->
# Mapa Conceitual — Hierarquia de Artefatos

> Guia rapido para entender como os artefatos do framework se relacionam com a terminologia padrao da industria (Epics, Stories, Tasks).

---

## Glossario de equivalencias

| Termo da industria | No framework | Onde vive | Comando |
|---|---|---|---|
| Epic / Initiative | **PRD** — analise de causa raiz | `.claude/prds/{id}.md` | `/prd` |
| User Story / Feature | **Spec** — derivada de uma acao do PRD | `.claude/specs/{id}.md` (repo) ou pagina no Notion | `/spec` |
| Task / Sub-task | **Task** dentro da spec (T1, T2...) | Secao "Breakdown de tasks" na spec | — |
| Backlog Item / Ticket | **Item no backlog** | `.claude/specs/backlog.md` (repo) ou database Notion | `/backlog-update` |
| Design Doc / ADR | **Design doc** (complemento para specs complexas) | `.claude/specs/{id}-design.md` (repo) ou pagina no Notion | — |
| Acceptance Criteria | Secao **"Criterios de aceitacao"** | Dentro de cada spec | — |
| Definition of Done | Secao **"Verificacao pos-implementacao"** | Dentro de cada spec | `/definition-of-done` |
| Sprint / Iteration | Nao gerenciado pelo framework | — | — |

> **Nota:** O framework complementa ferramentas de tracking (Jira, Linear, Notion). Ele nao substitui o board do time — ele estrutura o *conteudo tecnico* que alimenta esses boards.

---

## Hierarquia visual

```
┌─────────────────────────────────────────────────────────┐
│  PRD (analise de causa raiz)                            │
│  "o que / por que / para quem"                          │
│                                                         │
│  Secao "Como resolver" lista acoes → cada acao vira     │
│  uma ou mais specs                                      │
└──────────────┬──────────────┬──────────────┬────────────┘
               │              │              │
        ┌──────▼──────┐ ┌────▼────┐ ┌───────▼───────┐
        │   Spec A    │ │ Spec B  │ │    Spec C     │
        │ "como       │ │         │ │               │
        │ implementar"│ │         │ │               │
        ├─────────────┤ ├─────────┤ ├───────────────┤
        │ T1 - Auth   │ │ T1     │ │ T1            │
        │ T2 - API    │ │ T2     │ │ T2            │
        │ T3 - Tests  │ │        │ │ T3            │
        └─────────────┘ └─────────┘ └───────────────┘

        ┌─────────────────────────────────────────────┐
        │  Backlog ← rastreia tudo                    │
        │  (PRDs, specs, itens avulsos, bugs)         │
        └─────────────────────────────────────────────┘
```

**Leitura:** Um PRD gera multiplas specs. Cada spec tem suas tasks. O backlog rastreia tudo — inclusive itens que nao precisaram de PRD ou spec.

---

## Quando usar o que

```
Mudanca trivial? (<=3 arquivos, sem nova abstração, sem mudança de schema, sem ambiguidade)
│
├── SIM → /backlog-update add → implementa direto
│
└── NAO → Escopo claro? (<10 tasks, uma solucao obvia)
          │
          ├── SIM → /spec → implementa
          │
          └── NAO → Multiplas causas ou solucoes possiveis?
                    │
                    ├── SIM → /prd → refina → /spec por acao
                    │
                    └── NAO → /spec (Grande) + design doc opcional
```

Para critérios detalhados de sizing (Pequeno/Médio/Grande/Complexo) e artefatos por tamanho, veja [`SPEC_DRIVEN_GUIDE.md`](SPEC_DRIVEN_GUIDE.md) seção "Auto-sizing".

---

## Referencia cruzada

| Nivel | Template | Skill | Agent de validacao |
|---|---|---|---|
| PRD | `prds/PRD_TEMPLATE.md` | `/prd` | `product-review` |
| Spec | `specs/TEMPLATE.md` | `/spec` | `spec-validator` |
| Research notes | `.claude/specs/{id}-research.md` | skill research | — (descartavel) |
| Design doc | `specs/DESIGN_TEMPLATE.md` | — (manual) | — |
| Backlog | `specs/backlog.md` | `/backlog-update` | `backlog-report` |

---

## Exemplo pratico

### Cenario: "Sistema de Notificacoes"

**1. PRD** (`notificacoes.md` em `.claude/prds/`) — Time de produto identifica que usuarios perdem atualizacoes importantes. Analisa causas: sem push mobile, sem preferencias, sem digest.

```
PRD-NOTIF: Sistema de Notificacoes
├── Causa 1: Sem canal push → Acao: Implementar push mobile
├── Causa 2: Sem controle do usuario → Acao: Tela de preferencias
└── Causa 3: Acumulo sem resumo → Acao: Digest semanal por email
```

**2. Specs** — Cada acao do PRD vira uma spec independente:

| Spec | Derivada de | Tasks |
|---|---|---|
| `SPEC-001-push-mobile.md` | Acao 1 do PRD | T1: Integracao FCM/APNs, T2: API de registro, T3: Testes E2E |
| `SPEC-002-preferencias.md` | Acao 2 do PRD | T1: Schema de preferencias, T2: UI settings, T3: API CRUD |
| `SPEC-003-digest-email.md` | Acao 3 do PRD | T1: Template do email, T2: Scheduler (cron), T3: Opt-in/out |

**3. Backlog** — Rastreia o progresso de cada item:

```
ID    | Spec        | Status       | Complexidade
BL-15 | SPEC-001    | em andamento | Medio
BL-16 | SPEC-002    | rascunho     | Medio
BL-17 | SPEC-003    | pendente     | Grande
```

**4. Implementacao** — Dev pega spec por spec, implementa tasks na ordem, marca como concluida.

---

## Onde aprender mais

| Topico | Documento |
|---|---|
| Guia completo de spec-driven development | [`SPEC_DRIVEN_GUIDE.md`](SPEC_DRIVEN_GUIDE.md) |
| Mapa de todas as skills disponiveis | [`SKILLS_MAP.md`](SKILLS_MAP.md) |
| Template de PRD | [`../prds/PRD_TEMPLATE.md`](../.claude/prds/PRD_TEMPLATE.md) |
| Template de Spec | [`../specs/TEMPLATE.md`](../.claude/specs/TEMPLATE.md) |
| Template de Design Doc | [`../specs/DESIGN_TEMPLATE.md`](../.claude/specs/DESIGN_TEMPLATE.md) |
| Integracao com Notion | [`NOTION_INTEGRATION.md`](NOTION_INTEGRATION.md) |
