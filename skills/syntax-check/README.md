# Skill: Syntax Check — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ANTES de commitar, como parte da verificação pós-implementação.
> Complementa o `verify.sh` — foca em erros de sintaxe e padrões suspeitos que passam despercebidos.

## Quando usar

- Antes de todo commit que altera arquivos de código
- Ao finalizar qualquer implementação (junto com verify.sh)
- Quando um erro inexplicável aparece em produção

## Quando NÃO usar

- Alterações apenas em .md, .sql, .json, .yml
- Alterações apenas em .claude/specs/ ou docs/

## Checklist de verificação

### 1. Verificação de sintaxe

{Adaptar ao runtime do projeto}

**Node.js / JavaScript:**
```bash
# Verificar sintaxe de todos os arquivos alterados
for f in $(git diff --name-only --cached | grep '\.js$\|\.jsx$\|\.ts$\|\.tsx$'); do
  node -c "$f" && echo "✓ $f" || echo "✗ $f SYNTAX ERROR"
done
```

**Python:**
```bash
# Verificar sintaxe
python -m py_compile {arquivo.py}
# Ou com flake8
flake8 --select=E9,F63,F7,F82 {diretório}/
```

**TypeScript:**
```bash
npx tsc --noEmit
```

Se qualquer arquivo falhar, **NÃO commitar**.

### 2. Build de produção

{Adaptar ao bundler do projeto}

```bash
# Vite
cd {frontend} && npx vite build 2>&1 | grep -E "error|✓ built"

# Next.js
npm run build 2>&1 | grep -E "error|✓"

# Webpack
npx webpack --mode production 2>&1 | grep -E "ERROR|compiled"
```

Build falho = erro de sintaxe ou import quebrado. **NÃO commitar.**

### 3. Padrões suspeitos a buscar

```bash
# Console.log esquecido em código de produção
grep -rn 'console\.log(' {src}/routes/ {src}/services/ {src}/middleware/ --include="*.{ext}" | grep -v node_modules | grep -v '// DEBUG'

# Template literals em queries SQL (SQL injection risk)
grep -rn '`.*\$\{.*\}.*FROM\|`.*\$\{.*\}.*WHERE\|`.*\$\{.*\}.*INSERT' {src}/ --include="*.{ext}" | grep -v node_modules

# Catch vazio (engole erro silenciosamente)
grep -rn 'catch\s*{' {src}/ --include="*.{ext}" | grep -v node_modules | grep -v '// silent\|// intentional'

# TODO/FIXME/HACK esquecidos
grep -rn 'TODO\|FIXME\|HACK\|XXX' {src}/ --include="*.{ext}" | grep -v node_modules

# Debugger esquecido
grep -rn 'debugger' {src}/ --include="*.{ext}" | grep -v node_modules

# test.only / test.skip esquecido
grep -rn 'test\.only\|test\.skip\|describe\.only\|describe\.skip\|it\.only\|it\.skip\|fdescribe\|fit\|xit\|xdescribe' {tests}/ --include="*.{ext}"
```

### 4. Imports e módulos

{Adaptar ao module system do projeto}

**CommonJS (require):**
```bash
# Verificar que requires apontam para arquivos existentes
grep -rn "require(" {src}/ --include="*.js" | grep -v node_modules | grep '\./' | while read line; do
  file=$(echo "$line" | sed 's/.*require("\(.*\)").*/\1/')
  # Verificar se arquivo existe
done
```

**ESM (import/export):**
```bash
# Verificar inconsistências CJS/ESM em módulos compartilhados
grep -n '^export ' {shared}/*.{ext}   # ESM exports
grep -n 'module.exports' {shared}/*.{ext}  # CJS exports
# Se ambos existem no mesmo arquivo → problema
```

## Integração com verify.sh

Ao adicionar um novo padrão suspeito ao checklist acima, considerar adicionar check correspondente no `scripts/verify.sh` (seção CHECKS EVOLUTIVOS) para validação automática.
