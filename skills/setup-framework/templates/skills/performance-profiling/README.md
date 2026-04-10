<!-- framework-tag: v2.33.0 framework-file: skills/performance-profiling/README.md -->
# Skill: Performance Profiling

> Use esta skill ao investigar lentidao, otimizar queries ou reduzir bundle size.
> Rode este checklist ANTES de considerar a otimizacao completa.
>
> **Foco:** backend (queries, pool, caching) e frontend (bundle, renders, memory).

## Quando usar

- Ao investigar endpoint lento (p95 > SLA)
- Ao otimizar queries ou acessos ao banco
- Ao reduzir bundle size ou tempo de carregamento
- Ao resolver memory leak reportado
- Ao revisar PR com mudanca de infra ou arquitetura

## Quando NAO usar

- Para validacao de contratos de API — usar skill api-testing
- Para auditoria de seguranca — usar skill security-review
- Para SEO e Core Web Vitals — usar skill seo-performance

## Checklist

### Queries N+1

- [ ] Loop que executa query dentro identificado e eliminado
- [ ] Eager loading aplicado (JOIN, include, prefetch_related)
- [ ] Batch queries para listas (`WHERE id IN (...)` ao inves de N selects)
- [ ] ORM configurado para alertar N+1 em dev (`bullet` gem, `nplusone`, etc.)

### Queries sem indice

- [ ] `EXPLAIN ANALYZE` executado em queries lentas
- [ ] Colunas em WHERE/JOIN/ORDER BY com indice adequado
- [ ] Indices compostos na ordem correta (seletividade decrescente)
- [ ] Full table scan eliminado em tabelas > 10k rows
- [ ] Indices nao utilizados removidos (overhead de escrita)

### Bundle size (frontend)

- [ ] Code splitting por rota (lazy loading de paginas)
- [ ] Tree shaking funcionando (imports especificos)
- [ ] Libs pesadas carregadas sob demanda (`import()` dinamico)
- [ ] Imagens otimizadas (WebP/AVIF, dimensoes corretas)
- [ ] Source maps nao enviados para producao

### Memory leaks

- [ ] Event listeners removidos no cleanup/unmount
- [ ] Timers (setTimeout/setInterval) limpos no unmount
- [ ] Closures nao retendo referencias desnecessarias
- [ ] Conexoes/streams fechadas apos uso
- [ ] WeakMap/WeakRef para caches que referenciam objetos grandes

### Rendering desnecessario (frontend)

- [ ] `React.memo` / `useMemo` / `useCallback` em componentes pesados
- [ ] Keys estaveis em listas (nao usar index como key)
- [ ] Context splitting — contextos granulares ao inves de um gigante
- [ ] Virtualizacao para listas longas (> 100 items)
- [ ] DevTools Profiler sem re-renders inesperados

### API response time

- [ ] p50 < {target}ms, p95 < {target}ms, p99 < {target}ms
- [ ] Endpoints lentos identificados e otimizados individualmente
- [ ] Payload minimo — retornar apenas campos necessarios
- [ ] Compressao habilitada (gzip/brotli)
- [ ] Paginacao para respostas com muitos registros

### Connection pooling

- [ ] Pool de DB configurado (min/max conexoes adequados ao workload)
- [ ] HTTP client reutilizando conexoes (keep-alive)
- [ ] Pool monitorado (conexoes ativas, fila de espera)
- [ ] Timeout de conexao configurado (nao esperar indefinidamente)

### Caching

- [ ] Dados que mudam raramente cacheados (config, enums, metadata)
- [ ] TTL adequado por tipo de dado (nao cache eterno sem invalidacao)
- [ ] Invalidacao explicita quando dado fonte muda
- [ ] Cache stampede prevenido (lock ou stale-while-revalidate)
- [ ] Hit rate monitorado (< 80% = revisar estrategia)

## Exemplos concretos

```sql
-- Detectar query lenta
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123 ORDER BY created_at DESC;
-- Se "Seq Scan" aparece em tabela grande → criar indice
CREATE INDEX idx_orders_user_created ON orders (user_id, created_at DESC);
```

```javascript
// Node.js — detectar N+1 e corrigir
// RUIM: N+1
const users = await db.query("SELECT * FROM users");
for (const user of users) {
  user.orders = await db.query("SELECT * FROM orders WHERE user_id = $1", [user.id]);
}

// BOM: JOIN ou batch
const users = await db.query(`
  SELECT u.*, json_agg(o.*) as orders
  FROM users u LEFT JOIN orders o ON o.user_id = u.id
  GROUP BY u.id
`);
```

```python
# Python/Django — prefetch para evitar N+1
# RUIM
for order in Order.objects.all():
    print(order.user.name)  # query por iteracao

# BOM
for order in Order.objects.select_related("user").all():
    print(order.user.name)  # uma unica query com JOIN
```

## Regras

1. **Medir antes de otimizar.** Sem metrica = sem otimizacao. Profile primeiro.
2. **EXPLAIN ANALYZE em toda query nova em tabela grande.** Seq scan > 10k rows = indice obrigatorio.
3. **Bundle size monitorado em CI.** Regressao > 10% = bloqueia merge.
4. **Pool configurado, nao default.** Default do driver raramente e adequado para producao.
5. **Cache com TTL e invalidacao.** Cache sem invalidacao = bug futuro garantido.
