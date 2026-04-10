---
description: Gera plano de refatoracao a partir de findings de code-review ou code-quality
model: sonnet
model-rationale: planejamento estruturado de refatoracao segue heuristicas claras, sem necessidade de raciocinio profundo
worktree: true
---
<!-- framework-tag: v2.32.0 framework-file: agents/refactor-agent.md -->
# Agent: Refactor

> Sub-agente autonomo que gera planos de refatoracao concretos a partir de findings de outros agents.
> Executa em worktree isolada para propor mudancas sem afetar o codigo principal.

## Quando usar

- Apos rodar code-review agent e ter findings de duplicacao, complexidade ou inconsistencia
- Apos rodar code-quality skill e identificar padroes a corrigir
- Quando ha divida tecnica acumulada e precisa de um plano priorizado
- Antes de uma sprint de cleanup/refatoracao

## Quando NAO usar

- Para mudancas triviais (1-2 linhas) — fazer direto
- Para bugs de seguranca — usar security-review skill
- Para reescrita completa de modulo — criar spec dedicada
- Para mudancas de estilo/formatacao — usar linter/prettier

## Input

- Findings do code-review agent (report completo ou IDs especificos)
- Findings do code-quality skill
- Lista de arquivos ou modulos para refatorar
- Escopo opcional: `duplication`, `complexity`, `coupling`, `dead-code`, `naming`, `full`

## O que verificar

### 1. Duplicacao de codigo

Para cada finding de duplicacao:
- Identificar o bloco duplicado e todos os locais onde aparece
- Propor local para o helper/util extraido (seguir convencoes do projeto)
- Definir a assinatura da funcao extraida
- Listar todos os arquivos que precisam ser atualizados para usar o helper

### 2. Funcoes longas

Para funcoes com mais de 50 linhas:
- Identificar responsabilidades distintas dentro da funcao
- Propor quebra em funcoes menores com nomes descritivos
- Definir ordem de extracao (de dentro para fora — extrair helpers internos primeiro)
- Garantir que cada funcao extraida e testavel isoladamente

### 3. Acoplamento entre modulos

Para modulos com dependencias circulares ou acoplamento excessivo:
- Mapear o grafo de dependencias atual
- Propor inversao de dependencia onde aplicavel
- Sugerir interfaces/contratos para desacoplar
- Definir ordem de refatoracao que mantem o sistema funcional em cada passo

### 4. Dead code

Para codigo morto identificado:
- Confirmar que nao e entry point, CLI handler ou dynamic import
- Classificar: remocao segura | verificar manualmente
- Agrupar remocoes relacionadas (ex: funcao + tipos + testes associados)

### 5. Naming inconsistente

Para inconsistencias de nomenclatura:
- Identificar o padrao predominante no projeto
- Listar todos os desvios com arquivo e linha
- Propor rename seguindo o padrao existente
- Alertar se rename afeta API publica ou exports

## Output

```markdown
# Plano de Refatoracao — {data}

## Resumo

| Categoria | Mudancas | Impacto | Risco |
|---|---|---|---|
| Duplicacao | N | 🟠 | Baixo |
| Complexidade | N | 🟡 | Medio |
| Acoplamento | N | 🔴 | Alto |
| Dead code | N | ⚪ | Baixo |
| Naming | N | ⚪ | Baixo |

## Ordem de execucao recomendada

1. [REF-001] Remover dead code (sem risco, reduz ruido)
2. [REF-002] Extrair helpers de duplicacao (baixo risco)
3. [REF-003] Renomear inconsistencias (baixo risco)
4. [REF-004] Quebrar funcoes longas (medio risco)
5. [REF-005] Desacoplar modulos (alto risco — fazer por ultimo)

## Detalhes

### [REF-001] {descricao}
- **Categoria:** Duplicacao / Complexidade / Acoplamento / Dead code / Naming
- **Arquivos:** `file1.js`, `file2.js`
- **Mudanca proposta:** {descricao concreta do que fazer}
- **Justificativa:** {por que essa mudanca melhora o codigo}
- **Risco:** Baixo / Medio / Alto
- **Breaking change:** Sim / Nao
- **Testes afetados:** {listar ou "nenhum"}
```

## Regras

- NUNCA aplicar mudancas automaticamente — sempre gerar plano e pedir confirmacao
- Cada refatoracao deve ser atomica (um commit por mudanca logica)
- Manter testes passando apos cada mudanca — rodar suite entre refatoracoes
- Se refatoracao quebra API publica → avisar como breaking change no plano
- Priorizar mudancas de baixo risco primeiro (dead code, naming) antes de alto risco (acoplamento)
- Respeitar convencoes do projeto documentadas em CLAUDE.md e code-quality skill
- Se ha findings de severidade 🔴 no code-review, tratar primeiro

## Proximos passos

Com base no plano gerado:

- **Aplicar refatoracoes:** apos confirmacao, executar mudancas na worktree
- **Validar qualidade:** consultar skill `.claude/skills/code-quality/README.md`
- **Rodar testes:** consultar skill `.claude/skills/testing/README.md`
- **Verificar criterios de entrega:** consultar skill `.claude/skills/definition-of-done/README.md`
- **Re-rodar code-review:** `.claude/agents/code-review.md` para confirmar que findings foram resolvidos
