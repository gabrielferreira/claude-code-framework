<!-- framework-tag: v2.8.0 framework-file: skills/syntax-check/README.md -->
# Skill: Syntax Check

> **PROATIVA:** Executar ANTES de commitar, como parte da verificação pós-implementação.
> Complementa o `verify.sh` — foca em erros de sintaxe que passam despercebidos.

## Quando usar

- Antes de todo commit que altera código-fonte
- Ao finalizar qualquer implementação (junto com verify.sh)
- Quando um erro inexplicável aparece em produção

## Checklist de verificação

### 1. Validação de sintaxe

```bash
# Backend (Node.js)
for f in $(git diff --name-only --cached | grep '\.js$' | grep '^{backend}/'); do
  node -c "$f" && echo "✓ $f" || echo "✗ $f SYNTAX ERROR"
done

# Frontend (build check)
cd {frontend} && {build command} 2>&1 | grep -E "error|✓ built"
```

Se qualquer arquivo falhar, **não commitar**.

{Adaptar para a stack do projeto: `tsc --noEmit` para TypeScript, `python -m py_compile` para Python, `go vet` para Go, etc.}

### 2. Padrões suspeitos a buscar

```bash
# console.log/print esquecido em código de produção
grep -rn 'console\.log(' {src}/routes/ {src}/middleware/ {src}/services/ --include="*.{ext}" | grep -v node_modules | grep -v '// DEBUG'

# Template literals em queries SQL (injection risk)
grep -rn '`.*\$\{.*\}.*FROM\|`.*\$\{.*\}.*WHERE\|`.*\$\{.*\}.*INSERT\|`.*\$\{.*\}.*UPDATE\|`.*\$\{.*\}.*DELETE' {src}/ --include="*.{ext}" | grep -v node_modules

# Catch vazio (engole erro silenciosamente)
grep -rn 'catch\s*{' {src}/ --include="*.{ext}" | grep -v node_modules | grep -v '// silent'

# TODO/FIXME/HACK esquecidos
grep -rn 'TODO\|FIXME\|HACK\|XXX' {src}/ --include="*.{ext}" | grep -v node_modules

# debugger/breakpoint statements
grep -rn 'debugger' {src}/ --include="*.{ext}"

# test.only/describe.only (bloqueia CI)
grep -rn 'test\.only\|describe\.only\|it\.only' {tests}/ --include="*.{ext}"

# test.skip sem justificativa
grep -rn 'test\.skip\|describe\.skip\|it\.skip' {tests}/ --include="*.{ext}"
```

### 3. Module system consistency

{Adaptar para o projeto:}

```bash
# Se o projeto usa CommonJS no backend:
# Verificar que não mistura export/module.exports no mesmo módulo
grep -n '^export ' {backend}/*.{ext}
# Se encontrar export sem module.exports → pode quebrar o bundler

# Se o projeto usa ESM:
# Verificar que não mistura require/import no mesmo módulo
grep -n 'require(' {frontend}/src/ --include="*.{ext}" -r
```

### 4. Import de arquivos inexistentes

Detectado automaticamente pelo validador de sintaxe e build command acima. Se passa na validação mas falha em runtime, verificar:
- Imports condicionais (lazy loading)
- Imports em caminhos dinâmicos
- Aliases não resolvidos

## Integração com verify.sh

Adicionar estes checks na seção CHECKS EVOLUTIVOS do `scripts/verify.sh` conforme o projeto evolui.

## Quando NÃO usar

- Alterações apenas em arquivos de documentação (.md)
- Alterações apenas em specs ou configs (.json, .yml, .sql)
- Alterações apenas em assets estáticos (imagens, fontes)
