---
name: map-codebase
description: Analisa o projeto em paralelo e gera mapa estruturado de stack, arquitetura, convencoes e concerns
user_invocable: true
---
<!-- framework-tag: v2.36.0 framework-file: skills/map-codebase/SKILL.md -->

# /map-codebase — Mapeamento de codebase

Analisa o projeto em 4 dimensoes paralelas e gera um mapa estruturado: stack tecnologico, arquitetura, convencoes de codigo e concerns ativos. Util para onboarding em projetos existentes e para o Claude iniciar sessao em repositorio desconhecido.

## Uso

```
/map-codebase
/map-codebase --save
/map-codebase --quick
```

- **Sem flag:** exibe o mapa completo na conversa
- **`--save`:** salva em `.claude/CODEBASE_MAP.md` (avisa antes de sobrescrever)
- **`--quick`:** resumo executivo inicial (stack em 3 linhas, arquitetura em 2, top 3 concerns). Nao substitui analise completa. Nao usar antes de executar tasks em codebase desconhecida — apenas para orientacao rapida ou preview.

## Quando usar

- Onboarding em projeto existente (primeiro contato)
- Inicio de sessao após longa ausência
- Antes de planejar feature em area desconhecida do codigo
- Para entender convencoes antes de implementar

## Quando NAO usar

- Projeto ja mapeado recentemente e contexto ainda valido
- Repositorio vazio ou em fase inicial (poucos arquivos de codigo)
- Task simples em area bem conhecida

## Instrucoes

### Passo 0 — Delimitar escopo (obrigatorio antes de qualquer analise)

1. **Determinar escopo:** executar `git ls-files --cached --others --exclude-standard` para listar arquivos rastreados. Se git nao estiver disponivel ou o comando falhar, usar listagem do diretorio atual respeitando `.gitignore` como referencia heuristica.

2. **Fronteiras de escopo — nunca entrar em:**
   - `node_modules/`, `vendor/`, `dist/`, `build/`, `.gradle/`, `.cargo/`
   - Arquivos gerados (detectar por `.gitignore`)
   - Conteudo de pacotes externos — apenas manifestos

3. **Profundidade por arquivo:** ler no maximo 50–80 linhas por arquivo para identificar padroes. O objetivo e visao geral, nao compreensao completa. Ir alem apenas com razao especifica.

4. **Limite de arquivos por dimensao:** maximo 30 arquivos por agente. Se o projeto for maior, amostrar garantindo **minimos obrigatorios** antes de preencher o restante por prioridade:

   **Minimos obrigatorios** (sempre incluir):
   - Pelo menos 1 entry point (`main.*`, `index.*`, `app.*`, `server.*`, `cmd/`) — excecao: se tipo `Biblioteca/shared code`, substituir pelo principal ponto de exposicao (arquivo que exporta a API publica da lib)
   - Pelo menos 1 config file — detectar por nome convencional (`package.json`, `go.mod`, `Cargo.toml`, `requirements.txt`, `pom.xml`, `Dockerfile`, `docker-compose.yml`, `.env*`) **ou** por padrao de conteudo (lista de dependencias, scripts de build/deploy, blocos de providers/resources, configuracao de runtime)
   - Pelo menos 1 arquivo de dominio (`services/`, `modules/`, `domain/`, `core/`, `internal/`)

   **Preencher restante** por ordem de prioridade:
   1. Mais entry points e scripts de execucao (`package.json scripts`, `Makefile`)
   2. Mais configs e infra (CI/CD `.github/workflows/`, env adicional)
   3. Mais arquivos de dominio e integracao (routers, controllers, handlers)
   4. Fallback: arquivos com maior churn (`git log`), se disponivel e nao custoso. Caso contrario: arquivos maiores ou mais centrais na estrutura.

5. **Dependencias externas:** consultar apenas manifestos — nunca seguir imports recursivamente nem ler conteudo de pacotes externos. Listar apenas dependencias diretas, nao transitivas.

### Passo 1 — Analise em 4 dimensoes paralelas

**Principio:** `Deteccao → Especializacao opcional → Fallback generico`. Cada agente detecta a stack de sua dimensao antes de aplicar heuristicas. Se stack conhecida → heuristicas especificas. Se desconhecida → heuristicas genericas. Nunca assumir stack.

