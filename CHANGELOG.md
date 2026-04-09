# Changelog

Todas as mudancas relevantes do framework sao documentadas neste arquivo.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [2.23.1] — 2026-04-09

### Corrigido

- **spec-creator (modo Notion):** formato da pergunta de Severidade e Estimativa agora explícito — `Campo: **valor** *(sugestão para {complexidade})* — confirma ou ajusta?`

## [2.23.0] — 2026-04-09

### Alterado

- **spec-creator (modo Notion):** Severidade e Estimativa agora são obrigatórios e vêm com sugestão automática baseada na complexidade (Pequeno→baixa/<4h, Médio→media/1-2 dias, Grande→alta/1-2 semanas, Complexo→critica/>2 semanas). Se `--from` tem prioridade/story points, mapeia automaticamente.

## [2.22.0] — 2026-04-09

### Adicionado

- **Hook de verificação pós-commit:** setup-framework configura automaticamente `PostToolUse` em `.claude/settings.local.json` — roda `scripts/verify.sh` após cada `git commit`, silêncio quando passa, injeta apenas linhas `❌` quando falha
- **Check no update-framework:** avisa no UPDATE_REPORT.md quando hook não está configurado, apontando para `docs/VERIFY_HOOK.md`
- **`docs/VERIFY_HOOK.md`:** documentação do hook — por que usar, pré-requisitos, configuração manual, como testar

## [2.21.0] — 2026-04-08

### Adicionado

- **Content patches:** mecanismo para surfacar mudanças intra-seção no update (migration template + fase 3.2b no update-framework)
- **Categoria 7 "Coerência de customização":** auditoria em setup e update verifica referências órfãs quando projeto remove TDD, sub-agents ou agents
- **Gate obrigatório (Médio+):** spec-driven exige spec aprovada + execution-plan escrito antes de implementar
- **Próximos passos no spec-creator:** após criar spec, direciona para spec-driven e execution-plan conforme complexidade
- **Bootstrap checks:** spec-creator e backlog-update criam dirs/arquivos automaticamente se não existem
- **Seção "Planejamento" no definition-of-done:** checklist verifica existência de execution-plan para Médio+

### Mudado

- **Toda mudança cria spec:** Pequeno cria spec light (contexto + critério mínimo), não só entrada no backlog. Unificado entre modo repo e Notion
- **MANIFEST: agents, templates de spec e backlog-format agora structural** (antes overwrite). Preserva `{Adaptar:}`, `model:` editado e seções custom do projeto
- **TDD e sub-agents condicionais:** skills degradam gracefully quando projeto remove seção TDD ou sub-agents do CLAUDE.md
- **Exceção TDD unificada:** duas exceções claras (Pequeno + bug urgente em produção) em spec-driven e CLAUDE.template
- **Emojis de complexidade diferenciados:** ⚪ Pequeno, 🔵 Médio, 🟣 Grande, ⬛ Complexo (não conflitam mais com severidade 🔴🟠🟡⚪)
- **Severidade padronizada cross-agents:** performance-audit usa Crítico/Alto/Médio/Info (antes P1/P2/P3)
- **backlog-format.md:** corrigido para modelo de arquivo único (antes descrevia 2 arquivos)
- **"Antes de commitar" reduzido:** delega detalhes ao Definition of Done, sem duplicação
- **verify.sh consolidado:** menção única em Regras de operação, demais seções referenciam

### Corrigido

- Tabela de classificação de complexidade existia em 6 lugares com divergências — agora spec-driven é fonte canônica
- SPEC_DRIVEN_GUIDE.md não incluía execution-plan no fluxo Médio — sincronizado
- Auditoria setup vs update violava regra 11 (wording Notion, check .gitignore, numeração Cat.6) — sincronizado
- Contradição no spec-creator: SPECS_INDEX.md "se existir" vs obrigatório — unificado

## [2.20.0] — 2026-04-08

### Adicionado

