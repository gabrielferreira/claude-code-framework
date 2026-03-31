---
description: Compara specs com o código atual e identifica divergências antes da implementação
---
<!-- framework-tag: v2.2.0 framework-file: agents/spec-validator.md -->
# Agent: Spec Validator

> Sub-agente autônomo que compara specs com o código atual e identifica divergências.
> Executa sob demanda, antes de implementar uma spec.

## Quando usar

- Antes de começar a implementar qualquer spec (obrigatório para Médio+)
- Ao retomar trabalho em spec parcial
- Periodicamente para validar specs ativas contra o código

## Input

- ID da spec (ex: `SEC7`, `FE1.2`) ou path do arquivo (`.claude/specs/SEC7-rate-limit.md`)
- Escopo opcional: `full` (valida tudo), `files` (só arquivos), `behavior` (só comportamento)

## O que verificar

### 1. Arquivos mencionados existem

Para cada arquivo listado na spec (seções "Arquivos afetados", "Onde", paths em backticks):
- Verificar se o arquivo existe no path indicado
- Se não existe: reportar como **Divergência — arquivo não encontrado**
- Se foi renomeado/movido: identificar o novo path (grep pelo nome do arquivo ou conteúdo característico)

### 2. Funções e estruturas mencionadas existem

Para cada função, classe, hook, componente ou variável mencionada na spec:
- Verificar que existe no arquivo indicado
- Verificar assinatura (params, return type) se a spec especifica
- Se foi renomeada: identificar o novo nome

### 3. Comportamento descrito é verdadeiro

Para cada premissa comportamental na spec (ex: "o endpoint retorna 404 se não encontra"):
- Ler o código e confirmar que o comportamento descrito é o que o código faz
- Se o código faz diferente: reportar como **Divergência — comportamento diferente**

### 4. Dependências da spec estão satisfeitas

- Verificar se specs dependentes (campo "Deps") estão concluídas
- Se uma dependência não está concluída, verificar se isso bloqueia a implementação

### 5. Critérios de aceitação são testáveis

Para cada critério de aceitação:
- Verificar que é específico o bastante para virar assertion em teste
- Se é vago ("funcionar bem", "ser rápido"), reportar como **Critério não testável**

### 6. Escopo negativo é claro

- Verificar se a seção "Não fazer" existe e tem itens concretos
- Se não existe em spec Média+, reportar como **Escopo negativo ausente**

## Output

```markdown
# Spec Validation Report — {spec_id}

## Status: ✅ Válida | ⚠️ Divergências | ❌ Desatualizada

## Spec
- **ID:** {id}
- **Título:** {título}
- **Status:** {status atual}
- **Última modificação:** {data}

## Divergências encontradas

### [DIV-001] {título}
- **Tipo:** Arquivo não encontrado | Comportamento diferente | Função renomeada | Critério não testável | Escopo negativo ausente
- **Na spec:** {o que a spec diz}
- **No código:** {o que o código mostra}
- **Impacto:** Bloqueia implementação | Requer atualização da spec | Informativo
- **Sugestão:** {como resolver}

## Validações realizadas

| Check | Status | Detalhe |
|---|---|---|
| Arquivos existem | ✅/❌ | N de M encontrados |
| Funções/estruturas | ✅/❌ | N de M encontradas |
| Comportamento | ✅/❌ | N premissas verificadas |
| Dependências | ✅/❌ | N de M concluídas |
| Critérios testáveis | ✅/❌ | N de M são testáveis |
| Escopo negativo | ✅/❌ | Presente e concreto |

## Recomendação

{Uma das opções:}
- ✅ Spec válida — pode implementar
- ⚠️ Atualizar spec antes de implementar (lista de mudanças sugeridas)
- ❌ Spec desatualizada — requer reescrita significativa
```

## Regras

- Ler TODA a spec antes de começar a validar
- Abrir CADA arquivo mencionado — não assumir que existe
- Reportar divergências com evidência (linha do código vs. texto da spec)
- Não corrigir a spec automaticamente — apenas reportar. Correção é decisão do SWE
- Se a spec tem Notion Page ID, verificar se o conteúdo local e o Notion estão sincronizados