**Modo preferencial:** lançar ate 4 chamadas de Agent tool em paralelo (preferencialmente na mesma mensagem quando suportado), uma por dimensao. Nao requer worktrees — analise e read-only. O CLAUDE.md do projeto nao precisa ter "Worktrees e subagents" configurado.

**Fallback (se Agent tool indisponivel):** executar as 4 dimensoes sequencialmente na mesma sessao. Mencionar no output: `(analise sequencial — paralelo indisponivel)`.

Cada dimensao e analisada de forma completamente independente — sem compartilhar estado. A sintese (Passo 2) so inicia após todas as dimensoes serem concluidas. Nenhuma dimensao pode depender de resultados de outra durante a coleta.

---

**Dimensao A — Stack tecnologico:**

- Linguagens detectadas (por extensao de arquivo e volume)
- Frameworks e bibliotecas principais
- Build tools, test runners, linters, formatadores
- **Tipo de runtime:** compilado (Go, Rust, Java, C#), interpretado (Python, Ruby, JS/TS, PHP), declarativo (infra/config driven systems)
- **Forma de execucao:** servico persistente (web server, daemon), CLI (execucao pontual por comando), batch (job agendado/trigger), infra apply (IaC)
- **Modelo de deploy:** inferir apenas com evidencia explicita (Dockerfile, CI/CD, config de plataforma detectada). Valores: containerizado, serverless, PaaS, bare metal, IaC apply. Se sem evidencia → `(nao detectado)`

Exemplo de saida (Node.js + Docker):
```
Linguagens: TypeScript (principal), JavaScript, Shell
Framework: Express 4.18
Test runner: Vitest
Runtime: interpretado
Forma de execucao: servico persistente (web server)
Modelo de deploy: containerizado (Dockerfile presente)
```

---

**Dimensao B — Arquitetura:**

- **Tipo de sistema** (classificar antes do padrao arquitetural):
  - `Aplicacao`: codigo executavel + entry point
  - `Infraestrutura declarativa`: .tf, .yaml/.json sem logica, blocos resource/module/provider, diretorios `environments/`, `modules/`
  - `Scripts/automacao`: shell scripts, CI, sem entry point persistente
  - `Biblioteca/shared code`: sem executavel, expoe API/tipos para outros projetos
  - Se multiplos tipos coexistem: classificar separadamente

- Estrutura de pastas (top-level + proposito de cada)
- Entry points
- Camadas detectadas (handlers/controllers, services/use-cases, repositories/data, models)
- **Padrao arquitetural:** identificar apenas com evidencia clara:
  - MVC = controllers + services + routes juntos
  - Clean Architecture = usecases + repositories com separacao explicita
  - Hexagonal = ports + adapters
  - Modular monolith = modulos com fronteiras explicitas
  - Framework-driven = Nuxt, NestJS, Django, Rails, etc.
  - Se nao for claro → `(nao detectado)`. Nunca inferir padrao apenas pelo nome de diretorios isolados.

Exemplo de saida (monolito MVC):
```
Tipo de sistema: Aplicacao
Estrutura:
  src/controllers/   — handlers HTTP
  src/services/      — logica de negocio
  src/models/        — entidades e ORM
  src/routes/        — definicao de rotas
  test/              — testes unitarios e de integracao
Padrao arquitetural: MVC (controllers + services + routes evidentes)
```

---

**Dimensao C — Convencoes:**

- Naming: arquivos, pastas, funcoes, variaveis (camelCase, snake_case, kebab-case, PascalCase)
- Organizacao de testes (colocados com o source ou em pasta separada)
- Padrao de error handling (error codes, classes de excecao, wrapping)
- Padrao de log (biblioteca usada, campos padrao, nivel de detalhe)
- Padrao de config (env vars, config files, secrets management)

Exemplo de saida:
```
| Aspecto      | Padrao detectado                    | Arquivo de referencia     |
|---|---|---|
| Naming arquivos | kebab-case                        | src/user-service.ts:1     |
| Naming funcoes  | camelCase                          | src/auth.ts:12            |
| Error handling  | classes customizadas (AppError)    | src/errors/index.ts:3     |
| Logs            | winston com structured fields      | src/logger.ts:1           |
| Config          | dotenv + zod validation            | src/config.ts:1           |
```

---

**Dimensao D — Concerns:**

Avaliar no contexto do tipo de sistema (Dim B). Se um concern nao se aplica ao tipo → marcar como `(nao aplicavel)`. Se sem dados → `(nao detectado)`.

- **Performance:** hotspots de complexidade (arquivos >300 linhas), queries sem indice visivel, loops aninhados suspeitos. *(Exemplos ilustrativos — adaptar ao tipo de sistema detectado)*
- **Seguranca:** padroes de risco (env vars com SECRET/TOKEN/KEY sem protecao, queries concatenadas, inputs nao sanitizados)
- **Manutencao:** TODOs/HACKs/FIXMEs (contar e localizar), arquivos com alta complexidade aparente, acoplamento excessivo
- **Testabilidade:** ratio arquivos com testes vs. sem testes, ausência de mocks/interfaces, logica embedded em handlers
- **Observabilidade:** ausência de logs estruturados, falta de tracing, erros silenciados

### Passo 2 — Sintetizar

Cada dimensao deve ser analisada de forma independente (Passo 1) antes de iniciar a sintese. Na sintese, correlacionar dimensoes e permitido, mas nunca contradizer evidencias coletadas individualmente.

Estrutura de saida obrigatoria:

---

**## Stack tecnica** (Dim A)
- Tipo(s) de sistema
- Tecnologias detectadas
- Runtime(s)
- Forma de execucao
- *Confianca: Alta | Media | Baixa*

**## Estrutura de arquivos** (Dim B)
- Arvore resumida (top-level + proposito de cada pasta/arquivo principal)
- Separacao por contexto (backend/frontend/infra/etc., se aplicavel)
- Padrao arquitetural (se identificado com evidencia clara)
- *Confianca: Alta | Media | Baixa*

**## Convencoes** (Dim C)
- Tabelas para naming, organizacao, patterns
- *Confianca: Alta | Media | Baixa*

**## Concerns** (Dim D)

### Performance
- [achados ou `(nao detectado)` ou `(nao aplicavel)`]

### Seguranca
- [achados]

### Manutencao
- [achados]

### Testabilidade
- [achados]

### Observabilidade
- [achados]

*Confianca: Alta | Media | Baixa*

---

**Criterios de confianca por dimensao:**
- `Alta` — evidencia direta (config, codigo explicito, declaracao no manifesto)
- `Media` — inferencia consistente (padroes repetidos, multiplos arquivos convergem)
- `Baixa` — sinais fracos ou incompletos (unico arquivo, convencao ambigua)

**## Cobertura da analise** (secao obrigatoria)
- Arquivos analisados vs total estimado. Total estimado via `git ls-files` ou listagem filtrada por `.gitignore`.
- Exemplo: `28 de 150 arquivos — amostragem aplicada (entry points + configs + dominio)`
- Se amostragem foi necessaria: indicar quais prioridades foram usadas.

**## Confianca geral** (secao obrigatoria ao final)
- Alta | Media | Baixa
- Baseado em: consistencia entre dimensoes, presenca de evidencia clara, cobertura de arquivos analisados.

### Passo 3 — Gerar saida

- **Modo padrao:** exibir o mapa completo na conversa
- **`--save`:** salvar em `.claude/CODEBASE_MAP.md`. Se o arquivo ja existe, avisar e confirmar antes de sobrescrever
- **`--quick`:** exibir apenas Stack tecnica + Estrutura de arquivos em formato resumido + top 3 concerns. Incluir aviso: `Resumo executivo — nao substitui analise completa.`

### Passo 4 — Alimentar PROJECT_CONTEXT.md (se existir)

1. Verificar se `PROJECT_CONTEXT.md` existe na raiz do projeto
2. **Se existir:** propor popular as secoes com os dados detectados:
   - `## Stack tecnica` ← Dim A
   - `## Estrutura de arquivos` ← Dim B
   - `## Convencoes` ou secao equivalente ← Dim C (convencoes aqui tornam o scout do `/discuss` mais preciso)
3. **Mostrar o diff proposto** e aguardar confirmacao antes de aplicar. Nunca aplicar automaticamente.
4. **Nao sobrescrever** secoes com conteudo real. Substituir apenas `{placeholders}` e linhas com `{Adaptar:`.
5. **Se nao existir:** silencio — nao criar o arquivo.

### Passo 5 — Sugerir proximos passos

Com base nos concerns detectados, sugerir (nao executar):

- Concerns de seguranca detectados → agent `security-audit.md`
- Debito tecnico alto (muitos TODOs/HACKs, arquivos muito longos) → skill `code-quality/README.md`
- Cobertura de testes baixa → skill `testing/README.md`
- Dependencias nao auditadas → skill `dependency-audit/README.md`
- Codebase desconhecida + planejamento de feature → `/spec-creator` + `execution-plan`

## Regras

> **Principio central:** `Deteccao → Especializacao opcional → Fallback generico`
> Detectar a stack primeiro. Se conhecida → usar heuristicas especificas. Se desconhecida → usar heuristicas genericas seguras. Nunca inverter. Nunca assumir stack.

1. **Read-only:** nunca modificar arquivos do projeto durante a analise. Esta skill e exclusivamente observacional.
2. **Guardrail de escopo e profundidade:** analisar apenas arquivos rastreados pelo git. Nunca entrar em `node_modules/`, `vendor/`, `dist/`, `build/` ou arquivos gerados. Dependencias: apenas manifestos, nunca conteudo de pacotes externos. Sem rastreamento transitivo de imports. Priorizar visao geral — ler no maximo 50–80 linhas por arquivo. Nao aprofundar excessivamente em nenhum arquivo individual.
3. **Limite por dimensao:** maximo 30 arquivos por agente. Garantir minimos obrigatorios antes de amostrar o restante.
4. **Paralelismo preferencial:** lançar ate 4 agents em paralelo (preferencialmente na mesma mensagem quando suportado). Ter fallback sequencial — indicar `(analise sequencial — paralelo indisponivel)` no output quando usado.
5. **Paralelismo determinístico:** cada dimensao (A–D) e analisada de forma completamente independente, sem compartilhar estado. A sintese (Passo 2) so inicia após todas as dimensoes serem concluidas. A ordem de execucao nao deve afetar o resultado.
6. **Marcar incertezas:** usar `(inferido)` para achados nao diretamente evidentes, `(nao detectado)` se sem dados, `(nao aplicavel)` se o concern nao se aplica ao tipo de sistema.
7. **Nao inventar stack:** sem evidencia direta, nao incluir. Preferir `(nao detectado)` a suposicao.
8. **Concerns sao observacoes, nao prescricoes:** listar o que foi encontrado. Nao recomendar mudancas arquiteturais nem criticar escolhas do projeto.
9. **`--save` com confirmacao:** se `.claude/CODEBASE_MAP.md` ja existe, avisar e aguardar confirmacao antes de sobrescrever.
10. **Achados concretos:** referenciar arquivos reais com `arquivo:linha` quando confiavel. Evitar afirmacoes vagas sem referencia.
11. **PROJECT_CONTEXT.md com confirmacao:** nunca aplicar atualizacoes sem mostrar o diff proposto e aguardar confirmacao do usuario.

## Integracao com workflow

O output desta skill alimenta diretamente:

- **`PROJECT_CONTEXT.md`** — secoes Stack tecnica, Estrutura de arquivos e Convencoes (Passo 4, com confirmacao)
- **`/spec-creator`** — contexto de arquitetura e convencoes para definir escopo e impacto de uma spec
- **`execution-plan`** — entendimento de arquitetura antes de planejar waves de execucao
- **`/discuss`** — PROJECT_CONTEXT.md enriquecido pelo `/map-codebase` torna o scout de gray areas mais preciso
- **`task-runner`** — execucao com contexto fresco sobre o codebase

**Recomendacao:** executar `/map-codebase` antes de qualquer planejamento em codebase desconhecida.

## Checklist

- [ ] Passo 0 completo: escopo delimitado, fronteiras definidas
- [ ] 4 dimensoes analisadas (A: Stack, B: Arquitetura, C: Convencoes, D: Concerns)
- [ ] Stack com runtime e forma de execucao identificados
- [ ] Tipo de sistema classificado (Dim B)
- [ ] Padrao arquitetural com evidencia clara (ou `nao detectado`)
- [ ] Convencoes com exemplos concretos (arquivo:linha quando confiavel)
- [ ] Concerns estruturados nas 5 categorias (Performance/Seguranca/Manutencao/Testabilidade/Observabilidade)
- [ ] Incertezas marcadas (`inferido`, `nao detectado`, `nao aplicavel`)
- [ ] Cobertura da analise reportada (arquivos analisados vs total estimado)
- [ ] Confianca geral declarada
- [ ] PROJECT_CONTEXT.md verificado — diff proposto se existir (Passo 4)
- [ ] Proximos passos sugeridos com base nos concerns (Passo 5)
