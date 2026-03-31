<!-- framework-tag: v2.1.0 framework-file: skills/docs-sync/README.md -->
# Skill: Docs Sync — {NOME_DO_PROJETO}

> Use esta skill ao finalizar qualquer entrega para garantir que a documentação
> está sincronizada com o código. Docs desatualizadas é o gap mais recorrente.

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

```bash
#!/bin/bash
# Rodar após completar uma feature para verificar sync

echo "=== Contagem de testes ==="
# {ADAPTAR: padrão de contagem de testes}
REAL=$(grep -c "test(" {tests}/*.test.js | awk -F: '{s+=$2} END {print s}')
echo "Real: $REAL testes"

echo ""
echo "=== Endpoints no código vs docs ==="
echo "Rotas reais:"
# {ADAPTAR: padrão de contagem de rotas}
grep "router\.\(get\|post\|put\|delete\)" {routes}/*.js | wc -l
```

## Contagens a manter sincronizadas

{Listar contagens que devem bater entre código e docs:}

- Testes: {N} ({comando para verificar})
- Suites: {N} ({comando})
- Tabelas no schema: {N}
- Endpoints: {N}
- {outras contagens relevantes}

## Regras

1. **Nunca commitar feature sem atualizar docs.** 100% dos gaps de doc vêm de features commitadas sem sync.
2. **Contagem de testes é um número exato.** Atualizar ao adicionar/remover.
3. **Docs user-facing são obrigatórios para features visíveis.** Se o usuário vê algo novo, o guia reflete.
4. **Na dúvida, atualize.** Melhor um doc com frase a mais que doc desatualizado.
