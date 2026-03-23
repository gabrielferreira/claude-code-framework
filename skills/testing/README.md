# Skill: Testing — {NOME_DO_PROJETO}

> Use esta skill ao escrever, modificar ou revisar testes.

## Stack de testes

- **Framework:** {Jest / Vitest / Mocha / Pytest / etc.}
- **Runtime:** {Node.js 20 / Python 3.12 / etc.}
- **Mocks:** {jest.mock / sinon / unittest.mock / etc.}
- **HTTP:** {supertest / httpx / etc.}
- **E2E:** {Playwright / Cypress / Selenium / etc.}
- **Carga:** {k6 / Artillery / Locust / etc.}
- **Coverage:** {c8 / istanbul / coverage.py / etc.}

## Pirâmide de testes

```
        ╱╲
       ╱ E2E ╲          Poucos, lentos, caros — validam fluxo real do usuário
      ╱────────╲
     ╱ Integração╲      Moderados — validam interação entre módulos
    ╱──────────────╲
   ╱    Unitários    ╲  Muitos, rápidos, baratos — validam lógica isolada
  ╱════════════════════╲
```

A base é larga (unitários) e o topo é estreito (E2E). Cada camada cobre o que a anterior não consegue.

### Unitários — a fundação

**O que são:** testam uma função/módulo isolado, com dependências mockadas.

**Quando usar:**
- Regras de negócio puras (cálculos, validações, transformações)
- Funções utilitárias (sanitize, format, parse)
- Lógica condicional complexa (branches, edge cases)
- Segurança (sanitização, comparação timing-safe, permissões)

**Características:**
- Rápidos (ms por teste)
- Determinísticos (mesmo input = mesmo output, sempre)
- Sem I/O (banco, rede, filesystem são mockados)
- Quebram se a lógica interna mudar — e é isso que queremos

```javascript
// ✅ Bom teste unitário — testa lógica real
test("should reject expired token", () => {
  const token = createToken({ exp: Date.now() - 1000 });
  expect(() => validateToken(token)).toThrow("token_expired");
});

// ❌ Ruim — reimplementa a lógica no teste
test("should format name", () => {
  const expected = `${firstName} ${lastName}`;  // isso é testar o JS, não o código
  expect(formatName(firstName, lastName)).toBe(expected);
});
```

### Integração — a cola

**O que são:** testam a interação entre 2+ módulos reais (rota + service + DB, por exemplo).

**Quando usar:**
- Endpoints HTTP (supertest / httpx)
- Queries SQL contra banco real (ou mock-pool fiel)
- Fluxos com transaction (BEGIN/COMMIT/ROLLBACK)
- Webhooks (assinatura + processamento + side effects)
- Comunicação entre serviços

**Características:**
- Mais lentos que unitários (setup/teardown de estado)
- Testam o contrato entre módulos, não a lógica interna
- Podem usar banco em memória, mock-pool, ou testcontainers
- Capturam bugs que unitários não veem (ex: query SQL errada com mocks sempre retornando OK)

```javascript
// ✅ Bom teste de integração — testa rota + auth + DB juntos
test("GET /api/resource returns 401 without token", async () => {
  const res = await request(app).get("/api/resource");
  expect(res.status).toBe(401);
});

test("POST /api/resource creates and returns resource", async () => {
  const res = await request(app)
    .post("/api/resource")
    .set("Authorization", `Bearer ${validToken}`)
    .send({ name: "test" });
  expect(res.status).toBe(201);
  expect(res.body.name).toBe("test");
});
```

### E2E (End-to-End) — a prova final

**O que são:** testam o sistema completo do ponto de vista do usuário, com browser real.

**Quando usar:**
- Fluxos críticos de negócio (cadastro, compra, onboarding)
- Integrações com terceiros que são difíceis de mockar (pagamentos, OAuth)
- Regressão de fluxos que já quebraram em produção
- Validação de que frontend + backend + banco funcionam juntos

**Características:**
- Lentos (segundos por teste)
- Frágeis (dependem de UI, seletores, timing)
- Caros de manter — cada mudança de UI pode quebrar
- Cobrem o que nenhum outro tipo cobre: o fluxo real do usuário

```javascript
// ✅ Bom teste E2E — fluxo completo de login
test("user can login with valid credentials", async ({ page }) => {
  await page.goto("/login");
  await page.fill('[name="email"]', "user@example.com");
  await page.click('button[type="submit"]');
  // ... OTP flow ...
  await expect(page.locator('[data-testid="dashboard"]')).toBeVisible();
});
```

**Regra de ouro:** se um cenário pode ser coberto com teste unitário ou de integração, NÃO escreva E2E para ele. E2E é para o que só E2E consegue validar.

