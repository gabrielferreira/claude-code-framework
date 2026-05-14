<!-- framework-tag: v2.51.0 framework-file: skills/testing/README.md -->
# Skill: Testing — {NOME_DO_PROJETO}

> Use esta skill ao escrever, modificar ou revisar testes.

## Quando usar

- Ao escrever testes para nova feature, bugfix ou refatoração
- Ao modificar testes existentes para refletir novo comportamento
- Ao revisar cobertura de testes de um módulo

## Quando NÃO usar

- Para verificar sintaxe e padrões suspeitos — usar skill `code-quality`
- Para auditoria de segurança — usar agent `security-audit`
- Para análise de performance — não é o escopo desta skill

## Stack de testes

- **Framework:** {Jest / Vitest / Mocha / Pytest / xUnit / NUnit / dart:test / cargo test / etc.}
- **Runtime:** {Node.js 20 / Python 3.12 / .NET 8 / Dart 3 / Rust 1.78 / etc.}
- **Mocks:** {jest.mock / sinon / unittest.mock / Moq / NSubstitute / Mockito (Dart) / mockall / etc.}
- **HTTP:** {supertest / httpx / WebApplicationFactory / http (Dart) / reqwest + wiremock / etc.}
- **E2E:** {Playwright / Cypress / Selenium / flutter_test / etc.}
- **Carga:** {k6 / Artillery / Locust / etc.}
- **Coverage:** {c8 / istanbul / coverage.py / coverlet / dart test --coverage / cargo llvm-cov / etc.}

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

**JavaScript (Jest):**
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

**Go:**
```go
// ✅ Bom teste unitário — testa lógica real
func TestValidateToken_Expired(t *testing.T) {
    token := createToken(time.Now().Add(-1 * time.Hour))
    err := ValidateToken(token)
    assert.ErrorIs(t, err, ErrTokenExpired)
}

// ❌ Ruim — reimplementa a lógica no teste
func TestFormatName(t *testing.T) {
    expected := firstName + " " + lastName  // isso é testar o Go, não o código
    assert.Equal(t, expected, FormatName(firstName, lastName))
}
```

**C# (xUnit):**
```csharp
// ✅ Bom teste unitário — testa lógica real
[Fact]
public void ValidateToken_Expired_ThrowsTokenExpiredException()
{
    var token = CreateToken(DateTime.UtcNow.AddHours(-1));
    Assert.Throws<TokenExpiredException>(() => _sut.ValidateToken(token));
}

// ❌ Ruim — reimplementa a lógica no teste
[Fact]
public void FormatName_ShouldConcatenate()
{
    var expected = $"{firstName} {lastName}";  // isso é testar o C#, não o código
    Assert.Equal(expected, FormatName(firstName, lastName));
}
```

**Rust (cargo test):**
```rust
// ✅ Bom teste unitário — testa lógica real
#[test]
fn validate_token_expired_returns_error() {
    let token = create_token(Utc::now() - Duration::hours(1));
    let result = validate_token(&token);
    assert!(matches!(result, Err(AuthError::TokenExpired)));
}

// ❌ Ruim — reimplementa a lógica no teste
#[test]
fn format_name_concatenates() {
    let expected = format!("{} {}", first_name, last_name);  // isso é testar o Rust, não o código
    assert_eq!(expected, format_name(first_name, last_name));
}
```

