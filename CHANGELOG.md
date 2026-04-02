# Changelog

Todas as mudancas relevantes do framework sao documentadas neste arquivo.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [2.8.0] — 2026-04-02

### Adicionado

- Fase 5b "Auditoria de completude" no `/setup-framework` e `/update-framework` — 5 categorias de checks (arquivos, agents, skills, secoes do CLAUDE.md, integridade de conteudo) com auto-fix
- Regra 11 no CLAUDE.md: auditoria de completude em sincronia entre setup e update

### Alterado

- Fase 4d do `/update-framework` absorvida pela auditoria de completude (era limitada a secoes H2)
- Secao "Pendencias para aderencia total" do `/setup-framework` substituida por diagnostico dinamico

## [2.7.0] — 2026-04-02

### Adicionado

- Doc portavel `PRD_PORTABLE_PROMPT.md` — prompt standalone para criar PRDs em OpenAI Projects, Claude Projects ou Gemini Gems
- Regra 10 no CLAUDE.md: docs portaveis sincronizados com skills
- Separacao de PRDs em diretorio proprio (`prds/`) com PRDS_INDEX independente
- Flag `--from` no `/prd` para preencher a partir de Jira, Notion, Confluence ou Google Docs
- Flag `--export` no `/prd` para gerar PRD formatado na conversa sem criar arquivo
- Verificacao pos-criacao obrigatoria no `/spec` e `/prd`
- Secao de regras imperativas no CLAUDE.template.md

### Corrigido

- Modo Notion do `/prd` e `/spec` agora preenche body da pagina (nao so properties)

## [2.6.0] — 2026-04-02

### Adicionado

- Sistema de PRD — template, skill `/prd` e agent `product-review`
- 3 skills novas: `api-testing`, `dependency-audit`, `performance-profiling`
- 2 action agents: `refactor-agent` e `test-generator` (com `worktree: true`)
- 7 docs novos: QUICK_START, MIGRATION_GUIDE, TROUBLESHOOTING, NOTION_INTEGRATION, SKILLS_MAP, SPEC_EXAMPLE, CHANGELOG
- Secao "Possiveis riscos" no template de spec
- Secao "Proximos passos" em todos os 10 agents
- Campo `model-rationale:` no frontmatter de todos os agents
- Diretrizes permanentes no CLAUDE.md: padroes para criar skills e agents
- Ordem de precedencia entre skills no CLAUDE.template.md
- Script `validate-tags.sh` para verificacao pre-release
- Modo dry-run no `/setup-framework`
- Checklist pos-release no CLAUDE.md
- Exemplos concretos em dba-review, mock-mode, code-quality, docs-sync

### Alterado

- `backlog-report` atualizado de haiku para sonnet (analise de tendencias)
- Severidade padronizada em todos os agents (🔴🟠🟡⚪)
- Placeholders padronizados para formato `{Adaptar: descricao}`
- `install-skills.sh` com deteccao automatica SSH/HTTPS
- `plugin.json` expandido com author, license, keywords, agents, docs
- MANIFEST.md completado com todas as entradas faltantes
- Algoritmo de structural merge documentado no update-framework
- Tratamento de erros Notion documentado no update-framework

### Corrigido

- Referencias a PRD condicionadas ao opt-in do projeto

## [2.5.0] — 2026-04-01

### Adicionado

- Skills `security-review`, `seo-performance`, `syntax-check` e `golden-tests`
- Agent `seo-audit` para analise automatizada de SEO e performance

## [2.4.0] — 2026-04-01

### Adicionado

- Campo `model:` no frontmatter dos agents para selecao de modelo por complexidade (opus, sonnet, haiku)
- Guidelines de dispatch autonomo para agents

## [2.3.0] — 2026-03-31

### Adicionado

- CLAUDE.md do framework com guia completo para desenvolvedores do framework
- Script `release.sh` com modo automatico que detecta bump via Conventional Commits
- Campo `worktree` no frontmatter dos agents
- Secao worktrees e subagents no CLAUDE.template.md

### Alterado

- Processo de release migrado inteiramente para o CLAUDE.md (Claude Code decide o bump)
- Script `release.sh` removido — processo de release vive nas instrucoes do CLAUDE.md

### Corrigido

- Pre-requisitos do Notion MCP mais claros no setup e update
- Instrucoes de configuracao do Notion MCP corrigidas no setup e update

## [2.2.0] — 2026-03-31

### Alterado

- Documentacao do README atualizada com instrucoes do `install-skills.sh`
- Opcao B de instalacao atualizada para usar `install-skills.sh`

### Corrigido

- Auditoria de secoes do CLAUDE.md no setup e update para garantir consistencia

## [2.1.1] — 2026-03-31

### Adicionado

- Script `install-skills.sh` para instalacao e atualizacao pessoal de skills

## [2.1.0] — 2026-03-31

### Adicionado

- Integracao nativa com Notion para specs e backlog via MCP
- `plugin.json` para instalacao via `claude plugin add`
- Documentacao de fluxo dia a dia pos-setup

### Corrigido

- Modo Notion sempre cria pagina (incluindo classificacao Pequeno)
- Frontmatter YAML em agents e skills ajustado para plugin validate
- `plugin.json` movido para `.claude-plugin/` (formato correto do Claude Code)

## [2.0.0] — 2026-03-31

### Adicionado

- Sistema de versionamento com framework-tags e skill `/update-framework`
- Suporte a mobile, infra, CLI, desktop e library (alem de web)
- Cenarios de monorepo no setup (migracao, sub-projeto novo, re-run)
- `reports-index.js` generico com pagina consolidada e auto-deteccao
- `reports.sh` generico com integracao no setup e skills
- `backlog-report.cjs` com auto-regeneracao no `/backlog-update`
- Coluna Owner no SPECS_INDEX, variante externa, validacao pre-implementacao
- Auto-sizing de specs, fluxo RPI, design docs, task breakdown, STATE.md, sub-agents, scope guardrails e context budget
- Templates do framework embutidos na skill setup-framework
- Resolucao de caminhos do framework e docs de distribuicao para times
- Wizard interativo `/setup-framework` para deploy automatizado
- Skills multi-linguagem para testes e guias tecnicos
- Framework expandido para 7 camadas com PROJECT_CONTEXT e suporte profundo a mono-repo
- Suporte a CLAUDE.md hierarquico

### Alterado

- Agents refatorados para autonomos com modularizacao de skills
- DoD sem duplicacao com verify.sh — separacao entre verificacao de maquina e inteligencia
- CLAUDE.md delega pre-commit ao DoD
- Documentacao geral revisada (README, guides, specs)
- Fundamentacao de praticas com pesquisa (RPI, scope guardrails, context budget 60-70%)

### Corrigido

- Headers framework-tag em docs, specs e templates corrigidos
- Setup nunca para em "nao" — separacao entre obrigatorios e opcionais
- Templates SETUP_GUIDE e SPEC_DRIVEN_GUIDE adicionados aos templates do setup
- Gaps no fluxo single-repo do setup
- Setup monorepo nao assume estrutura — mapeia sub-projetos com confirmacao
- Templates do setup sincronizados com versoes atuais
- `reports.sh` limpa `coverage/` antes de rerodar para evitar cache stale
- `/spec` classifica complexidade automaticamente (nao o humano)
