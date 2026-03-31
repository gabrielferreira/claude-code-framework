# CLAUDE.md — claude-code-framework (desenvolvimento)

Este arquivo e para quem **desenvolve o framework**. NAO e copiado para projetos — projetos recebem o `CLAUDE.template.md` customizado pelo setup.

## O que e este projeto

Framework de specs, skills, agents e verificacao para projetos com Claude Code. Gera estrutura completa via `/setup-framework` e mantém atualizado via `/update-framework`. Suporta Notion nativo via MCP.

## Estrutura do repo

```
claude-code-framework/
├── CLAUDE.md                  ← ESTE ARQUIVO (dev do framework)
├── CLAUDE.template.md         ← Template que vira CLAUDE.md nos projetos
├── PROJECT_CONTEXT.md         ← Template de contexto
├── SPECS_INDEX.template.md    ← Template do indice de specs
├── MANIFEST.md                ← Fonte de verdade: o que vai pro projeto e como
├── VERSION                    ← Versao atual (semver)
├── .claude-plugin/
│   └── plugin.json            ← Manifesto para instalacao via plugin
├── agents/                    ← Agents source (copiados como overwrite)
├── skills/
│   ├── setup-framework/       ← Skill de setup (inclui templates/)
│   │   └── templates/         ← Copia de todos os arquivos que vao pro projeto
│   ├── update-framework/      ← Skill de update
│   ├── spec-creator/          ← Skill /spec (dual-mode: repo + Notion)
│   ├── backlog-update/        ← Skill /backlog-update (dual-mode)
│   └── {outras}/              ← Skills de dominio (testing, code-quality, etc.)
├── docs/                      ← Docs source
├── specs/                     ← Templates de spec (TEMPLATE.md, DESIGN_TEMPLATE.md)
└── scripts/
    ├── verify.sh              ← Copiado pro projeto (manual)
    ├── reports.sh             ← Copiado pro projeto (manual)
    ├── release.sh             ← NAO copiado — uso exclusivo do framework
    └── install-skills.sh      ← NAO copiado — instalacao pessoal
```

## Regra de ouro: source + templates em sincronia

Todo arquivo que vai pro projeto existe em **dois lugares**:
1. **Source** (raiz): `agents/security-audit.md`, `skills/testing/README.md`, etc.
2. **Template** (copia): `skills/setup-framework/templates/agents/security-audit.md`, etc.

**Sempre que editar um source, copiar para o template correspondente.** O setup usa os templates, o update usa o source via git diff. Se divergirem, o framework quebra.

```bash
# Exemplo: editou agents/security-audit.md
cp agents/security-audit.md skills/setup-framework/templates/agents/security-audit.md
```

## MANIFEST.md

E a fonte de verdade sobre o que vai pro projeto e com qual estrategia:
- **overwrite** — substitui direto (agents, templates de spec, plugin.json)
- **structural** — preserva conteudo customizado, adiciona/remove secoes (skills, docs)
- **manual** — mostra diff, nunca aplica sozinho (scripts, CLAUDE.md, PROJECT_CONTEXT.md)
- **skip** — nunca toca (backlog, specs do projeto, STATE.md)

Consultar o MANIFEST antes de adicionar qualquer arquivo novo ao framework.

## Arquivos que NAO vao pro projeto

| Arquivo | Proposito |
|---|---|
| `CLAUDE.md` (este) | Dev do framework |
| `README.md` | Documentacao do repo |
| `scripts/release.sh` | Automacao de versao |
| `scripts/install-skills.sh` | Instalacao pessoal |
| `.claude-plugin/plugin.json` | Vai como overwrite (e do framework, nao do projeto) |

Documentados no MANIFEST na secao "Scripts do framework (nao copiados)".

## Conventional Commits (obrigatorio)

Todos os commits seguem Conventional Commits. O `release.sh auto` depende disso para detectar o bump correto.

| Prefixo | Quando | Bump |
|---|---|---|
| `feat:` | Funcionalidade nova (skill, agent, campo, secao) | minor |
| `fix:` | Correcao de bug ou instrucao errada | patch |
| `docs:` | Documentacao (README, SETUP_GUIDE, etc.) | patch |
| `refactor:` | Reestruturacao sem mudar comportamento | patch |
| `release:` | Gerado pelo release.sh | — |
| `feat!:` ou `BREAKING CHANGE` | Mudanca incompativel | major |

## Versionamento e release

```bash
# Publicar nova versao (detecta bump automaticamente)
./scripts/release.sh auto

# Ou especificar
./scripts/release.sh patch   # fix/docs
./scripts/release.sh minor   # feat
./scripts/release.sh major   # breaking change
```

O script faz tudo: VERSION, plugin.json, framework-tags, commit, tag, push.

**Framework-tags:** todo arquivo .md que vai pro projeto tem `<!-- framework-tag: vX.Y.Z framework-file: path -->`. O release.sh atualiza todos via grep. Nao manter lista hardcoded.

## Fluxo de desenvolvimento

1. Criar worktree para a sessao
2. Fazer as mudancas nos sources
3. Sincronizar com templates (`cp source → templates/`)
4. Atualizar MANIFEST se adicionou/removeu arquivo
5. Commitar com Conventional Commits
6. Merge na main
7. `./scripts/release.sh auto`

## Regras

1. **Nunca editar so o template sem editar o source** (ou vice-versa). Sempre os dois.
2. **Nunca adicionar arquivo ao framework sem entrada no MANIFEST.** Decidir a estrategia antes.
3. **Testar mudancas num repo real** antes de publicar. Instalar via `install-skills.sh` e rodar `/setup-framework` ou `/update-framework` num repo de teste.
4. **Skills dual-mode (repo + Notion):** `/spec` e `/backlog-update` detectam `## Integracao Notion (specs)` no CLAUDE.md do projeto. Qualquer mudanca nessas skills precisa funcionar nos dois modos.
5. **Agents sao read-only.** Todos tem `worktree: false`. Se criar agent que edita codigo, marcar `worktree: true`.
6. **O framework nao configura MCP.** Setup/update apenas usam o MCP Notion se ja estiver configurado. Nunca pedir token ou configurar autenticacao.
7. **CLAUDE.md do projeto e intocavel por overwrite.** Sempre `manual` — mostrar diff, nunca aplicar sozinho.

## Notion (integracao nativa)

Skills `/spec` e `/backlog-update` suportam Notion via MCP. O setup detecta templates da database e gera a secao `## Integracao Notion (specs)` no CLAUDE.md do projeto.

Para testar: precisa de MCP Notion configurado no Claude Code com acesso a uma database de teste.

## Como testar

1. Clonar um repo de teste (ou criar um vazio)
2. Instalar skills: `./scripts/install-skills.sh`
3. No repo de teste: `/setup-framework` → verificar que tudo foi gerado
4. Fazer uma mudanca no framework, bumpar versao
5. No repo de teste: `/update-framework` → verificar que detecta diferenças e aplica corretamente
