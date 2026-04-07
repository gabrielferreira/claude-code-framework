<!-- framework-tag: v2.17.1 framework-file: skills/golden-tests/README.md -->
# Skill: Golden Tests (Snapshot Testing)

> Use esta skill ao criar, modificar ou revisar golden tests (snapshot tests).
> Aplicável a backend (HTTP endpoints) e frontend (componentes).

## O que são Golden Tests

Golden tests capturam a **resposta completa** de um endpoint ou componente como snapshot. Se o comportamento mudar (intencional ou não), o teste falha mostrando o diff entre o esperado e o atual. O desenvolvedor então decide: atualizar o snapshot (mudança intencional) ou corrigir o código (regressão).

**Diferença dos unit tests:**
- Unit tests: assertions manuais (`expect(res.status).toBe(200)`)
- Golden tests: snapshot da resposta inteira (`expect(res).toMatchSnapshot()`)

Os dois coexistem. Unit tests validam regras de negócio específicas. Golden tests detectam **qualquer** mudança na interface (status, headers, body shape, mensagens).

## Quando usar golden tests

- Endpoints HTTP: capturar response completo (status + body + headers relevantes)
- Componentes UI: capturar render output (DOM tree ou markup)
- APIs internas: capturar return shape de funções públicas
- Configs/schemas: capturar output de geradores

## Quando NÃO usar

- Dados altamente dinâmicos sem serializer (timestamps, IDs aleatórios)
- Testes que dependem de estado externo (DB real, APIs)
- Outputs muito grandes (>100 linhas) — dificulta review do diff

## Estrutura recomendada

```
{tests}/golden/
├── __snapshots__/          # Gerado automaticamente pelo test runner
│   └── *.test.{ext}.snap
├── {module-a}.golden.test.{ext}
├── {module-b}.golden.test.{ext}
└── helpers.{ext}           # Setup compartilhado (mocks, serializers)
```

## Custom Serializers (essencial)

Golden tests precisam de serializers para normalizar dados dinâmicos. Sem eles, snapshots quebram a cada execução.

**Dados que DEVEM ser normalizados:**

| Tipo | Exemplo | Serializer |
|---|---|---|
| Timestamps | `2024-01-15T10:30:00Z` | `→ "[TIMESTAMP]"` |
| UUIDs | `550e8400-e29b-41d4-a716-446655440000` | `→ "[UUID]"` |
| Tokens JWT | `eyJhbGciOi...` | `→ "[JWT_TOKEN]"` |
| Session IDs | `sess_abc123...` | `→ "[SESSION_ID]"` |
| Hashes | `$2b$10$...` | `→ "[HASH]"` |
| Contadores dinâmicos | `count: 42` | Manter se determinístico, normalizar se não |

**Exemplo de serializer (JavaScript/Jest):**

```javascript
expect.addSnapshotSerializer({
  test: (val) => typeof val === "string" && /^\d{4}-\d{2}-\d{2}T/.test(val),
  print: () => '"[TIMESTAMP]"',
});

expect.addSnapshotSerializer({
  test: (val) => typeof val === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-/.test(val),
  print: () => '"[UUID]"',
});
```

{Adaptar para o test framework do projeto.}

## Regras

### Ao criar golden test

1. Definir serializers para TODOS os dados dinâmicos no `helpers`
2. Usar mocks consistentes (mesmos dados de entrada → mesmo snapshot)
3. Cobrir cenários de sucesso E erro (400, 401, 403, 404, 500)
4. Nomear testes com padrão: `"GET /api/resource — returns list of items"`

### Ao atualizar snapshots

1. **Sempre revisar o diff** — `--update` cego é o mesmo que deletar o teste
2. Se o diff é esperado (mudança intencional) → atualizar + commitar junto com a mudança
3. Se o diff é inesperado → investigar, é provavelmente uma regressão
4. Commitar snapshots junto com o código que os causa — nunca em commit separado

### Ao revisar PR com snapshots

1. Ler o diff do snapshot como se fosse código — mudanças não-intencionais são bugs
2. Verificar que novos endpoints/componentes têm golden test correspondente
3. Snapshot removido = funcionalidade removida? Confirmar se intencional

## Integração com CI

```bash
# CI deve rodar goldens sem --update
{test command} {golden tests path}

# Se falhar, desenvolvedor atualiza localmente:
{test command} {golden tests path} --update
# E revisa o diff antes de commitar
```

## Métricas

| Métrica | Target |
|---|---|
| Endpoints com golden test | 100% das rotas públicas |
| Componentes com golden test | Componentes de UI estáveis (não em flux) |
| Snapshots desatualizados | 0 (CI falha se houver) |