- GitHub Actions CI (`ci.yml`): valida framework-tags, version sync, source-template sync e migration exists em cada push/PR
- `scripts/check-sync.sh`: verifica que cada arquivo em `templates/` está em sincronia com seu source via `framework-file:` tag (64 pares)
- Notificação automática no Google Chat ao final do CI com sucesso — release envia resumo do CHANGELOG formatado com emojis; push para main envia versão + commit

### Corrigido

- Sincronização perdida entre `CLAUDE.template.md` e `templates/CLAUDE.md` (divergência desde v2.18.0)
- Notificação Google Chat disparava em falha; agora só dispara em sucesso total

## [2.19.1] — 2026-04-08

### Corrigido

- `backlog-update done` (Notion): Responsavel não era preenchido — agora resolve identidade via `notion-get-users self` e inclui no update
- `spec-creator` (Notion): verificação pós-criação agora valida properties obrigatórias (Tipo, Severidade, Fase, Complexidade, Domínio, Impacto, Autor, campos adicionais obrigatórios) além do body; pergunta ao usuário e atualiza via `notion-update-page` se vazio
- `execution-plan`: nova regra explícita — plano pronto = delegar implementação para sub-agents, não implementar no mesmo contexto de planejamento
- `spec-driven`: tabela de fluxo inclui sub-agents para Médio/Grande/Complexo; fluxo RPI expandido para Médio+ com o princípio "quem planejou não implementa — delega"
- `definition-of-done`: nova seção "Entrega" no checklist universal com PR obrigatório (nunca push direto), título Conventional Commits e descrição com link para spec
- `spec-driven`: passo 4 em Pós-implementação — abrir PR, nunca push direto para main

## [2.19.0] — 2026-04-08

### Adicionado

- `/spec --from {url}` agora aceita uso sem ID e Título: ambos são extraídos da fonte (Jira key, título do card) e confirmados com o usuário
- Suporte a **campos adicionais (custom fields)** no Notion: `setup-framework` detecta properties extra no schema e documenta regra de preenchimento + opções de select no CLAUDE.md
- `/spec` lê tabela "Campos adicionais" do CLAUDE.md e preenche campos custom ao criar página no Notion (perguntar, auto: url-from, auto: projeto, ou deixar vazio)
- Campo `Estimativa` agora sempre perguntado (era marcado como opcional)
- `template_id` no `notion-create-pages` documentado como best-effort com fallback automático
- `update-framework` (Cenário A) agora detecta e configura campos adicionais ao criar a seção Notion do zero
- `update-framework` (Cenário B) valida campos adicionais existentes contra o schema da database e alerta sobre opções de select desatualizadas
- Documentação de campos adicionais e problemas comuns em `docs/NOTION_INTEGRATION.md`

## [2.18.0] — 2026-04-08

### Adicionado

- Secao "Worktrees e subagents" ativada com regras concretas (worktree por sessao, isolamento de subagents read-only vs write)
- Secao "Entrega via Pull Request" obrigatoria no CLAUDE.template.md (nunca push direto para main)
- Subsecao "Regra de entrega" em GIT_CONVENTIONS.md
- Decomposicao e paralelismo agora obrigatorios para itens medio+ (antes era opcional)
- Passo 3.1b no setup: .gitignore para artefatos do framework (.claude/worktrees/, .claude/plans/, etc.)
- Pergunta sobre formato de PR no Bloco 5 do setup
- Check de .gitignore na Categoria 5 do update (auditoria de integridade)
- marketplace.json para distribuicao no plugin marketplace

### Corrigido

- marketplace.json adicionado ao MANIFEST.md (faltava entrada)
- Worktrees e subagents promovido de info para medio nas tabelas de auditoria (setup + update)

## [2.17.2] — 2026-04-07

### Corrigido

- Update Fase 3.0 reescrita com instrucoes operacionais concretas (comandos bash, tabela de padroes, procedimento passo-a-passo) — versao anterior era descritiva demais e o Claude nao executava

## [2.17.1] — 2026-04-07

