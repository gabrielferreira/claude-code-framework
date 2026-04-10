<!-- framework-tag: v2.37.0 framework-file: skills/api-testing/README.md -->
# Skill: API Testing

> Use esta skill ao criar, modificar ou revisar endpoints de API.
> Rode este checklist ANTES de considerar a feature completa.
>
> **Foco:** validacao de contratos, testes de integracao HTTP, contract testing.

## Quando usar

- Ao criar ou modificar endpoints REST/GraphQL
- Ao integrar com API externa (consumer side)
- Ao publicar API para terceiros (provider side)
- Ao alterar formato de request/response
- Ao adicionar paginacao, filtros ou versionamento

## Quando NAO usar

- Para testes unitarios de logica interna (sem HTTP) — usar skill testing
- Para validacao de seguranca — usar skill security-review
- Para performance de endpoints — usar agent `performance-audit`

## Checklist

### Status codes

- [ ] `200 OK` — GET, PUT, PATCH retornam dados atualizados
- [ ] `201 Created` — POST retorna recurso criado com `Location` header
- [ ] `204 No Content` — DELETE sem body na resposta
- [ ] `400 Bad Request` — input invalido (tipo errado, campo faltando)
- [ ] `401 Unauthorized` — sem token ou token invalido
- [ ] `403 Forbidden` — token valido mas sem permissao
- [ ] `404 Not Found` — recurso inexistente (nao revelar existencia)
- [ ] `409 Conflict` — duplicata ou estado inconsistente
- [ ] `422 Unprocessable Entity` — validacao de regra de negocio
- [ ] `500 Internal Server Error` — nunca expor stack trace em producao

### Response schemas

- [ ] Campos obrigatorios documentados e testados
- [ ] Tipos corretos (string, number, boolean, array, object)
- [ ] Campos nullable explicitamente marcados
- [ ] Campos sensíveis NUNCA presentes (password_hash, tokens internos)
- [ ] Envelopes consistentes (`{ data, meta, errors }` ou similar)

### Headers

- [ ] `Content-Type` correto em toda resposta (application/json, etc.)
- [ ] CORS headers configurados (origins, methods, credentials)
- [ ] Rate limit headers presentes (`X-RateLimit-Limit`, `X-RateLimit-Remaining`)
- [ ] Cache headers adequados (`Cache-Control`, `ETag` quando aplicavel)

### Paginacao

- [ ] Cursor-based ou offset-based — escolher um e manter consistente
- [ ] Limite maximo de page size (prevenir `?limit=999999`)
- [ ] Ordenacao default documentada e testada
- [ ] Response inclui total count ou has_next (nao ambos se desnecessario)
- [ ] Primeiro e ultimo page testados como edge cases

### Idempotencia

- [ ] POST com `Idempotency-Key` header para operacoes criticas
- [ ] PUT/PATCH naturalmente idempotentes (mesmo input = mesmo resultado)
- [ ] Retry seguro — mesma request nao duplica side effects

### Error responses

- [ ] Formato padrao em todos os endpoints (`{ code, message, details }`)
- [ ] Mensagens uteis para o consumidor (nao "something went wrong")
- [ ] Sem leak de informacao interna (paths, queries, stack traces)
- [ ] Validation errors listam todos os campos com problema (nao so o primeiro)

### Contract testing

- [ ] Provider: schema publicado e versionado (OpenAPI, JSON Schema)
- [ ] Consumer: testes contra schema, nao contra implementacao
- [ ] Breaking changes detectados antes do deploy (CI check)
- [ ] Versionamento de API definido (URL path, header, query param)

### Timeouts e retries

- [ ] Client HTTP com timeout configurado (connect + read)
- [ ] Retry com backoff exponencial para erros transientes (5xx, timeout)
- [ ] Circuit breaker para dependencias instáveis
- [ ] Timeout documentado por endpoint (SLA)

## Exemplos concretos

```javascript
// Node.js — supertest
describe("POST /api/users", () => {
  it("retorna 201 com usuario criado", async () => {
    const res = await request(app)
      .post("/api/users")
      .send({ name: "Test", email: "test@example.com" })
      .expect(201);
    expect(res.body.data).toHaveProperty("id");
    expect(res.headers["content-type"]).toMatch(/json/);
  });

  it("retorna 422 para email duplicado", async () => {
    await request(app)
      .post("/api/users")
      .send({ name: "Test", email: "existing@example.com" })
      .expect(422);
  });
});
```

```python
# Python — pytest + httpx
async def test_create_user(client):
    resp = await client.post("/api/users", json={"name": "Test", "email": "t@ex.com"})
    assert resp.status_code == 201
    assert "id" in resp.json()["data"]

async def test_pagination_limit(client):
    resp = await client.get("/api/users?limit=10000")
    assert resp.status_code == 200
    assert len(resp.json()["data"]) <= 100  # max enforced server-side
```

```csharp
// C# — xUnit + WebApplicationFactory
public class UserEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    public UserEndpointTests(WebApplicationFactory<Program> factory)
        => _client = factory.CreateClient();

    [Fact]
    public async Task CreateUser_Returns201_WithCreatedUser()
    {
        var payload = new { name = "Test", email = "test@example.com" };
        var response = await _client.PostAsJsonAsync("/api/users", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(body.GetProperty("data").TryGetProperty("id", out _));
    }

    [Fact]
    public async Task CreateUser_Returns422_ForDuplicateEmail()
    {
        var payload = new { name = "Test", email = "existing@example.com" };
        var response = await _client.PostAsJsonAsync("/api/users", payload);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }
}
```

```rust
// Rust — axum + tower::ServiceExt (oneshot)
#[tokio::test]
async fn create_user_returns_201() {
    let app = create_test_router().await;
    let request = Request::post("/api/users")
        .header("Content-Type", "application/json")
        .body(Body::from(r#"{"name":"Test","email":"t@ex.com"}"#))
        .unwrap();
    let response = app.oneshot(request).await.unwrap();
    assert_eq!(response.status(), StatusCode::CREATED);
    let body: Value = serde_json::from_slice(
        &to_bytes(response.into_body(), usize::MAX).await.unwrap()
    ).unwrap();
    assert!(body["data"]["id"].is_string());
}
```

```dart
// Dart — test + http
test('POST /api/users retorna 201 com usuario criado', () async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': 'Test', 'email': 't@ex.com'}),
  );
  expect(response.statusCode, equals(201));
  final body = jsonDecode(response.body);
  expect(body['data']['id'], isNotNull);
});

test('GET /api/users respeita limite de paginacao', () async {
  final response = await http.get(Uri.parse('$baseUrl/api/users?limit=10000'));
  expect(response.statusCode, equals(200));
  final data = jsonDecode(response.body)['data'] as List;
  expect(data.length, lessThanOrEqualTo(100));  // max enforced server-side
});
```

## Regras

1. **Todo endpoint tem teste de contrato.** Sem teste = sem deploy.
2. **Error format padronizado.** Um unico formato em toda API — sem excecoes.
3. **Quebrando contrato = major version bump.** Remover campo, mudar tipo ou status code = breaking change.
4. **Testes de integracao rodam em CI.** Nao depender de execucao manual.
5. **Timeout em todo client HTTP.** Sem timeout = risco de cascading failure.