**Dart (test package):**
```dart
// ✅ Bom teste unitário — testa lógica real
test('should reject expired token', () {
  final token = createToken(expiry: DateTime.now().subtract(const Duration(hours: 1)));
  expect(() => validateToken(token), throwsA(isA<TokenExpiredException>()));
});

// ❌ Ruim — reimplementa a lógica no teste
test('should format name', () {
  final expected = '$firstName $lastName';  // isso é testar o Dart, não o código
  expect(formatName(firstName, lastName), equals(expected));
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

**JavaScript (supertest):**
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

**Go (net/http/httptest):**
```go
func TestGetResource_Unauthorized(t *testing.T) {
    router := setupRouter()
    req := httptest.NewRequest(http.MethodGet, "/api/resource", nil)
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)

    assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestPostResource_Created(t *testing.T) {
    router := setupRouter()
    body := `{"name":"test"}`
    req := httptest.NewRequest(http.MethodPost, "/api/resource", strings.NewReader(body))
    req.Header.Set("Authorization", "Bearer "+validToken)
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)

    assert.Equal(t, http.StatusCreated, w.Code)
    var resp map[string]string
    json.Unmarshal(w.Body.Bytes(), &resp)
    assert.Equal(t, "test", resp["name"])
}
```

**C# (xUnit + WebApplicationFactory):**
```csharp
// ✅ Bom teste de integração — testa rota + auth + DB juntos
public class ResourceEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    public ResourceEndpointTests(WebApplicationFactory<Program> factory)
        => _client = factory.CreateClient();

    [Fact]
    public async Task GetResource_WithoutToken_Returns401()
    {
        var response = await _client.GetAsync("/api/resource");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task PostResource_WithValidToken_Returns201()
    {
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", GenerateTestToken());
        var response = await _client.PostAsJsonAsync("/api/resource", new { name = "test" });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("test", body.GetProperty("name").GetString());
    }
}
```

**Rust (axum + tokio::test):**
```rust
// ✅ Bom teste de integração — testa handler + middleware + DB
#[tokio::test]
async fn get_resource_without_token_returns_401() {
    let app = create_test_app().await;
    let response = app
        .oneshot(Request::get("/api/resource").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_resource_with_valid_token_returns_201() {
    let app = create_test_app().await;
    let response = app
        .oneshot(
            Request::post("/api/resource")
                .header("Authorization", format!("Bearer {}", generate_test_token()))
                .header("Content-Type", "application/json")
                .body(Body::from(r#"{"name":"test"}"#))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::CREATED);
}
```

**Dart (test + http + mockito):**
```dart
// ✅ Bom teste de integração — testa handler + auth
group('GET /api/resource', () {
  test('returns 401 without token', () async {
    final client = MockHttpClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Unauthorized', 401));
    final response = await client.get(Uri.parse('/api/resource'));
    expect(response.statusCode, equals(401));
  });

  test('returns 201 with valid token', () async {
    final client = MockHttpClient();
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"name":"test"}', 201));
    final response = await client.post(
      Uri.parse('/api/resource'),
      headers: {'Authorization': 'Bearer $validToken'},
      body: jsonEncode({'name': 'test'}),
    );
    expect(response.statusCode, equals(201));
    expect(jsonDecode(response.body)['name'], equals('test'));
  });
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
  // ... auth flow ...
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

{Adaptar: suites com contagem de testes — manter atualizado.}

| Suite | Tipo | Testes | Cobertura alvo |
|---|---|---|---|
| {security.test.js} | Unitário | {117} | 100% |
| {domain-rules.test.js} | Unitário | {75} | 100% |
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
- {Adaptar: modulos criticos — security, session, auth, payments, etc.}
- Todos os branches (if/else, switch, try/catch)
- Edge cases documentados na spec
- Error paths — não só happy path

**80% mínimo (módulos de suporte):**
- {Adaptar: modulos de suporte — adapters, email, middleware utils, CRUD routes}
- Happy path + principais erros
- Branches de segurança (mesmo em módulos "simples")

### Cobertura que NÃO conta

- Testes que passam mas não validam nada (`expect(true).toBe(true)`)
- Cobertura por acidente (linha executada mas não verificada)
- Testes de template literal (`expect("Hello " + name).toBe("Hello John")`)
- Snapshot tests sem review (atualizados automaticamente)

### Cobertura que o Istanbul NÃO mede (mas existe)

Istanbul/c8 só instrumenta arquivos carregados via `require`/`import` dentro do processo de teste. **Routes testadas via supertest (HTTP) aparecem 0% no Istanbul**, mesmo sendo exercitadas pelos testes de integração e golden tests.

**Solução recomendada:**
1. Excluir `routes/` do `collectCoverageFrom` — Istanbul não consegue medir, então o 0% é noise
2. Medir cobertura de routes via golden tests (snapshots de endpoints) — report separado
3. No report consolidado, mostrar as duas métricas lado a lado:
   - "Services & Middleware" → Istanbul (import direto, medição precisa)
   - "Routes & Endpoints" → Golden tests (supertest, medição por endpoint)

**Não incluir routes no Istanbul e interpretar 0% como "não testado"** — isso gera falsa urgência sobre código que está coberto por outro tipo de teste.

---

## Padrões de mock

### Regras fundamentais de mock

1. **Mocks ANTES dos imports (JS).** No Jest, `jest.mock()` é hoisted, mas a declaração deve aparecer antes dos `require`/`import` do módulo testado. Em Go, use interfaces — a injeção acontece na construção do struct.
2. **Cleanup entre testes.** JS: `beforeEach(() => jest.clearAllMocks())`. Go: cada teste cria suas próprias instâncias (table-driven tests). Sem isso, estado de um teste vaza para o próximo.
3. **Mock o mínimo necessário.** Mocks demais = testes que passam com código quebrado. Se pode testar com implementação real (in-memory, testcontainers), preferir.
4. **Mock fiel ao contrato.** O mock deve respeitar o mesmo formato de retorno da implementação real. Mock que retorna `{ data: "ok" }` quando o real retorna `{ rows: [...] }` gera falsa confiança. Em Go, o mock implementa a mesma interface que a dependência real.

### Abordagem de mock por linguagem

**JavaScript:** `jest.mock()` substitui módulos inteiros. Flexível mas frágil — se o módulo real muda a API, o mock não quebra (falsa confiança).

**Go:** interfaces + injeção de dependência. O mock implementa a mesma interface, então se a interface muda, o mock não compila. Mais seguro por design.

**C# (Moq / NSubstitute):** `Mock<IInterface>()` gera implementação em runtime a partir da interface. Se a interface muda, o mock pode não quebrar em compilação (diferente do Go), mas ao chamar `.Setup()` numa assinatura inexistente o compilador alerta. Mais seguro usar `NSubstitute` com verificação em compile-time.

**Rust (mockall):** `#[automock]` gera implementação de mock para traits. Se o trait muda, o mock gerado é regenerado na compilação — não compila se o código de teste chamar método inexistente. Análogo ao Go em segurança.

**Dart (Mockito):** `@GenerateMocks([Classe])` com build_runner gera mocks em compile time. Similar ao Go: se a interface muda, o código gerado muda e o compilador pega inconsistências.

```go
// Interface que a dependência real e o mock implementam
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
}

// Mock
type mockUserRepo struct {
    findByIDFn func(ctx context.Context, id string) (*User, error)
    createFn   func(ctx context.Context, user *User) error
}

func (m *mockUserRepo) FindByID(ctx context.Context, id string) (*User, error) {
    return m.findByIDFn(ctx, id)
}
func (m *mockUserRepo) Create(ctx context.Context, user *User) error {
    return m.createFn(ctx, user)
}

// Uso no teste
func TestGetUser(t *testing.T) {
    repo := &mockUserRepo{
        findByIDFn: func(ctx context.Context, id string) (*User, error) {
            return &User{ID: id, Name: "Test"}, nil
        },
    }
    svc := NewUserService(repo)  // injeção de dependência

    user, err := svc.GetUser(context.Background(), "uuid-1")
    assert.NoError(t, err)
    assert.Equal(t, "Test", user.Name)
}
```

**C# (Moq):**
```csharp
// Interface que a dependência real e o mock implementam
public interface IUserRepository
{
    Task<User?> FindByIdAsync(string id);
    Task CreateAsync(User user);
}

// Uso no teste (Moq gera implementação em runtime)
[Fact]
public async Task GetUser_ReturnsUser_WhenFound()
{
    var repoMock = new Mock<IUserRepository>();
    repoMock.Setup(r => r.FindByIdAsync("uuid-1"))
            .ReturnsAsync(new User { Id = "uuid-1", Name = "Test" });

    var svc = new UserService(repoMock.Object);  // injeção de dependência
    var user = await svc.GetUserAsync("uuid-1");

    Assert.Equal("Test", user.Name);
    repoMock.Verify(r => r.FindByIdAsync("uuid-1"), Times.Once);
}
```

**Rust (mockall):**
```rust
// Trait que a dependência real e o mock implementam
#[cfg_attr(test, automock)]
trait UserRepository {
    fn find_by_id(&self, id: &str) -> Result<User, Error>;
    fn create(&self, user: &User) -> Result<(), Error>;
}

// Uso no teste
#[test]
fn get_user_returns_user_when_found() {
    let mut repo = MockUserRepository::new();
    repo.expect_find_by_id()
        .with(eq("uuid-1"))
        .times(1)
        .returning(|_| Ok(User { id: "uuid-1".into(), name: "Test".into() }));

    let svc = UserService::new(Box::new(repo));  // injeção de dependência
    let user = svc.get_user("uuid-1").unwrap();

    assert_eq!("Test", user.name);
}
```

**Dart (Mockito):**
```dart
// Classe real que o mock replica
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<void> create(User user);
}

// Gerar mock: dart run build_runner build
@GenerateMocks([UserRepository])
void main() {
  test('getUser returns user when found', () async {
    final repo = MockUserRepository();
    when(repo.findById('uuid-1'))
        .thenAnswer((_) async => User(id: 'uuid-1', name: 'Test'));

    final svc = UserService(repo);  // injeção de dependência
    final user = await svc.getUser('uuid-1');

    expect(user?.name, equals('Test'));
    verify(repo.findById('uuid-1')).called(1);
  });
}
```

### Mock básico de banco de dados

```javascript
// {ADAPTAR à stack}

// Mocks ANTES dos imports
jest.mock("../../db", () => ({
  query: jest.fn(),
  connect: jest.fn(),
  on: jest.fn(),
}));

const db = require("../../db");
const { myFunction } = require("../../services/my-service");

beforeEach(() => {
  jest.clearAllMocks();
  db.query.mockReset();
});

test("should return user by ID", async () => {
  db.query.mockResolvedValueOnce({ rows: [{ id: "uuid-1", name: "Test" }] });
  const result = await myFunction("uuid-1");
  expect(result.name).toBe("Test");
  expect(db.query).toHaveBeenCalledWith(
    expect.stringContaining("WHERE id = $1"),
    ["uuid-1"]
  );
});
```

### Mock de transactions (connect → client)

Operações que usam `BEGIN/COMMIT/ROLLBACK` precisam de mock mais elaborado — simular o client com `query`, `release`, e tracking de chamadas:

```javascript
// {ADAPTAR à stack}
function createMockClient(queryResponses = []) {
  let callIndex = 0;
  const queries = [];
  const client = {
    query: jest.fn(async (sql, params) => {
      queries.push({ sql, params });
      return queryResponses[callIndex++] || { rows: [] };
    }),
    release: jest.fn(),
  };
  return { client, queries };
}

// Uso no teste
test("should rollback on error", async () => {
  const { client, queries } = createMockClient([
    { rows: [] },  // BEGIN
    { rows: [{ id: "1" }] },  // SELECT
    // INSERT vai falhar — simulamos no teste
  ]);
  client.query.mockRejectedValueOnce(new Error("constraint_violation"));
  db.connect.mockResolvedValueOnce(client);

  await expect(myTransactionalFunction()).rejects.toThrow();

  // Verificar que ROLLBACK foi chamado
  expect(queries.some(q => q.sql === "ROLLBACK")).toBe(true);
  expect(client.release).toHaveBeenCalled();
});
```

**Go (sqlx/pgx):**
```go
// Interface de transaction
type TxBeginner interface {
    BeginTx(ctx context.Context, opts *sql.TxOptions) (*sql.Tx, error)
}

type mockTxBeginner struct {
    tx     *mockTx
    begErr error
}

type mockTx struct {
    queries  []string
    commitFn func() error
    rollback bool
}

func (m *mockTx) ExecContext(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
    m.queries = append(m.queries, query)
    return nil, nil
}
func (m *mockTx) Commit() error   { return m.commitFn() }
func (m *mockTx) Rollback() error { m.rollback = true; return nil }

func TestTransferFunds_RollbackOnError(t *testing.T) {
    tx := &mockTx{
        commitFn: func() error { return errors.New("constraint_violation") },
    }
    db := &mockTxBeginner{tx: tx}
    svc := NewPaymentService(db)

    err := svc.TransferFunds(context.Background(), "from", "to", 100)

    assert.Error(t, err)
    assert.True(t, tx.rollback, "expected ROLLBACK on error")
}
```

### Mock de JWT para testes de rota

Testes de endpoint precisam simular autenticação. Gerar token real com a lib de JWT, usando o mesmo secret do ambiente de teste:

```javascript
// {ADAPTAR à stack}
const jwt = require("jsonwebtoken");
const request = require("supertest");
const app = require("../../app");

function generateTestToken(payload = {}) {
  return jwt.sign(
    { id: "test-uuid", email: "test@test.com", ...payload },
    process.env.JWT_SECRET || "test-secret",
    { expiresIn: "1h", issuer: "{your-issuer}" }
  );
}

test("should return 200 with valid token", async () => {
  const token = generateTestToken();
  db.query.mockResolvedValueOnce({ rows: [{ id: "test-uuid" }] });

  const res = await request(app)
    .get("/api/protected-resource")
    .set("Authorization", `Bearer ${token}`)
    .expect(200);
});

test("should return 401 without token", async () => {
  await request(app)
    .get("/api/protected-resource")
    .expect(401);
});

test("should return 403 with wrong role", async () => {
  const token = generateTestToken({ role: "viewer" });  // precisa de "admin"
  await request(app)
    .get("/api/admin/users")
    .set("Authorization", `Bearer ${token}`)
    .expect(403);
});
```

**Go (golang-jwt):**
```go
func generateTestToken(t *testing.T, claims jwt.MapClaims) string {
    t.Helper()
    defaults := jwt.MapClaims{
        "sub":   "test-uuid",
        "email": "test@test.com",
        "exp":   time.Now().Add(1 * time.Hour).Unix(),
        "iss":   "{your-issuer}",
    }
    for k, v := range claims {
        defaults[k] = v
    }
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, defaults)
    signed, err := token.SignedString([]byte("test-secret"))
    require.NoError(t, err)
    return signed
}

func TestProtectedRoute_200(t *testing.T) {
    router := setupRouter()
    token := generateTestToken(t, nil)

    req := httptest.NewRequest(http.MethodGet, "/api/protected-resource", nil)
    req.Header.Set("Authorization", "Bearer "+token)
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)
    assert.Equal(t, http.StatusOK, w.Code)
}

func TestProtectedRoute_401(t *testing.T) {
    router := setupRouter()
    req := httptest.NewRequest(http.MethodGet, "/api/protected-resource", nil)
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)
    assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestAdminRoute_403_WrongRole(t *testing.T) {
    router := setupRouter()
    token := generateTestToken(t, jwt.MapClaims{"role": "viewer"})

    req := httptest.NewRequest(http.MethodGet, "/api/admin/users", nil)
    req.Header.Set("Authorization", "Bearer "+token)
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)
    assert.Equal(t, http.StatusForbidden, w.Code)
}
```

### Mock de serviços compostos (webhook = externo + DB + email)

Webhooks e fluxos complexos precisam mockar múltiplas dependências de uma vez. Organizar por "cenário", não por "dependência":

```javascript
// {ADAPTAR à stack}
jest.mock("../../db", () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock("../../services/email-service", () => ({ send: jest.fn() }));
jest.mock("../../services/external-service", () => ({ verify: jest.fn() }));

const db = require("../../db");
const email = require("../../services/email-service");
const external = require("../../services/external-service");

function setupHappyPath() {
  external.verify.mockResolvedValueOnce({ valid: true, eventId: "evt_123" });
  db.query
    .mockResolvedValueOnce({ rows: [] })           // check duplicata
    .mockResolvedValueOnce({ rows: [{ id: "1" }] }) // INSERT
    ;
  email.send.mockResolvedValueOnce({ success: true });
}

test("webhook happy path — processes event", async () => {
  setupHappyPath();
  const res = await request(app)
    .post("/api/webhook")
    .set("x-signature", "valid-sig")
    .send({ type: "payment.completed", data: { id: "pay_1" } })
    .expect(200);
});

test("webhook duplicate — returns 200 without processing", async () => {
  external.verify.mockResolvedValueOnce({ valid: true });
  db.query.mockResolvedValueOnce({ rows: [{ id: "existing" }] });  // já existe

  const res = await request(app)
    .post("/api/webhook")
    .set("x-signature", "valid-sig")
    .send({ type: "payment.completed", data: { id: "pay_1" } })
    .expect(200);

  expect(email.send).not.toHaveBeenCalled();  // não reprocessou
});
```

**Go (interfaces + injeção):**
```go
// Interfaces para cada dependência
type SignatureVerifier interface {
    Verify(payload []byte, signature string) (*WebhookEvent, error)
}
type EventStore interface {
    Exists(ctx context.Context, eventID string) (bool, error)
    Save(ctx context.Context, event *WebhookEvent) error
}
type Notifier interface {
    Send(ctx context.Context, to string, msg string) error
}

// Setup para testes — injetar mocks
func setupWebhookHandler(verifier SignatureVerifier, store EventStore, notifier Notifier) http.Handler {
    svc := NewWebhookService(verifier, store, notifier)
    return NewWebhookHandler(svc)
}

func TestWebhook_HappyPath(t *testing.T) {
    verifier := &mockVerifier{event: &WebhookEvent{ID: "evt_1", Type: "payment.completed"}}
    store := &mockEventStore{exists: false}
    notifier := &mockNotifier{}

    handler := setupWebhookHandler(verifier, store, notifier)
    body := `{"type":"payment.completed","data":{"id":"pay_1"}}`
    req := httptest.NewRequest(http.MethodPost, "/api/webhook", strings.NewReader(body))
    req.Header.Set("X-Signature", "valid-sig")
    w := httptest.NewRecorder()

    handler.ServeHTTP(w, req)

    assert.Equal(t, http.StatusOK, w.Code)
    assert.True(t, notifier.sent, "expected notification to be sent")
}

func TestWebhook_Duplicate(t *testing.T) {
    verifier := &mockVerifier{event: &WebhookEvent{ID: "evt_1"}}
    store := &mockEventStore{exists: true}  // já existe
    notifier := &mockNotifier{}

    handler := setupWebhookHandler(verifier, store, notifier)
    // ... mesmo setup de request ...

    assert.Equal(t, http.StatusOK, w.Code)
    assert.False(t, notifier.sent, "should NOT re-notify on duplicate")
}
```

### Quando mockar vs quando usar real

| Dependência | Mock (JS) | Mock (Go) | Real | Decisão |
|---|---|---|---|---|
| Banco de dados | jest.mock, mock-pool | interface + struct | SQLite in-memory, testcontainers | **Real** se testar queries SQL; **Mock** se testar lógica que usa o resultado |
| Serviço externo (API) | jest.mock, nock, MSW | interface + struct | Sandbox do serviço | **Mock** quase sempre; **Real** apenas em E2E ou smoke tests |
| JWT / Auth | Token com lib real | Token com lib real | Auth real | **Real** (gerar token) — nunca skip auth no teste |
| Filesystem | memfs, jest.mock | afero, interface | tmpdir | **Mock** para unitários; **Real** para integração |
| Clock/Date | jest.useFakeTimers | clock interface | — | **Mock** sempre que testar expiração, TTL, scheduling |
| Randomness | jest.spyOn(Math, 'random') | rand source injection | — | **Mock** quando determinismo importa |
| E-mail | jest.mock | interface + struct | Mailhog, Ethereal | **Mock** quase sempre; **Real** em E2E com mail catcher |
| HTTP client | jest.mock, nock | interface + httptest | — | **Mock** quase sempre; injetar `http.Client` ou interface |

### Erros comuns de mock

| Erro | Linguagem | Consequência | Correção |
|---|---|---|---|
| Mock depois do import | JS | Módulo carrega implementação real | `jest.mock()` antes de `require()` |
| Sem `clearAllMocks` no beforeEach | JS | Estado vaza entre testes, flakes | `beforeEach(() => jest.clearAllMocks())` |
| Mock retorna formato errado | JS/Go | Teste passa, produção quebra | Verificar formato de retorno real |
| Mock de auth com skip em vez de token | JS/Go | Não testa middleware de auth | Gerar token real com test secret |
| Mock permanente (sem mockReset) | JS | Teste N vê mock de teste 1 | `mockReset()` ou `clearAllMocks()` |
| Mock de tudo num teste de integração | JS/Go | Não testa nada real | Mockar só I/O externo, deixar lógica real |
| Struct mock sem implementar interface | Go | Compila mas não garante contrato | `var _ Interface = (*MockStruct)(nil)` para check em compile-time |
| Mock com estado compartilhado entre testes | Go | Flakes em `t.Parallel()` | Criar instância nova de mock em cada teste |
| Usar `httptest.Server` quando `httptest.NewRequest` basta | Go | Teste mais lento sem necessidade | Server só quando precisa testar client HTTP real |

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

### CLI / Tool

- [ ] Help text (`--help`) renderiza corretamente
- [ ] Exit code 0 em sucesso, 1 em erro, 2 em uso incorreto
- [ ] stdout contém output esperado, stderr contém erros
- [ ] Flags obrigatórias ausentes → mensagem clara + exit code 2
- [ ] Stdin pipe funciona (se aplicável)
- [ ] Output sem cores quando piped (`NO_COLOR` ou detecção de TTY)

### Mobile

- [ ] Render sem crash nos tamanhos de tela comuns
- [ ] Permissões negadas → fallback graceful
- [ ] Offline → comportamento esperado (cache, fila, mensagem)
- [ ] Deep link resolve para a tela correta
- [ ] Push notification → ação correta ao abrir

### Infra / IaC

- [ ] `plan` sem erros em estado limpo
- [ ] Mudança esperada aparece no diff do plan
- [ ] Mudança destrutiva marcada como tal no plan
- [ ] Módulo reutilizável aceita variáveis obrigatórias
- [ ] State lock funciona (se remoto)

### Library / Package

- [ ] API pública retorna tipos esperados
- [ ] Breaking change: versão anterior falha, nova passa
- [ ] Tree-shaking: import parcial não traz o bundle inteiro
- [ ] Tipos/typings corretos (se TypeScript/typed)

---

## Regras

1. **Testes chamam código de produção real.** NUNCA testar template literals, construções do JS, ou reimplementar a lógica no teste.
2. **Cada bugfix tem teste que reproduz o bug.** O teste deve falhar sem o fix e passar com ele.
3. **Mock o mínimo necessário.** Se pode testar com implementação real (em memória, SQLite, etc.), preferir.
4. **Branches de erro são obrigatórios.** Não só happy path — cobrir catch blocks, validações, edge cases.
5. **Nenhum teste ignorado/exclusivo no commit.** Falhar no CI se detectado. Equivalentes por linguagem: JS/TS → `test.only` / `test.skip`; C# → `[Fact(Skip=...)]` sem justificativa rastreada; Rust → `#[ignore]` sem comentário; Dart → `skip:` sem motivo.
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
| Novo comando CLI | Unitário + Integração | Todos os cenários de "CLI / Tool" |
| Novo módulo IaC | Integração (Terratest/plan) | Todos os cenários de "Infra / IaC" |
| Nova API de library | Unitário | Todos os cenários de "Library / Package" |
| Fluxo crítico novo | E2E | Fluxo completo do usuário (web/mobile) |
| Refator | — | Testes existentes devem continuar passando |
| Mudança de regra de negócio | Unitário | Atualizar + novo cenário |
| Antes de lançamento | Carga | Endpoints/comandos críticos sob volume |
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

## Regenerar reports ao modificar testes

Quando testes são adicionados, removidos ou modificados, regenerar os relatórios HTML (se `scripts/reports.sh` existir):

```bash
bash scripts/reports.sh
```

O script auto-detecta quais reports existem e só roda os encontrados (coverage, golden tests, backlog, index).

Para pular re-execução de testes (só regenerar golden reports a partir de snapshots existentes):
```bash
bash scripts/reports.sh --skip-tests
```

## Checklist

- [ ] Testes novos cobrem cenários de sucesso E erro
- [ ] Cada bugfix tem teste que reproduz o bug (TDD reverso)
- [ ] Nenhum `test.only` ou `test.skip` commitado
- [ ] Mocks limitados ao mínimo necessário
- [ ] Fixtures determinísticas (sem dados aleatórios)
- [ ] Golden tests atualizados com review do diff