### Corrigido

- Setup: leitura obrigatoria do VERSION do framework para evitar framework-tags com `v0.0.0`
- Setup e Update: filtro por modo spec (Notion/externo) impede criacao de `backlog.md`, `TEMPLATE.md`, `DESIGN_TEMPLATE.md` locais
- Update: limpeza ativa de artefatos locais desnecessarios em modo Notion (backup + remocao automatica)
- Update: remocao de secoes do CLAUDE.md que referenciam backlog local quando projeto usa Notion
- Setup: tabela de arquivos obrigatorios agora distingue por modo (repo vs Notion)

## [2.17.0] — 2026-04-07

### Adicionado

- Suporte a multiplas specs por referencia externa (Fonte): N specs podem referenciar o mesmo card (Jira, Linear, etc.)
- Coluna `Fonte` adicionada ao SPECS_INDEX.template.md com exemplo de N:1

### Corrigido

- Auditoria completa de consistencia: 10 issues resolvidos (docs/README index, SKILLS_MAP, migration sed, template syncs, etc.)
- Migration files nao sao mais contaminados pelo sed de framework-tags durante release

## [2.16.1] — 2026-04-07

### Corrigido

- Todas as referencias a specs/backlog agora respeitam modo Notion (CLAUDE.template.md, spec-driven, CONCEPTUAL_MAP, docs/README)
- Categoria 1 do setup e update diferencia arquivos obrigatorios por modo (repo/Notion/externo)
- verify.sh detecta modo Notion e pula checks de specs locais; avisa sobre arquivos locais desnecessarios
- `/spec` em modo Notion: Pequeno agora cria pagina explicitamente (NAO pula)

## [2.16.0] — 2026-04-07

### Adicionado

- Setup: Fase 5a — verificacao pos-geracao que detecta e corrige automaticamente skills instaladas com exemplos genericos (ex: JS em projeto Go, branches genericas em GIT_CONVENTIONS)
- Update: Fase 3.5 — verificacao pos-aplicacao obrigatoria que compara resultado vs backup e restaura se detectou regressao (ex: elogger substituido por console.log)
- Update: regra absoluta na Fase 3 — arquivos structural NUNCA sao substituidos por cp do source
- Update: backup obrigatorio ANTES de cada merge structural

### Corrigido

- `setup-framework` e `update-framework` nao sao mais copiados para `.claude/skills/` do projeto (sao skills de gestao, ficam em `~/.claude/skills/` ou via plugin)
- MANIFEST atualizado para refletir que skills de gestao nao vao pro projeto

## [2.15.1] — 2026-04-07

### Corrigido

- Setup: `spec-creator` e `backlog-update` adicionados a lista core do Bloco 4 (antes so apareciam em secao separada facil de pular)
- Setup: nota explicita diferenciando `spec-driven` (processo) de `spec-creator` (slash command) — ambas obrigatorias
- Setup: aviso de que skills so ficam disponiveis como slash commands apos nova sessao ou `/clear`
- Setup Notion: nao criar `backlog.md`, `TEMPLATE.md`, `STATE.md` locais — specs e backlog vivem no Notion
- Setup Notion: secao `## Integracao Notion (specs)` no CLAUDE.md marcada como OBRIGATORIA (sem ela, `/spec` cai em modo local)
- Slash command renomeado de `/spec-creator` para `/spec` (consistente com toda a documentacao)
- Update: sincronizado com as mesmas correcoes (spec-driven vs spec-creator, aviso nova sessao)

## [2.15.0] — 2026-04-07

### Adicionado

- Monorepo: modelo de distribuicao de skills/agents L0 (raiz) vs L2 (sub-projeto) com 3 opcoes de organizacao
- Monorepo: CODE_PATTERNS por sub-projeto — mesmo linguagem com padroes diferentes (ex: 2 projetos Go com libs distintas)
- Monorepo: isolamento por sub-projeto para skills, verify.sh, docs e CLAUDE.md L2
- Monorepo: modelo misto para CLAUDE.md L2 — sub-projetos so listam overrides de skills, resto herda da raiz via concatenacao
- Setup: deteccao de stack por sub-projeto e distribuicao condicional de skills/agents
- Update: deteccao de mudancas de stack por sub-projeto e sugestao de migracao de padroes

