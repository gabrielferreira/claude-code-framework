# {NOME_DO_PROJETO} — Contexto do Projeto

> **Como usar este arquivo**
> Cole o conteúdo abaixo como primeira mensagem ao iniciar uma discussão sobre este projeto em qualquer ferramenta de IA. Ele contém tudo que o modelo precisa para dar respostas úteis e alinhadas com o que já foi decidido.
>
> **Manutenção:** atualize este arquivo toda vez que uma decisão arquitetural for tomada, uma nova feature for implementada, ou o estado atual do projeto mudar significativamente.
>
> **Diferença do CLAUDE.md:** o `CLAUDE.md` é para o Claude Code (regras internas, skills, verify.sh). Este arquivo é para **qualquer** ferramenta de IA — é um briefing completo e autossuficiente.

---

## O que é o projeto

{Descrever em 2-3 frases: o que o sistema faz, para quem, e qual problema resolve.}

**Exemplo:**
> {Descreva aqui o que o sistema faz, para quem, e o problema que resolve.}

---

## Stack técnica

| Camada | Tecnologia |
|---|---|
| Frontend | {React 18 + Vite / Next.js / Vue / etc.} |
| Backend | {Node.js 20 + Express / FastAPI / Django / etc.} |
| Banco | {PostgreSQL 16 / MySQL / MongoDB / etc.} |
| Auth | {JWT / OAuth / Passwordless / etc.} |
| Pagamentos | {Gateway de pagamento — se aplicável} |
| E-mail | {Serviço de e-mail transacional — se aplicável} |
| Testes | {Jest / Vitest / Pytest / etc. — contagem atual: ver CLAUDE.md} |
| Deploy | {Docker / Vercel / AWS / etc.} |

---

## Estrutura de arquivos

```
{projeto}/
├── {frontend}/
│   ├── {entry-point}             # {Descrição}
│   ├── {components}/             # {Descrição}
│   └── {pages}/                  # {Descrição}
├── {backend}/
│   ├── {routes}/                 # {Descrição}
│   ├── {services}/               # {Descrição}
│   ├── {middleware}/              # {Descrição}
│   └── {tests}/                  # {N} suites
├── {database}/
│   ├── {schema.sql}              # DDL completo
│   └── {migrations}/             # Incrementais
├── docs/
│   ├── README.md                 # Índice da documentação
│   ├── GIT_CONVENTIONS.md        # Commits, branches, PRs
│   └── {outros docs}
├── scripts/
│   ├── verify.sh                 # Verificação pré-commit
│   ├── reports.sh                # Orquestrador de reports (auto-detecção)
│   ├── reports-index.js          # Página consolidada de reports
│   └── backlog-report.cjs        # Report HTML do backlog
└── .claude/
    ├── skills/                   # {N} skills
    └── specs/                    # Specs ativas + backlog + done/
        ├── STATE.md              # Memória persistente entre sessões
        └── {id}-design.md        # Design docs (Grande/Complexo)
```

{Se monorepo: adaptar a estrutura acima para mostrar sub-projetos com CLAUDE.md L2 em cada um. Exemplo:}

```
{projeto}/
├── CLAUDE.md                     # L0 — regras globais
├── SPECS_INDEX.md
├── apps/
│   ├── web/
│   │   ├── CLAUDE.md             # L2 — regras do frontend
│   │   └── ...
│   └── api/
│       ├── CLAUDE.md             # L2 — regras do backend
│       └── ...
├── packages/
│   └── shared/
│       └── CLAUDE.md             # L2 — regras do package
└── .claude/
    ├── skills/                   # Skills compartilhadas
    └── specs/                    # Specs centralizadas ou distribuídas por módulo
```

---

## Decisões arquiteturais já tomadas

{Listar decisões que NÃO devem ser rediscutidas — o LLM precisa respeitar estas decisões.}

**Formato sugerido:**

**{Nome da decisão}.** {Explicação curta. Por que foi decidido assim. Implicações práticas.}

**Exemplos:**
- **{Decisão 1}.** {Explicação e implicações.}
- **{Decisão 2}.** {Explicação e implicações.}
- **{Decisão 3}.** {Explicação e implicações.}

---

## Regras de negócio

{Regras fundamentais do domínio que qualquer LLM precisa saber para dar respostas corretas.}

**Formato sugerido:**

**{Área}:**
- {Regra 1}
- {Regra 2}

**Exemplo:**
> **{Área 1}:** {regras}
> **{Área 2}:** {regras}
> **{Área 3}:** {regras}

---

## Segurança — pontos críticos

{Resumir as decisões de segurança mais importantes que o LLM deve respeitar.}

- {Ponto 1 — ex: prompt injection tratada como ameaça real}
- {Ponto 2 — ex: timing-safe comparison em toda comparação de secret}
- {Ponto 3 — ex: rate limit em endpoints de auth}

---

## Estado atual do projeto

### Implementado e testado

{Listar features prontas — ajuda o LLM a não sugerir reimplementar algo que já existe.}

- {Feature 1}
- {Feature 2}
- ...

### Dívida técnica conhecida

{Listar problemas conhecidos — ajuda o LLM a não tropeçar neles.}

- Backlog completo em `.claude/specs/backlog.md`

---

## Convenções de código

- **Commits:** Conventional Commits — ver `docs/GIT_CONVENTIONS.md`
- **Testes:** toda nova feature ou bugfix vem com teste
- **Errors:** sempre específicos — `{ error: "código", message: "texto para o usuário" }`
- **Logs:** estruturados, nunca logam dados sensíveis do usuário

---

## O que este projeto NÃO faz

{Listar explicitamente o que está fora do escopo — evita sugestões inúteis do LLM.}

- {Limitação 1}
- {Limitação 2}
- {Limitação 3}
