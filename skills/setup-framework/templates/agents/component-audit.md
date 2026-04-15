---
description: Analisa arquitetura de componentes e módulos — estrutura, responsabilidades e oportunidades de extração
model: sonnet
model-rationale: Checklist estruturado com thresholds numericos para tamanho, responsabilidades e acoplamento de componentes.
worktree: false
---
<!-- framework-tag: v2.40.0 framework-file: agents/component-audit.md -->
# Agent: Component Audit

> Sub-agente autônomo que analisa a arquitetura de componentes e módulos.
> Executa sob demanda para avaliar estrutura, responsabilidades e oportunidades de extração.

## Quando usar

- Quando o codebase cresce e a estrutura precisa de revisão
- Antes de refatoração grande
- Quando componentes ficam difíceis de manter (god components, props drilling)
- Periodicamente para saúde arquitetural

## Input

- Path do repositório ou diretório específico (ex: `frontend/components/`, `backend/services/`)
- Escopo opcional: `frontend`, `backend`, `full`

## O que verificar

### 1. God components / God modules

Identificar arquivos com responsabilidades demais:

- **Frontend:** componente que faz fetch, state management, lógica de negócio e renderização tudo junto
- **Backend:** service que faz validação, query, transformação, notificação e logging num só arquivo

**Sinais:**
- Arquivo > 300 linhas (componente) ou > 500 linhas (service)
- Mais de 5 imports de domínios diferentes
- Mais de 3 responsabilidades distintas (identificar por blocos de lógica)
- Mais de 10 props (componente) ou 5 dependências injetadas (service)

### 2. Props drilling

Identificar props passadas por múltiplos níveis sem uso intermediário:

```
ComponenteA (define prop X)
  → ComponenteB (recebe X, não usa, passa adiante)
    → ComponenteC (recebe X, não usa, passa adiante)
      → ComponenteD (finalmente usa X)
```

- 2 níveis de passagem sem uso → sugerir Context ou state management
- Prop passada para > 3 componentes → sugerir extração para Context/hook

### 3. Responsabilidade única

Para cada componente/módulo, classificar responsabilidades:

**Frontend:**
- Data fetching (API calls)
- State management (useState, useReducer, Context)
- Business logic (cálculos, transformações, validações)
- UI rendering (JSX, estilos)
- Side effects (useEffect, timers, subscriptions)

**Backend:**
- Request validation (params, body, auth)
- Business logic (regras, cálculos)
- Data access (queries, transactions)
- External services (APIs, email, pagamento)
- Response formatting (serialização, status codes)

Se um componente/módulo tem > 2 responsabilidades → sugerir extração.

### 4. Oportunidades de extração

Identificar blocos que deveriam ser componentes/módulos independentes:

**Frontend:**
- Visual repetido em 2+ telas → extrair componente reutilizável
- Lógica de state + effects reusada → extrair hook customizado
- Lógica de transformação de dados → extrair util/helper
- Grupo de componentes sempre usados juntos → considerar compound component

**Backend:**
- Query complexa usada em 2+ endpoints → extrair para repository/helper
- Validação complexa usada em 2+ routes → extrair middleware ou validator
- Lógica de negócio no controller → mover para service
- Lógica de formatação → extrair serializer

### 5. Acoplamento

Identificar dependências excessivas entre módulos:

- Módulo A importa > 5 coisas de módulo B → acoplamento alto
- Dependência circular (A importa B, B importa A) → **erro arquitetural**
- Módulo "util" com 20+ exports → provavelmente precisa ser dividido

```bash
# Detectar imports circulares
# Para cada arquivo, mapear imports e verificar ciclos
```

### 6. Hierarquia de componentes

Mapear a árvore de componentes/módulos e avaliar:

- Profundidade da árvore (> 5 níveis → considerar flatten)
- Largura (componente com > 10 filhos diretos → considerar agrupamento)
- Componentes "folha" muito grandes → deveriam ser decompostos
- Componentes "container" que só passam props → possível eliminação

## Output

```markdown
# Component Audit Report — {data}

## Resumo

| Categoria | Issues | Severidade |
|---|---|---|
| God components/modules | N | 🟠 |
| Props drilling | N | 🟡 |
| Responsabilidade múltipla | N | 🟡 |
| Oportunidades de extração | N | ⚪ |
| Acoplamento excessivo | N | 🟠/🟡 |
| Dependência circular | N | 🔴 |

## Mapa de componentes

```
App
├── Layout (300 linhas ⚠️)
│   ├── Header (50 linhas ✅)
│   ├── Sidebar (120 linhas ✅)
│   └── Content
│       ├── Dashboard (450 linhas ⛔ god component)
│       └── ...
```

## God components

### [GOD-001] `{path/Component.jsx}` — {N} linhas
- **Responsabilidades encontradas:**
  1. Data fetching (linhas N-N)
  2. Business logic (linhas N-N)
  3. State management (linhas N-N)
  4. UI rendering (linhas N-N)
- **Sugestão de decomposição:**
  - Extrair `useComponentData()` hook (fetch + state)
  - Extrair `ComponentLogic.js` (cálculos)
  - Manter `Component.jsx` só com UI
- **Resultado esperado:** {N} linhas → ~{N} linhas

## Props drilling

### [PROP-001] Prop `{nome}` — {N} níveis
- **Caminho:** A → B → C → D
- **Quem usa:** apenas D
- **Sugestão:** Extrair para Context ou hook customizado

## Oportunidades de extração

### [EXT-001] {descrição}
- **Onde aparece:** `file1.jsx:20-50`, `file2.jsx:30-60`
- **Tipo:** Hook / Componente / Util / Service
- **Sugestão:** Criar `{path/novo-modulo}`

## Dependências

### Módulos mais acoplados
| Módulo | Imports de | Importado por | Acoplamento |
|---|---|---|---|
| `{módulo}` | N módulos | N módulos | Alto ⚠️ |

### Dependências circulares
- ⛔ `{A}` ↔ `{B}` (através de `{função/export}`)
```

## Regras

- Focar em problemas estruturais, não cosméticos
- God component de 400 linhas que faz uma coisa só não é god component — é componente grande
- Props drilling de 2 níveis é aceitável — reportar a partir de 3
- Não refatorar — apenas identificar e sugerir decomposição
- Cada sugestão de extração deve ter resultado esperado (tamanho antes/depois)
- Se o projeto tem padrões definidos (CLAUDE.md), verificar compliance

## Proximos passos

Com base nos findings deste agent:

- **God components, props drilling e acoplamento:** consultar skill `.claude/skills/code-quality/README.md` para padroes de refatoracao e decomposicao
- **Problemas de UX em componentes visuais:** consultar skill `.claude/skills/ux-review/README.md` para validar usabilidade apos refatoracao
- **Criar spec para correcao:** `/spec {ID} {titulo do finding}`