## [2.14.2] — 2026-04-07

### Documentacao

- Adicionado `/clear` como alternativa a abrir sessao nova no SPEC_DRIVEN_GUIDE, spec-driven skill e CLAUDE.template.md

## [2.14.1] — 2026-04-07

### Corrigido

- Categoria 6 (relevancia): agora obriga gerar sugestao concreta de substituicao antes de perguntar ao usuario — nunca mais reseta campos sem mostrar o que vai ficar no lugar
- Adicionadas regras 9 e 10 ao setup e update: nunca resetar conteudo customizado, sempre perguntar especificamente com opcoes numeradas

## [2.14.0] — 2026-04-07

### Adicionado

- Setup: Fase 1.6 — deteccao automatica de padroes de codigo (logging, error handling, HTTP client, validacao, ORM, config) a partir do codigo-fonte real do projeto
- Setup: Fase 3.6.1 — customizacao de skills (logging, code-quality, security-review) com exemplos baseados nos padroes detectados em vez de exemplos genericos
- Setup/Update: Categoria 6 na auditoria de completude — validacao de relevancia de conteudo:
  - 6.1: Exemplos de codigo incompativeis com a stack (ex: JS em projeto Go)
  - 6.2: Libs e padroes divergentes dos detectados (ex: fmt.Errorf quando projeto usa lib erros)
  - 6.3: Skills e agents irrelevantes para o tipo de projeto (ex: ux-review em backend puro)
  - 6.4: Secoes do CLAUDE.md irrelevantes (ex: Mindset Frontend em API)
  - 6.5: Docs irrelevantes
  - 6.6: Evolucao do projeto — detecta mudancas desde ultimo setup (exclusivo do update)
  - 6.7: Procedimento de remocao completa (arquivo + referencias no CLAUDE.md + verify.sh)
- Update: Fase 0.6 — deteccao de CODE_PATTERNS para validar conteudo existente a cada execucao
- PRD Creator: geracao de diagrama causal (.mmd) e export para ferramentas visuais (Miro, FigJam)
- Bug Investigation: criacao automatica de card no Jira apos investigacao

## [2.13.3] — 2026-04-06

### Corrigido

- Bug report: 5 Whys agora bloqueia respostas rasas e insiste ate 3 tentativas antes de aceitar como incompleto
- Bug report: output agora segue o formato do template de bugs do Notion do time (4 secoes)
- Bug report: fluxo extrai informacoes da mensagem inicial antes de perguntar

## [2.13.0] — 2026-04-06

### Adicionado

- Skill `bug-investigation` (`/bug-report`): investigacao estruturada de bugs para times N2/N3 antes de escalar para engenharia — 10 passos com validacao de sintoma, reproducao, porques encadeados, mapa de impacto e recomendacao para engenharia
- Template `BUG_REPORT_TEMPLATE.md`: template completo para relatorios de bug com todas as secoes de investigacao
- Doc `BUG_INVESTIGATION_PORTABLE_PROMPT.md`: prompt standalone para investigacao de bugs em qualquer LLM (Gemini, OpenAI, Claude)
- PRD Creator: validacao do problema (teste de resolucao — desafia se o problema declarado e sintoma/causa)
- PRD Creator: porques encadeados com minimo 3 niveis por causa (antes era 1 nivel)
- PRD Creator: mapa causal com nos compartilhados, convergencias e causa raiz principal
- PRD Creator: derivacao de "como resolver" encadeada a partir das causas raiz (Como? → Como especificamente? → O que concretamente?)
- PRD Creator: calibracao de escopo que previne PRDs nivel task (<3 acoes = warning)

### Alterado