### Carga / Performance — o estresse

**O que são:** testam como o sistema se comporta sob volume alto de requisições simultâneas.

**Quando usar:**
- Antes de lançamento ou período de pico
- Endpoints com rate limit (validar que o limit funciona)
- Queries que podem ser lentas sob volume
- Integrações com serviços externos (verificar degradação graceful)

**Características:**
- Rodam contra ambiente dedicado (nunca produção)
- Medem latência (p50, p95, p99), throughput, e taxa de erro
- Identificam bottlenecks antes que os usuários encontrem
- Não são parte do CI — rodam sob demanda ou em schedule

```javascript
// Exemplo k6
export default function () {
  const res = http.get(`${BASE_URL}/api/health`);
  check(res, {
    "status 200": (r) => r.status === 200,
    "latency < 500ms": (r) => r.timings.duration < 500,
  });
}
```

### Golden tests — o snapshot inteligente

**O que são:** comparam output atual contra um "golden file" (snapshot aprovado). Se mudou, o teste falha e você decide se a mudança é intencional.

**Quando usar:**
- Respostas de API que têm formato estável
- Relatórios HTML/PDF gerados
- Outputs de CLI
- Queries SQL geradas por ORMs
- Qualquer output onde "mudou sem querer" é um bug

**Características:**
- Fáceis de criar (gera o golden na primeira execução)
- Detectam regressões sutis que testes manuais não pegariam
- Precisam de review quando falham — nem toda mudança é bug
- Golden files vivem no repo e são versionados

```javascript
// Exemplo de golden test
test("API response matches golden", () => {
  const response = generateReport(inputData);
  expect(response).toMatchSnapshot();  // ou compara com arquivo .golden
});
```

**Regra:** quando o golden falha, NÃO atualize automaticamente. Leia o diff, entenda a mudança, e só então aprove.

---

## Suites e contagem

{Listar suites com contagem de testes — manter atualizado.}

