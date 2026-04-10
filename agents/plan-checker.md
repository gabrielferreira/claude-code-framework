---
description: Valida se o execution-plan cobre todos os RFs e critérios de aceitação da spec
model: sonnet
model-rationale: Checklist estruturado de cobertura — comparação metódica sem julgamento profundo.
worktree: false
---
<!-- framework-tag: v2.31.0 framework-file: agents/plan-checker.md -->
# Agent: Plan Checker

> Sub-agente autônomo que valida se o execution-plan cobre todos os requisitos da spec.
> Executa antes de implementar para garantir que nenhum RF ou critério ficou sem task correspondente.

## Quando usar

- Após gerar o execution-plan (`{id}-plan.md`), antes de iniciar a implementação
- Ao retomar trabalho em spec parcial — verificar se o plano ainda está completo
- Standalone (`/plan-checker {ID}`) quando quiser verificar o plano sem rodar o spec-validator completo

## Input

- ID da spec (ex: `SEC7`, `FE1.2`) ou path do arquivo (`.claude/specs/FE1-login.md`)
- O agent localiza automaticamente `{id}-plan.md` no mesmo diretório

## O que verificar

### 1. Localizar e ler a spec

Encontrar o arquivo de spec em `.claude/specs/`:
- Buscar por `{id}-*.md` (ex: `FE1-login.md`)
- Extrair da spec: todos os RFs (Requisitos Funcionais), critérios de aceitação, e seção "Não fazer"
- Se a spec não existir: reportar erro e encerrar

### 2. Verificar se o execution-plan existe

Verificar se `.claude/specs/{id}-plan.md` existe:

- **Não existe:** reportar ⚪ Info — "Sem execution-plan para validar. Gerar o plano com `/execution-plan {ID}` antes de implementar." Encerrar sem erro.
- **Existe:** continuar para os checks abaixo

### 3. Cobertura dos RFs

Para cada RF da spec:

```
RF-001: {descrição do requisito}
→ task-N: {nome da task} — cobre porque {motivo}
→ Status: ✅ coberto | ⚠️ parcialmente coberto | ❌ sem task correspondente
```

- ✅ **Coberto:** pelo menos uma task do plano endereça este RF explicitamente (nome, descrição ou arquivos afetados)
- ⚠️ **Parcialmente coberto:** uma task toca o RF mas deixa parte do comportamento sem implementação clara — documentar o gap
- ❌ **Não coberto:** nenhuma task do plano corresponde a este RF

### 4. Cobertura dos critérios de aceitação

Para cada critério de aceitação da spec:

```
CA-001: {descrição do critério}
→ task-N: {nome da task} — cobre porque {motivo}
→ Status: ✅/⚠️/❌
```

Aplicar as mesmas regras do check 3.

### 5. Orphan tasks

Para cada task do execution-plan:
- Qual RF ou critério ela endereça?
- Se nenhum: classificar como orphan — pode ser setup/infra legítimo, mas deve ser explicitado

Orphan tasks não são erro por si — setup, migrations, infra e refatoração interna podem não ter RF direto. O objetivo é tornar explícito, não bloquear.

### 6. Cobertura total

Calcular:
- N de M RFs cobertos (✅ + ⚠️)
- N de M critérios cobertos (✅ + ⚠️)
- N tasks orphans

## Output

```markdown
# Plan Coverage Report — {spec_id}

## Status: ✅ Cobertura completa | ⚠️ Gaps identificados | ❌ Cobertura insuficiente

**Spec:** `.claude/specs/{id}-{titulo}.md`
**Plano:** `.claude/specs/{id}-plan.md`

## Cobertura dos RFs

| RF | Descrição | Cobertura | Task(s) | Gap |
|---|---|---|---|---|
| RF-001 | {texto} | ✅ | task-1 | — |
| RF-002 | {texto} | ⚠️ | task-2 | {o que faltou cobrir} |
| RF-003 | {texto} | ❌ | — | Sem task correspondente |

## Cobertura dos critérios de aceitação

| Critério | Cobertura | Task(s) | Gap |
|---|---|---|---|
| CA-001: {texto} | ✅ | task-1, task-3 | — |
| CA-002: {texto} | ❌ | — | Sem task correspondente |

## Tasks sem RF mapeado (orphans)

- **task-4:** {descrição} — setup/infra (sem RF direto)
- **task-5:** {descrição} — verificar se deveria ser removida ou tem RF implícito

## Resumo

| Métrica | Cobertos | Total | % |
|---|---|---|---|
| RFs | N | M | X% |
| Critérios de aceitação | N | M | X% |
| Tasks orphans | — | K | — |

## Recomendação

{Uma das opções:}
- ✅ Cobertura completa — pode implementar
- ⚠️ Gaps encontrados — revisar o execution-plan antes de implementar (ver gaps acima)
- ❌ Cobertura insuficiente — execution-plan precisa ser refeito para cobrir todos os RFs
```

## Regras

- Ler a spec completa antes de começar — não assumir quais seções existem
- Se `{id}-plan.md` não existe: reportar ⚪ Info e encerrar — não é falha do agente
- Não editar o plano nem a spec — apenas reportar. Correção é decisão do SWE
- Orphan tasks devem ser listadas, não bloqueadas — o SWE decide se são legítimas
- Se a spec não tem RFs explícitos (seção "Requisitos Funcionais"), buscar requisitos em "O que fazer", "Critérios", ou seção de comportamento esperado

## Proximos passos

Com base nos findings deste agent:

- **Gaps de cobertura:** revisar e atualizar o execution-plan com a skill `.claude/skills/execution-plan/README.md`
- **RFs vagos ou critérios não testáveis:** atualizar a spec via `.claude/skills/spec-driven/README.md`
- **Spec desatualizada:** rodar `spec-validator.md` para verificação completa antes de replanejar
