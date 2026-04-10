<!-- framework-tag: v2.36.0 framework-file: PROJECT_CONTEXT.md -->
# {NOME_DO_PROJETO} — Contexto do Projeto

> **Como usar este arquivo**
> Cole o conteúdo abaixo como primeira mensagem ao iniciar uma discussão sobre este projeto em qualquer ferramenta de IA. Ele contém tudo que o modelo precisa para dar respostas úteis e alinhadas com o que já foi decidido.
>
> **Manutenção:** atualize este arquivo toda vez que uma decisão arquitetural for tomada, uma nova feature for implementada, ou o estado atual do projeto mudar significativamente.
>
> **Diferença do CLAUDE.md:** o `CLAUDE.md` é para o Claude Code (regras internas, skills, verify.sh). Este arquivo é para **qualquer** ferramenta de IA — é um briefing completo e autossuficiente.

---

## O que é o projeto

{Adaptar: o que o sistema faz, para quem, e qual problema resolve. 2-3 frases.}

**Exemplo:**
> {Adaptar: descricao do sistema, publico-alvo e problema que resolve.}

---

## Stack técnica

| Camada | Tecnologia |
|---|---|
| Frontend | {React 18 + Vite / Next.js / Vue / etc. — remover se não aplicável} |
| Backend | {Node.js 20 + Express / FastAPI / Django / etc. — remover se não aplicável} |
| Banco | {PostgreSQL 16 / MySQL / MongoDB / etc. — remover se não aplicável} |
| Auth | {JWT / OAuth / Passwordless / etc. — remover se não aplicável} |
| Pagamentos | {Gateway de pagamento — remover se não aplicável} |
| E-mail | {Serviço de e-mail transacional — remover se não aplicável} |
| Mobile | {React Native / Flutter / Swift / Kotlin — remover se não aplicável} |
| Infra/IaC | {Terraform / Pulumi / CDK / Ansible — remover se não aplicável} |
| CLI | {Commander / Cobra / Click / Clap — remover se não aplicável} |
| Testes | {Jest / Vitest / Pytest / etc. — contagem atual: ver CLAUDE.md} |
| Deploy | {Docker / Vercel / AWS / etc.} |

{Adaptar: manter apenas as linhas relevantes ao projeto. Remover as que nao se aplicam.}

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

{Adaptar: se monorepo, mostrar sub-projetos com CLAUDE.md L2 em cada um. Exemplo:}

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

{Adaptar: decisoes que NAO devem ser rediscutidas — o LLM precisa respeitar estas decisoes.}

**Formato sugerido:**

**{Nome da decisão}.** {Explicação curta. Por que foi decidido assim. Implicações práticas.}

**Exemplos:**
- **{Decisão 1}.** {Explicação e implicações.}
- **{Decisão 2}.** {Explicação e implicações.}
- **{Decisão 3}.** {Explicação e implicações.}

---

## Regras de negócio

{Adaptar: regras fundamentais do dominio que qualquer LLM precisa saber para dar respostas corretas.}

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

{Adaptar: decisoes de seguranca mais importantes que o LLM deve respeitar.}

- {Ponto 1 — ex: prompt injection tratada como ameaça real}
- {Ponto 2 — ex: timing-safe comparison em toda comparação de secret}
- {Ponto 3 — ex: rate limit em endpoints de auth}

---

## Estado atual do projeto

### Implementado e testado

{Adaptar: features prontas — ajuda o LLM a nao sugerir reimplementar algo que ja existe.}

- {Feature 1}
- {Feature 2}
- ...

### Dívida técnica conhecida

{Adaptar: problemas conhecidos — ajuda o LLM a nao tropecar neles.}

- Backlog completo em `.claude/specs/backlog.md`

---

## Convenções de código

- **Commits:** Conventional Commits — ver `docs/GIT_CONVENTIONS.md`
- **Testes:** toda nova feature ou bugfix vem com teste
- **Errors:** sempre específicos — `{ error: "código", message: "texto para o usuário" }`
- **Logs:** estruturados, nunca logam dados sensíveis do usuário

---

## Restrições inegociáveis

> Decisões arquiteturais e padrões fixos que não estão abertos a discussão.
> Toda spec e execution-plan deve respeitar estas restrições.

{Adaptar — exemplos de restrições comuns:}

- **Stack de banco:** PostgreSQL — sem ORM alternativo, sem SQLite em produção
- **Autenticação:** JWT via middleware `auth` — sem sessão em memória, sem cookie sem httpOnly
- **API:** REST com JSON — sem GraphQL, sem gRPC neste projeto
- **Infra:** Kubernetes — sem deploy direto em VMs ou Heroku
- **Cobertura mínima:** 80% em funções de negócio — não negociável por prazo
- {adicionar restrições do projeto}

**Como usar:** ao criar spec ou execution-plan, verificar se a proposta respeita estas restrições. Se conflitar, escalar antes de prosseguir — não contornar silenciosamente.

---

## O que este projeto NÃO faz

{Adaptar: o que esta fora do escopo — evita sugestoes inuteis do LLM.}

- {Limitação 1}
- {Limitação 2}
- {Limitação 3}
