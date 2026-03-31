---
description: Analisa qualidade do código — duplicação, complexidade, dead code e inconsistências
worktree: false
---
<!-- framework-tag: v2.3.0 framework-file: agents/code-review.md -->
# Agent: Code Review

> Sub-agente autônomo que analisa qualidade do código e identifica problemas.
> Executa sob demanda para encontrar duplicação, complexidade, dead code e inconsistências.

## Quando usar

- Antes de PR ou merge
- Após refatoração significativa
- Periodicamente para saúde do codebase
- Quando o codebase cresce e precisa de limpeza

## Input

- Path do repositório ou diretório específico
- Escopo opcional: `duplication`, `complexity`, `dead-code`, `patterns`, `deps`, `full` (todos)

## O que verificar

### 1. Duplicação de código

Identificar blocos de código duplicados ou muito similares:

```bash
# Funções com mesmo nome em arquivos diferentes
grep -rn "function \|const .* = (" {src}/ --include="*.{ext}" | grep -v node_modules | grep -v test | sort -t: -k3

# Constantes de negócio em mais de 1 lugar
# {Adaptar: valores específicos do projeto}
```

Para cada duplicação encontrada:
- Listar os N arquivos onde aparece
- Classificar: exata (copy-paste) ou similar (mesma lógica, implementação diferente)
- Sugerir: extrair para helper/util/constante compartilhada
- Indicar onde a fonte única de verdade deveria morar

**Thresholds:**
- Mesmo bloco > 10 linhas em 2+ arquivos → **reportar**
- Mesmo bloco > 5 linhas em 3+ arquivos → **reportar**
- Constante de negócio em 2+ arquivos → **reportar**

### 2. Complexidade

Identificar código excessivamente complexo:

- **Funções longas:** > 50 linhas → sugerir extração
- **Arquivos grandes:** > 500 linhas → sugerir split
- **Aninhamento profundo:** > 3 níveis de if/for/try → sugerir early return ou extração
- **Muitos parâmetros:** > 4 params → sugerir objeto de configuração
- **Switch/if-else extenso:** > 5 cases → sugerir lookup table ou strategy pattern

### 3. Dead code

Identificar código que não é usado:

```bash
# Exports não importados por ninguém
# Para cada export em {src}/, verificar se há import correspondente

# Funções definidas mas nunca chamadas
# Variáveis atribuídas mas nunca lidas

# Arquivos não importados por nenhum outro arquivo
```

Para cada dead code encontrado:
- Confirmar que não é usado (pode ser entry point, CLI handler, ou dynamic import)
- Classificar: com certeza morto | provavelmente morto | verificar manualmente

### 4. Inconsistência de patterns

Identificar quando o mesmo problema é resolvido de formas diferentes:

- Error handling: uns usam try/catch, outros usam .catch(), outros não tratam
- Auth: uns usam middleware, outros verificam inline
- Validação: uns usam lib, outros fazem manual
- Queries: uns usam helper, outros fazem inline
- Imports: CJS e ESM misturados no mesmo módulo

Para cada inconsistência:
- Identificar qual pattern é o predominante (padrão do projeto)
- Listar os arquivos que desviam
- Sugerir padronização

### 5. Dependências

```bash
# Pacotes instalados mas não usados
# Verificar cada dependência de package.json contra imports no código

# Pacotes duplicados (mesmo propósito, libs diferentes)
# Ex: axios + node-fetch + got → padronizar em 1
```

### 6. Code smells gerais

- Magic numbers sem constante nomeada
- `console.log` em código de produção (deveria usar logger)
- `SELECT *` em queries
- Catch vazio que engole erros
- TODO/FIXME/HACK não resolvidos
- `any` type em TypeScript (se aplicável)
- Callbacks aninhados (callback hell)

## Output

```markdown
# Code Review Report — {data}

## Resumo

| Categoria | Issues | Severidade mais alta |
|---|---|---|
| Duplicação | N | 🟠/🟡 |
| Complexidade | N | 🟠/🟡 |
| Dead code | N | 🟡/⚪ |
| Inconsistência | N | 🟡 |
| Dependências | N | ⚪ |
| Code smells | N | 🟡/⚪ |

## Duplicação

### [DUP-001] {descrição}
- **Arquivos:** `file1.js:20-35`, `file2.js:40-55`
- **Tipo:** Exata / Similar
- **Sugestão:** Extrair para `{path}/helpers/{nome}.js`

## Complexidade

### [CX-001] {arquivo}:{função}
- **Linhas:** N
- **Aninhamento máximo:** N
- **Sugestão:** {como simplificar}

## Dead code

### [DC-001] {arquivo}:{export}
- **Certeza:** Alta / Média / Baixa
- **Sugestão:** Remover / Verificar manualmente

## Inconsistências

### [INC-001] {pattern}
- **Padrão do projeto:** {como a maioria faz}
- **Desvios:** `file1.js`, `file2.js`
- **Sugestão:** Padronizar seguindo {padrão}

## Métricas gerais

| Métrica | Valor | Threshold | Status |
|---|---|---|---|
| Maior arquivo | N linhas | 500 | ✅/⚠️ |
| Maior função | N linhas | 50 | ✅/⚠️ |
| Magic numbers | N | 0 | ✅/⚠️ |
| console.log em prod | N | 0 | ✅/❌ |
| TODOs não resolvidos | N | — | ℹ️ |
```

## Regras

- Focar em problemas reais, não em estilo (formatação, naming conventions)
- Duplicação de código de teste é aceitável — não reportar
- Dead code em entry points (main, CLI handlers, route handlers) não é dead code
- Não refatorar — apenas identificar e sugerir. Refatoração vira spec
- Se o projeto tem fontes únicas de verdade definidas (CLAUDE.md/code-quality skill), verificar compliance
