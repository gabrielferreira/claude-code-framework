<!-- framework-tag: v2.44.0 framework-file: skills/code-quality/README.md -->
# Skill: Code Quality — {NOME_DO_PROJETO}

> **PROATIVA:** Executar ao finalizar qualquer feature, refactor ou PR.
> Rodar ANTES do commit, junto com `definition-of-done`.

## Quando usar

- Ao criar novo arquivo ou módulo
- Ao modificar mais de 1 arquivo na mesma entrega
- Ao adicionar nova rota, service ou componente
- Antes de todo commit que altera arquivos de código
- Quando pedido revisão de qualidade

## Quando NÃO usar

- Alterações apenas em .md, .sql, .json, .yml
- Alterações apenas em .claude/specs/ ou docs/

## Checklist de duplicação

### Verificar antes de commitar

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Busca de funcoes com nomes similares (detecta duplicacao):
```bash
# Encontrar funcoes de validacao espalhadas pelo projeto
grep -rn "function.*validate" src/ --include="*.js" | head -20
# Saida tipica que indica duplicacao:
#   src/routes/users.js:15:  function validateEmail(email) {
#   src/routes/auth.js:8:    function validateEmail(input) {
#   src/services/signup.js:22: function validateEmailFormat(e) {
# -> 3 funcoes fazendo a mesma coisa = extrair para utils/validate.js

# Encontrar constantes duplicadas (precos, limites, configs)
grep -rn "50000\|500\.00\|MAX_UPLOAD" src/ --include="*.{js,ts}" | grep -v node_modules | grep -v test
# Saida tipica:
#   src/routes/billing.js:10:  const MAX_AMOUNT = 50000;
#   src/services/payment.js:5: if (amount > 50000) {
#   src/middleware/upload.js:3: const LIMIT = 50000;
# -> mesmo valor em 3 lugares = extrair para constants.js
```
-->

```bash
# 1. Funcoes duplicadas entre arquivos
# {ADAPTAR: padrao de busca}
grep -rn "function " {src}/*.js | sort -t: -k3 | uniq -d -f2

# 2. Constantes de negocio em mais de um lugar
# {ADAPTAR: valores do projeto}
grep -rn "{valor1}\|{valor2}" {backend}/ {frontend}/ --include="*.js" | grep -v node_modules | grep -v test

# 3. Padroes repetidos que deveriam ser helpers
# {ADAPTAR: patterns do projeto}
```

Se um valor de negocio aparece em mais de 2 arquivos -> extrair para constante compartilhada.

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Antes (duplicacao em 3 arquivos):
```javascript
// src/routes/users.js
function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// src/routes/auth.js
function isValidEmail(input) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(input);
}

// src/services/signup.js
function checkEmail(e) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
}
```

Depois (extraido para helper unico):
```javascript
// src/utils/validate.js  <-- fonte unica de verdade
export function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// src/routes/users.js, auth.js, services/signup.js
import { validateEmail } from '../utils/validate.js';
```
Regra pratica: >3 blocos similares = extrair. >2 constantes iguais = centralizar.
-->

## Regras de qualidade

### Nao duplicar

{Adaptar: fontes unicas de verdade do projeto:}

1. **{Funcoes de seguranca}** -> `{path/security.js}`
2. **{Validacao de IDs}** -> `{path/validate.js}`
3. **{Precos/planos}** -> `{path/pricing.js}`
4. **{Constantes de negocio}** -> `{path/constants.js}`

### Não repetir padrões

1. **{Transaction}** -> usar helper quando disponível
2. **{Error handling}** -> usar pattern base
3. **{Rate limiter}** -> usar factory, não criar inline
4. **{Pagination}** -> usar helper compartilhado

### Métricas de code smell

| Smell | Threshold | Ação |
|---|---|---|
| Função > 50 linhas | > 50 | Extrair subfunções |
| Arquivo > 500 linhas | > 500 | Considerar split |
| Mesmo bloco > 10 linhas em 2+ arquivos | > 10 | Extrair para helper |
| Magic number em mais de 1 arquivo | > 1 | Extrair para constante |
| `SELECT *` em query | qualquer | Listar colunas |
| `console.log` em produção | qualquer | Usar logger estruturado |