- PRD Template: secoes Porques e Como Resolver reestruturadas para suportar analise encadeada
- PRD Template: checklist de verificacao pos-conclusao expandido de 4 para 10 itens
- PRD Portable Prompt: espelha todas as mudancas da skill e template
- CLAUDE.template.md: adicionada skill #22 (bug-investigation)
- MANIFEST.md: adicionadas entradas para bug-investigation, BUG_REPORT_TEMPLATE e BUG_INVESTIGATION_PORTABLE_PROMPT

## [2.12.0] — 2026-04-06

### Adicionado

- Skill `execution-plan`: planejamento obrigatorio para itens medios+ com mapa de arquivos, decomposicao em partes, analise de overlap e ordem de execucao
- Agent `dx-audit`: auditoria de developer experience (scripts, configs, docs, hooks)
- Agent `performance-audit`: auditoria de performance (queries, componentes, pool, timeouts)
- Agent `infra-audit`: auditoria de infraestrutura (deploy, Docker, CI/CD, monitoramento)
- Template `backlog-format.md`: especificacao do formato do backlog (colunas, fases, severidade, complexidade)
- Doc `PROTECT_BACKLOG_HOOK.md`: documentacao do hook opcional para proteger backlog de edicao direta
- Secao "Output — concisao obrigatoria" no CLAUDE.template.md (economia de tokens)
- Secao "TDD obrigatorio" no CLAUDE.template.md (red-green-refactor)
- Secao "Execucao por agents — orquestracao" no CLAUDE.template.md (tech lead pattern, checkpoint, delegacao)
- Secao "Testes e coverage" com tabela de targets por camada e modulos criticos
- Tabela de ciclo de vida dos status no SPECS_INDEX.template.md

### Alterado

- Skills no CLAUDE.template.md: de lista numerada para tabela com coluna "Obrigatorio?"
- Agents no CLAUDE.template.md: de lista numerada para tabela com modelo, trigger e obrigatoriedade
- Checklist pre-commit expandido de 3 para 9 itens (coverage, verificacao manual, E2E, docs)
- Verificacao proativa: adicionada regra de validacao de spec contra codigo atual
- Removida secao duplicada de "Regras de codigo"

## [2.11.0] — 2026-04-06

### Adicionado

- Sistema de migrations para atualizacoes manuais entre versoes — como migrations de banco de dados, mas para o framework
- Template de migration (`migrations/MIGRATION_TEMPLATE.md`) e README explicativo
- 7 migrations retroativas cobrindo v2.4.0 ate v2.10.1
- Passo 4 no processo de release: geracao automatica de migration a cada nova versao
- Backlog do framework com analise do ecossistema SDD (`BACKLOG.md`)

## [2.10.1] — 2026-04-03

### Adicionado

- Diagrama de workflow do framework (`docs/WORKFLOW_DIAGRAM.md`) com 7 diagramas ASCII: setup, uso diario, agents, update, ciclo de release, estrategias do MANIFEST e integracao Notion

## [2.10.0] — 2026-04-02

### Corrigido

- Setup e update agora filtram agents/skills pelo perfil do projeto em vez de copiar tudo cegamente
- Update detecta contexto do projeto (stack, DB, frontend, PRD, Notion) na Fase 0.4 antes de propor mudancas
- Agents condicionais (seo-audit, component-audit, product-review) so sao instalados se o perfil bate ou o usuario aceitar
- Skills condicionais (dba-review, ux-review, seo-performance) seguem a mesma logica

## [2.9.0] — 2026-04-02

### Adicionado

- Campos Autor, Responsavel e Concluida em no template de spec e no ciclo de vida
- Resolucao de identidade: Notion user (`notion-get-users self`) no modo Notion, `git config user.name` no modo repo
- Regra sobre campo "Arquivo" no Notion (deixar vazio quando spec vive no Notion)

### Corrigido

- Definition of Done agora preenche Responsavel e Concluida em ao marcar spec como concluida
- Verificacao pos-implementacao inclui checklist para campos de conclusao

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
