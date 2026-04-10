<!-- framework-tag: v2.30.0 framework-file: skills/docs-sync/README.md -->
# Skill: Docs Sync — {NOME_DO_PROJETO}

> Use esta skill ao finalizar qualquer entrega para garantir que a documentação
> está sincronizada com o código. Docs desatualizadas é o gap mais recorrente.

## Quando usar

- Ao finalizar qualquer entrega antes de abrir PR
- Ao adicionar nova feature visível ao usuário
- Quando alterar fluxo, endpoint, schema ou convenção documentada

## Quando NÃO usar

- Para commits de código sem impacto em docs (refactor interno, ajuste de test)
- Se o projeto ainda não tem docs (criar os docs primeiro)
- Para updates de docs puros sem mudança de código — editar direto

## Mapa de documentação

### Docs de projeto (raiz)

| Arquivo | Propósito | Quando atualizar |
|---|---|---|
| `CLAUDE.md` | Regras, convenções, contexto de negócio | Mudança de regra, convenção, contagem de testes |
| `README.md` | Visão geral para devs | Mudança de stack, setup, feature principal |
| {outros docs de projeto} | {propósito} | {gatilho} |

### Docs técnicos

| Arquivo | Propósito | Quando atualizar |
|---|---|---|
| {`docs/ARCHITECTURE.md`} | {Arquitetura do sistema} | {Mudança estrutural} |
| {`docs/API.md`} | {Documentação de API} | {Novo endpoint, mudança de contrato} |
| {`docs/SECURITY.md`} | {Postura de segurança} | {Nova proteção, mudança de auth} |
| {outros docs técnicos} | {propósito} | {gatilho} |

### Docs user-facing

| Arquivo | Propósito | Quando atualizar |
|---|---|---|
| {`docs/USER_GUIDE.md`} | {Manual do usuário} | {Feature visível, mudança de fluxo} |
| {`docs/ADMIN_GUIDE.md`} | {Manual do admin} | {Endpoint admin, funcionalidade admin} |

## Matriz de impacto: feature -> docs

| Tipo de mudança | Docs obrigatórios | Docs condicionais |
|---|---|---|
| Nova rota API | `CLAUDE.md` | API docs, Security docs |
| Feature visível ao usuário | User guide, Help/FAQ | Termos de uso |
| Fix de segurança | Security docs | Audit docs |
| Mudança de stack/infra | `README.md` | Docker, .env.example |
| Novo teste | `CLAUDE.md` (contagem) | |
| {tipo específico} | {docs} | {docs} |

## Verificação automatizada pré-commit

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Script completo para projeto Node.js + Express:
```bash
#!/bin/bash
echo "=== Contagem de testes ==="
REAL=$(grep -rc "test(\|it(" tests/ --include="*.test.js" | awk -F: '{s+=$2} END {print s}')
DOCS=$(grep -oP 'Testes: \K[0-9]+' CLAUDE.md)
echo "Real: $REAL testes | Docs: $DOCS"
[ "$REAL" != "$DOCS" ] && echo "DIVERGENCIA: atualizar CLAUDE.md"

echo ""
echo "=== Endpoints ==="
ROTAS=$(grep -rc "router\.\(get\|post\|put\|delete\|patch\)" src/routes/ --include="*.js" | awk -F: '{s+=$2} END {print s}')
echo "Rotas no codigo: $ROTAS"

echo ""
echo "=== Tabelas no schema ==="
TABELAS=$(grep -c "CREATE TABLE" database/schema.sql)
echo "Tabelas: $TABELAS"
```
-->
<!-- Script completo para projeto Django/Python:
```bash
#!/bin/bash
echo "=== Contagem de testes ==="
REAL=$(grep -rc "def test_" tests/ --include="*.py" | awk -F: '{s+=$2} END {print s}')
echo "Real: $REAL testes"

echo ""
echo "=== Endpoints ==="
ROTAS=$(grep -rc "path(\|re_path(" */urls.py | awk -F: '{s+=$2} END {print s}')
echo "Rotas no codigo: $ROTAS"

echo ""
echo "=== Models ==="
MODELS=$(grep -rc "class.*models.Model" */models.py | awk -F: '{s+=$2} END {print s}')
echo "Models: $MODELS"
```
-->

```bash
#!/bin/bash
# Rodar apos completar uma feature para verificar sync

echo "=== Contagem de testes ==="
# {ADAPTAR: padrao de contagem de testes}
REAL=$(grep -c "test(" {tests}/*.test.js | awk -F: '{s+=$2} END {print s}')
echo "Real: $REAL testes"

echo ""
echo "=== Endpoints no codigo vs docs ==="
echo "Rotas reais:"
# {ADAPTAR: padrao de contagem de rotas}
grep "router\.\(get\|post\|put\|delete\)" {routes}/*.js | wc -l
```

## Contagens a manter sincronizadas

<!-- Exemplo concreto — adaptar ou remover -->
<!-- Contagens para projeto Node.js + PostgreSQL:
- Testes: 142 (`grep -rc "test(\|it(" tests/ --include="*.test.js" | awk -F: '{s+=$2} END {print s}'`)
- Suites: 12 (`ls tests/*.test.js | wc -l`)
- Tabelas: 15 (`grep -c "CREATE TABLE" database/schema.sql`)
- Endpoints: 34 (`grep -rc "router\.\(get\|post\|put\|delete\|patch\)" src/routes/ --include="*.js" | awk -F: '{s+=$2} END {print s}'`)
- Migrations: 23 (`ls database/migrations/*.js | wc -l`)

Exemplo de secao no CLAUDE.md que deve bater:
  ## Metricas do projeto
  - **142 testes** em 12 suites (jest)
  - **34 endpoints** REST
  - **15 tabelas** no schema PostgreSQL

Quando adicionar teste: rodar contagem, atualizar numero no CLAUDE.md.
-->

{Adaptar: contagens que devem bater entre codigo e docs:}

- Testes: {N} ({comando para verificar})
- Suites: {N} ({comando})
- Tabelas no schema: {N}
- Endpoints: {N}
- {outras contagens relevantes}

## Checklist

- [ ] `CLAUDE.md` atualizado se mudou regra, convenção ou contagem de testes
- [ ] Docs técnicos atualizados conforme a matriz de impacto acima
- [ ] Docs user-facing atualizados se feature é visível ao usuário
- [ ] Links e referências cruzadas verificados
- [ ] Verificação automatizada executada (ver seção acima)

## Regras

1. **Nunca commitar feature sem atualizar docs.** 100% dos gaps de doc vêm de features commitadas sem sync.
2. **Contagem de testes é um número exato.** Atualizar ao adicionar/remover.
3. **Docs user-facing são obrigatórios para features visíveis.** Se o usuário vê algo novo, o guia reflete.
4. **Na dúvida, atualize.** Melhor um doc com frase a mais que doc desatualizado.