| Suite | Tipo | Testes | Cobertura alvo |
|---|---|---|---|
| {security.test.js} | Unitário | {117} | 100% |
| {business-rules.test.js} | Unitário | {75} | 100% |
| {auth.test.js} | Integração | {49} | 100% |
| {routes.test.js} | Integração | {29} | 80% |
| {utils.test.js} | Unitário | {15} | 80% |
| {e2e/*.spec.js} | E2E | {25} | — |
| **Total** | | **{310}** | |

## Política de cobertura

### Como pensar cobertura

Cobertura NÃO é um número para atingir — é uma ferramenta para encontrar código não testado. 100% de cobertura com testes ruins é pior que 80% com testes bons.

**Priorizar cobertura por risco, não por volume:**

| Risco do módulo | Cobertura alvo | Exemplos |
|---|---|---|
| **Crítico** — regra de negócio, segurança, dinheiro | 100% | auth, payments, permissions, business rules |
| **Alto** — fluxo principal do usuário | 90%+ | core features, API routes, data processing |
| **Médio** — suporte ao fluxo | 80%+ | middleware, validators, formatters |
| **Baixo** — infra, utilitários, admin | 70%+ | adapters, email templates, admin CRUD |

### O que cobrir em cada nível

**100% obrigatório (módulos críticos):**
- {Listar módulos: security, session, auth, payments, etc.}
- Todos os branches (if/else, switch, try/catch)
- Edge cases documentados na spec
- Error paths — não só happy path

**80% mínimo (módulos de suporte):**
- {Listar módulos: adapters, email, middleware utils, CRUD routes}
- Happy path + principais erros
- Branches de segurança (mesmo em módulos "simples")

### Cobertura que NÃO conta

- Testes que passam mas não validam nada (`expect(true).toBe(true)`)
- Cobertura por acidente (linha executada mas não verificada)
- Testes de template literal (`expect("Hello " + name).toBe("Hello John")`)
- Snapshot tests sem review (atualizados automaticamente)

---

## Padrões de mock

```javascript
// {ADAPTAR à stack}

// Mock de banco de dados
jest.mock("../../db", () => ({
  query: jest.fn(),
  connect: jest.fn(() => ({
    query: jest.fn(),
    release: jest.fn(),
  })),
}));

// Mock de serviço externo
jest.mock("../../services/external-service", () => ({
  call: jest.fn(),
}));

// Supertest para rotas
const request = require("supertest");
const app = require("../../app");
```

### Quando mockar vs quando usar real

| Dependência | Mock | Real | Decisão |
|---|---|---|---|
| Banco de dados | Mock-pool, jest.mock | SQLite in-memory, testcontainers | **Real** se testar queries SQL; **Mock** se testar lógica que usa o resultado |
| Serviço externo (API) | jest.mock, nock, MSW | Sandbox do serviço | **Mock** quase sempre; **Real** apenas em E2E ou smoke tests |
| Filesystem | memfs, jest.mock | tmpdir | **Mock** para unitários; **Real** para integração |
| Clock/Date | jest.useFakeTimers | — | **Mock** sempre que testar expiração, TTL, scheduling |
| Randomness | jest.spyOn(Math, 'random') | — | **Mock** quando determinismo importa |

**Regra:** mock o mínimo necessário. Mocks demais = testes que passam com código quebrado.

---

## Cenários obrigatórios por tipo

### Rota/Endpoint

- [ ] Happy path (200/201)
- [ ] Validação de input (400)
- [ ] Auth obrigatório (401)
- [ ] Permissão negada (403)
- [ ] Recurso não encontrado (404)
- [ ] Rate limit (429) — se aplicável
- [ ] Erro interno (500)

### Serviço com banco de dados

- [ ] Operação OK
- [ ] Registro não encontrado
- [ ] Constraint violation (duplicate, FK)
- [ ] Transaction rollback no erro
- [ ] Pool exhaustion / connection error

### Integração com serviço externo

- [ ] Resposta válida
- [ ] Timeout
- [ ] Resposta inválida / malformada
- [ ] Rate limit do serviço
- [ ] Erro de autenticação (401/403 do serviço)

### Webhook

- [ ] Happy path — evento processado
- [ ] Assinatura inválida (403)
- [ ] Evento duplicado (idempotência)
- [ ] Payload inválido
- [ ] Tipo de evento não suportado (ignorar gracefully)

### Regra de negócio

- [ ] Caso base
- [ ] Edge cases (limites, zeros, negativos)
- [ ] Combinações (ex: desconto + cupom + plano gratuito)
- [ ] Overflow / underflow
- [ ] Concorrência (se aplicável)

---

## Regras

1. **Testes chamam código de produção real.** NUNCA testar template literals, construções do JS, ou reimplementar a lógica no teste.
2. **Cada bugfix tem teste que reproduz o bug.** O teste deve falhar sem o fix e passar com ele.
3. **Mock o mínimo necessário.** Se pode testar com implementação real (em memória, SQLite, etc.), preferir.
4. **Branches de erro são obrigatórios.** Não só happy path — cobrir catch blocks, validações, edge cases.
5. **Nenhum `test.skip` ou `test.only` no commit.** Falhar no CI se detectado.
6. **Testes são documentação.** Nome descritivo: `should return 401 when token is expired`, não `test auth`.
7. **Fixture data é controlada.** Usar factories/fixtures, não dados aleatórios que causam flakes.
8. **Golden tests precisam de review.** Nunca atualizar snapshot sem ler o diff e entender a mudança.
9. **E2E cobre fluxos, não lógica.** Se pode testar com unitário/integração, não escreva E2E.
10. **Testes de carga rodam sob demanda.** Não são parte do CI — rodam antes de lançamentos ou quando há suspeita de bottleneck.

## Quando adicionar testes

| Situação | Tipo de teste | Ação |
|---|---|---|
| Nova feature | Unitário + Integração | Happy path + edge cases + erros |
| Bugfix | Unitário (ou Integração) | Teste que reproduz o bug (TDD reverso) |
| Novo endpoint | Integração | Todos os cenários de "Rota/Endpoint" |
| Novo webhook | Integração | Todos os cenários de "Webhook" |
| Fluxo crítico novo | E2E | Fluxo completo do usuário |
| Refator | — | Testes existentes devem continuar passando |
| Mudança de regra de negócio | Unitário | Atualizar + novo cenário |
| Antes de lançamento | Carga | Endpoints críticos sob volume |
| Output estável que não pode mudar | Golden | Snapshot do output esperado |

## Anti-patterns

| Anti-pattern | Por quê é ruim | O que fazer |
|---|---|---|
| Testar implementação, não comportamento | Quebra em refactors que não mudam resultado | Testar input/output, não internos |
| Mock de tudo | Teste sempre passa, código pode estar quebrado | Minimizar mocks, usar real quando possível |
| Testes interdependentes | Ordem importa, flakes aleatórios | Cada teste cria/limpa seu próprio estado |
| `expect(true).toBe(true)` | Cobertura sem validação | Todo `expect` deve validar algo do código |
| Dados aleatórios | Flakes, difícil reproduzir falha | Fixtures determinísticas |
| E2E para tudo | Suite lenta, frágil, cara de manter | E2E só para fluxos que exigem browser |
| Snapshot sem review | Aceita regressão sem perceber | Ler diff antes de atualizar golden |