## Componentização

### Quando extrair componente/módulo

- Bloco > 50 linhas usado em mais de 1 lugar -> extrair
- Lógica reutilizável (state + effects) -> extrair hook/helper
- Mesmo visual em múltiplas telas -> extrair componente com props
- Componente/módulo > 300 linhas -> considerar split

### Quando extrair para service/helper

- Função > 30 linhas usada em mais de 1 arquivo -> extrair
- Mesma query SQL em 2+ endpoints -> extrair para helper
- Lógica de negócio em handler/controller -> mover para service

## Verificação de sintaxe

### Verificacao por runtime

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Para monorepo com backend Node.js + frontend React:
```bash
# Backend (Node.js)
for f in $(git diff --name-only --cached | grep 'backend/.*\.js$'); do
  node -c "$f" && echo "ok $f" || echo "ERRO $f"
done

# Frontend (TypeScript)
cd frontend && npx tsc --noEmit

# Python (se houver scripts)
for f in $(git diff --name-only --cached | grep '\.py$'); do
  python -m py_compile "$f" && echo "ok $f" || echo "ERRO $f"
done
```
-->

{Adaptar ao runtime do projeto}

**Node.js / JavaScript:**
```bash
for f in $(git diff --name-only --cached | grep '\.js$\|\.jsx$\|\.ts$\|\.tsx$'); do
  node -c "$f" && echo "✓ $f" || echo "✗ $f SYNTAX ERROR"
done
```

**Python:**
```bash
python -m py_compile {arquivo.py}
flake8 --select=E9,F63,F7,F82 {diretório}/
```

**TypeScript:**
```bash
npx tsc --noEmit
```

**Go:**
```bash
go vet ./...
```

**Rust:**
```bash
cargo check
cargo clippy -- -D warnings
```

**Dart:**
```bash
dart analyze --fatal-infos
dart format --set-exit-if-changed .
```

**C# (.NET):**
```bash
dotnet build --no-restore 2>&1 | grep "error CS"
```

Se qualquer arquivo falhar, **NÃO commitar**.

### Build de produção

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

### Padrões suspeitos a buscar

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

# test.only / test.skip esquecido — JS/TS
grep -rn 'test\.only\|test\.skip\|describe\.only\|describe\.skip\|it\.only\|it\.skip\|fdescribe\|fit\|xit\|xdescribe' {tests}/ --include="*.{ext}"

# Debug esquecido — Rust
grep -rn 'dbg!\|println!\|eprintln!\|todo!\|unimplemented!' {src}/ --include="*.rs" | grep -v '#\[allow'
# Suppression sem justificativa — Rust
grep -rn '#\[allow(dead_code)\]\|#\[allow(unused' {src}/ --include="*.rs"

# Debug esquecido — Dart
grep -rn '^\s*print(\|^\s*debugPrint(' {lib}/ --include="*.dart"

# Debug esquecido — C#
grep -rn 'Console\.Write\|Debug\.WriteLine' {src}/ --include="*.cs" | grep -v '// DEBUG\|// intentional'
```

### Imports e módulos

{Adaptar ao module system do projeto}

**CommonJS (require):**
```bash
grep -rn "require(" {src}/ --include="*.js" | grep -v node_modules | grep '\./'
```

**ESM (import/export):**
```bash
# Verificar inconsistências CJS/ESM em módulos compartilhados
grep -n '^export ' {shared}/*.{ext}   # ESM exports
grep -n 'module.exports' {shared}/*.{ext}  # CJS exports
# Se ambos existem no mesmo arquivo → problema
```

## Quando escalar

Se detectar:
- Mesmo código em 3+ lugares -> **PARE e refatore antes de prosseguir**
- Divergência entre cópias -> **PARE — risco de inconsistência**
- Arquivo > 1000 linhas -> criar spec de refatoração

## Integração com verify.sh

Ao adicionar um novo padrão suspeito ao checklist acima, considerar adicionar check correspondente no `scripts/verify.sh` (seção CHECKS EVOLUTIVOS) para validação automática.
