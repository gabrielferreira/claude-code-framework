# Changelog

Todas as mudancas relevantes do framework sao documentadas neste arquivo.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [2.51.0] — 2026-05-13

### Adicionado

- **`.claude/conventions/estimation.md` — escala de Estimativa por projeto.** Novo arquivo de convenção que define os valores válidos do campo Estimativa no backlog e nas specs. Cada projeto escolhe o formato (Fibonacci, T-shirt P/M/G, horas, story points etc.) — o framework deixa de impor uma escala única. `/setup-framework` agora inclui o Bloco F6 (wizard de 4 presets: Horas/dias, Fibonacci, T-shirt, Customizar) e a sub-fase 3.4c gera o arquivo com o preset escolhido.
- **`/update-framework` oferece criar `estimation.md` em projetos vindos de v2.50.x.** Auditoria de completude detecta o arquivo ausente (severidade 🟠 alto) e oferece criação via mesmo wizard. Após criado, o arquivo é tratado como `skip` no MANIFEST — nunca sobrescrito em updates futuros.

### Mudado

- **Mapeamento direto Complexidade → Estimativa removido em `spec-creator/SKILL.md`** (modo Notion). Antes: `Pequeno → < 4h | Médio → 1-2 dias | Grande → 1-2 semanas | Complexo → > 2 semanas`. Agora: Estimativa é eixo independente, valor lido da escala definida em `.claude/conventions/estimation.md`. O mapeamento Complexidade → Severidade (`Pequeno → baixa | Médio → media | ...`) **continua intacto**.
- **`skills/spec-driven/README.md`** — tabela de Complexidade perde os thresholds temporais (`1-3h` no Médio, `>3h` no Grande). Critério vira puramente estrutural (nº de tasks, abstração, schema).
- **`skills/backlog-update/SKILL.md` e `specs/backlog-format.md`** — campo Estimativa referencia `.claude/conventions/estimation.md` em vez de listar a escala fixa.
- **Coluna Compl. em `specs/backlog-format.md`** — descrição reescrita sem menções temporais (`1-3h`, `>3h`).

### Migração

- Ver `migrations/v2.50.0-to-v2.51.0.md` para o passo a passo de cada content patch e a oferta de criação do arquivo.

## [2.50.0] — 2026-05-13

### Adicionado

- **`.claude/specs/STATE.md` agora é gitignored por padrão** — adicionada entrada no bloco obrigatório do `.gitignore` distribuído pelo `/setup-framework`. STATE.md é memória pessoal de sessão (não status compartilhado do time), e commitá-lo em projetos multi-dev causava conflito de merge garantido e contaminação de contexto (o Claude do dev A podia agir sobre o "Em andamento" do dev B ao iniciar sessão).
- **`/update-framework` detecta STATE.md trackeado em versões antigas** — nova subseção 1.2b checa `git ls-files .claude/specs/STATE.md`; quando detecta, reporta na categoria 🔧 "Migrações de gitignore" do relatório com os comandos `git rm --cached` para o usuário rodar manualmente (não executa automaticamente para evitar afetar a working tree de outros devs sem coordenação).
- **`/update-framework` faz append no `.gitignore`** — subseção 3.7 garante que `.claude/specs/STATE.md` é appendado ao `.gitignore` do projeto mesmo quando o `git rm --cached` ainda não foi rodado (preparação segura).

### Mudado

- **Regra #6 do `CLAUDE.md` template** (e mirror em `templates-light/`, regra #5) explicita que STATE.md é pessoal por dev (gitignored) e estende o princípio a `.claude/plans/` (já era gitignored desde versões anteriores, mas a regra não estava documentada).
- **MANIFEST.md** descreve a nova estratégia de STATE.md como `manual + gitignored — pessoal por dev, nunca commitado`.

## [2.49.3] — 2026-04-17

### Corrigido

- **URLs do repositório** em `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `docs/SETUP_GUIDE.md`, `README.md`, `CONTRIBUTING.md` e `scripts/install-skills.sh` (source + templates sincronizados) agora apontam para `github.com/gabrielferreira/claude-code-framework`. Campos `author`/`owner.name` atualizados para "Gabriel Ferreira".
- **Ortografia de "Estratégia"** (com acento) em headers de tabela e seções: `MANIFEST.md`, `docs/MIGRATION_GUIDE.md` (source + template), `specs/DESIGN_TEMPLATE.md` (source + template), `.claude/plans/MO9-light-edition.md`.
- **Exemplos de detecção de lib Go** em auxiliares internos de skills (`AUDIT_DETAILS.md`, `EXAMPLES.md`, `MONOREPO_DETAILS.md`) neutralizados para `github.com/your-org/backend-libs` — placeholder genérico apropriado pra qualquer projeto downstream.

### Interno (dev do framework)

- Criados `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1, em português), `SECURITY.md` (canal privado de relato de vulnerabilidades via GitHub Security Advisory) e `.github/ISSUE_TEMPLATE/` (bug_report, feature_request, config.yml).
- `scripts/release.sh` agora inclui no output final o comando `gh release create` com extração automática das notas do CHANGELOG — garante que próximas releases saiam com GitHub Release visível desde o início.
- `CLAUDE.md` passo 9 no fluxo de release descrevendo o mesmo.
- Branch protection aplicada na `main`: PR review obrigatório, sem force-push, sem delete, status checks strict. Secret scanning + push protection + Discussions habilitados.
- 70 GitHub Releases retroativas criadas (antes apenas 3 das 73 tags tinham Release associado).

## [2.49.2] — 2026-04-16

### Corrigido

- **`validate-structure.sh` no macOS:** força locale UTF-8 (`en_US.UTF-8` ou `C.UTF-8`) no topo do script para que o BSD grep interprete `Ã` em "NÃO" como um caractere único. Sob locale `C`, 23 skills eram reportadas como faltando a seção "Quando NÃO usar" mesmo tendo-a — falso negativo que quebrava validação local pré-commit.
- **`validate-tags.sh` ignora `.claude/worktrees/` e `.git/`:** validação falhava em 500+ arquivos quando havia worktrees de sessões antigas com tags de versões anteriores. Worktrees são diretórios temporários de desenvolvimento, não devem entrar na validação de tags.

### Interno (dev do framework)

- **TQ10 — item-specs retroativas:** reconstruídas `DF13.md` (Discovery Routing + `/quick`, v2.36.0) e `TQ5.md` (seções obrigatórias nas skills, v2.31.0) em `.claude/item-specs/done/` a partir de CHANGELOG + git log + estado atual. `INDEX.md` fecha os 2 orphans.
- **OP4 — `scripts/release.sh`:** automatiza bump mecânico de release (VERSION + plugin.json + marketplace.json, sed de framework-tags excluindo `migrations/`, sincronia de templates, `check-sync.sh`, scaffold de migration). Commit/tag/push continuam manuais. `CLAUDE.md` (seção "Versionamento e release") prefere o script; passos manuais viram fallback. Não é distribuído para projetos.
- **Anti-padrões de auditoria:** `.claude/AUDIT_ANTIPATTERNS.md` registra os falsos positivos da auditoria de 2026-04-16 + teste obrigatório do "segundo arquivo" antes de reportar qualquer achado. Seção `## Auditorias` no `CLAUDE.md` aponta pro doc.

## [2.49.1] — 2026-04-16

### Corrigido

- **CI: marcador framework-mode: light faltando** no `templates-light/docs/README.md` — check-sync falhava após atualização de docs.

## [2.49.0] — 2026-04-16

### Melhorado

- **Instrução compacta (PF7):** setup SKILL.md reduzido de 2.495 → 1.238 linhas (-50%), update SKILL.md de 1.257 → 564 linhas (-55%). Conteúdo condicional (monorepo, Notion, auditoria, exemplos) extraído para arquivos auxiliares carregados sob demanda. Zero perda de funcionalidade — todos os cenários (L0/L2/L3+, single-repo, monorepo A-E, Notion, PRD, light/full) preservados nos auxiliares.

### Housekeeping

- Descartados SW6 (já implementado via specs/done + SW9) e DF5 (decisão tomada no SW2)
- Reclassificado TQ7 como OP3 (Operações — não é teste)

## [2.48.1] — 2026-04-16

### Corrigido

- **CI pula migration check em patches:** releases patch (x.y.Z onde Z>0) não exigem migration file. Corrige falha no CI desde v2.47.1 que bloqueava webhook de notificação.

## [2.48.0] — 2026-04-16

### Adicionado

- **PR draft automático com execution plan:** spec-driven fase Plan abre PR draft com o execution plan como primeiro commit. Implementação vai no mesmo PR. Artefatos de trabalho (plan, research) deletados antes de finalizar. `/pr` detecta PR draft existente via `gh pr view`, atualiza body e marca ready for review.
- **Pós-implementação sugere /pr:** após DoD completo, o spec-driven sugere ao dev executar `/pr` para finalizar o PR draft (confirmação, não automático).

## [2.47.1] — 2026-04-16

### Corrigido

- **Hook verify.sh robusto:** detecta `--changed` se disponível, não depende de jq (usa printf), valida que o hook funciona após configurar.
- **Hook em settings.json:** hook agora configurado em `.claude/settings.json` (versionado, compartilhado) em vez de `settings.local.json` (gitignored). Todos os devs recebem o hook automaticamente.
- **STATE.md resetado ao concluir:** instrução explícita de resetar para estado vazio (sem item ativo) após fechar item.
- **Checkboxes e status obrigatórios:** pós-implementação exige tool calls reais (Read+Edit+Bash) para marcar checkboxes e transicionar status. "Já fiz" sem tool call = inválido.
- **verify.sh gate reforçado no CLAUDE.md:** "EXECUTAR DE FATO (Bash tool), não apenas mencionar."

## [2.47.0] — 2026-04-16

### Adicionado

- **Performance: defaults inteligentes (PF1):** Fase 1 gera DETECTION_SUMMARY, Fase 1.8 apresenta tudo detectado e pede confirmação. "Sim" pula Fase 2 inteira (~15 min economizados).
- **Performance: perguntas agrupadas (PF2):** Fase 2 usa 5 AskUserQuestion com options/multiSelect em vez de 20-30 chamadas texto livre.
- **Performance: CODE_PATTERNS paralelo (PF3):** instrução explícita para ler 10-15 arquivos representativos em paralelo no setup e update.
- **Performance: geração batch (PF4):** templates copiados em batch via bash, placeholders substituídos via sed global, skills customizadas em paralelo.
- **Performance: structural merge otimizado (PF5):** receita mecânica em 5 passos com short-circuit (tag igual = skip, ~80% economia em update típico).
- **Performance: auditoria seletiva (PF6):** guards explícitos nas categorias 6-8 (skip se não aplicável).

## [2.46.2] — 2026-04-16

### Corrigido

- **Update-framework usa templates-light para merge:** projetos light agora recebem merge structural do template correto (light) em vez do full, evitando adição de seções full-only.
- **Upgrade transformação light→full:** CLAUDE.md agora é transformado (preserva dados, gera full) em vez de merge aditivo que não expandia seções condensadas.
- **marketplace.json versão stale:** sincronizado com VERSION (estava em 2.18.0). Processo de release e check-sync.sh agora validam marketplace.json.
- **CONCEPTUAL_MAP links quebrados:** display text corrigido para paths reais.
- **MIGRATION_GUIDE skill inexistente:** referência a `syntax-check` removida.
- **check-sync.sh:** valida marker `framework-mode: light` em templates-light/ e versão de plugin.json/marketplace.json contra VERSION.
- **SKILLS_MAP:** `/upgrade-framework` adicionado.
- **SETUP_GUIDE:** nova seção light vs full com tabela comparativa.
- **SPEC_DRIVEN_GUIDE:** delta markers (brownfield) documentados.
- **Setup re-run:** detecção de modo antes da pergunta (não re-pergunta).
- **Setup conditional skills:** critérios algorítmicos de detecção documentados (DB, frontend, frontend público).
- **Update 0.4:** grep pattern exato para detecção de modo documentado.
- **WORKFLOW_DIAGRAM:** escolha light/full na Fase 0.
- **MANIFEST Renames:** coluna Tier adicionada.
- **templates-light framework-file:** prefixo `light:` para evitar falso positivo no check-sync.
- **templates-light markers:** `framework-mode: light` adicionado em STATE.md, backlog.md, TEMPLATE.md.

## [2.46.1] — 2026-04-15

### Corrigido

- **validate-tags.sh ignora code fences:** tags dentro de blocos ``` (incluindo indentados) não são mais validados. Elimina falsos positivos em migrations antigas.
- **Tags corrompidos em migrations v2.29→v2.34:** exemplos de sed dentro de code fences restaurados para versões corretas. Framework-tags reais removidos de migrations históricas (não deveriam ter).
- **Errata na migration v2.45→v2.46:** nota sobre impacto em projetos que aplicaram migrations manuais corrompidas.
- **Seção de atualização no QUICK_START.md:** instrui dev a atualizar a skill local antes de rodar `/update-framework`.

## [2.46.0] — 2026-04-15

### Adicionado

- **Framework Light Edition (MO9):** modo dual light/full no setup. MANIFEST.md com coluna Tier (core/full/conditional). Setup pergunta modo, questionário simplificado (3-4 perguntas no light vs 15-20 no full), filtro por tier, templates-light/ (~10 arquivos simplificados). Update detecta modo e filtra por tier (skip silencioso para full-tier ausente). Nova skill `/upgrade-framework` converte light→full aditivamente. check-sync.sh estendido com seção D para validar templates-light/.

## [2.45.0] — 2026-04-15

### Adicionado

- **Git isolation por task (MO4):** task-runner cria branch isolada `task/{spec-id}-t{index}` antes de cada task (opt-in via `git_isolation: true` no briefing). Diff resumido ao concluir, merge só com confirmação humana. context-fresh pergunta no início da sessão.

## [2.44.0] — 2026-04-15

### Adicionado

- **Deduplicação de artefatos entre camadas em monorepo (MR6):** novo passo E no setup cenário B detecta skills, agents, docs de processo, verify.sh e TEMPLATE.md idênticos entre sub-projetos e sugere promoção para nível superior (L3→L2→L0). Nova Categoria 8 no update faz auditoria periódica. Interseção inteligente (todos idênticos, maioria, par coincidente) e promoção multi-nível. Docs de conteúdo nunca candidatos.

## [2.43.0] — 2026-04-15

### Adicionado

- **Delta markers para brownfield (SW1):** marcadores `[ADDED]`/`[MODIFIED]`/`[REMOVED]` por RF no template de spec. Passo 4c no spec-creator pergunta se brownfield e orienta classificação. Instrução delta no spec-driven para localizar código antes de `[MODIFIED]` e listar impactos antes de `[REMOVED]`.
- **SPECS_INDEX archive (SW9):** novo `SPECS_INDEX_ARCHIVE.md` recebe specs concluídas e descontinuadas. SPECS_INDEX agora só contém specs ativas. Setup cria o archive, update detecta ausência e oferece migração de specs concluídas existentes. spec-creator verifica duplicatas no archive.
- **Docs por sub-projeto em monorepo (MR5):** nova subsection `### Documentação por sub-projeto` no template `## Monorepo`. Setup gera docs relevantes por sub-projeto (`{subdir}/docs/`) e preenche tabela de referência no CLAUDE.md L0. Update detecta sub-projetos sem docs.
- **Diretrizes de implementação no CLAUDE.md:** nova seção com princípios de design — 3 cenários obrigatórios (greenfield/re-run/update), dual-mode repo+Notion, monorepo sub-níveis e submodules, backward compatibility, releases via PR.

## [2.42.0] — 2026-04-15

### Adicionado

- **Setup-framework — detecção completa de monorepo (MR2):** bullet explícito na Fase 3.2 para preencher `## Monorepo` com exemplo de output, entrada condicional na tabela de auditoria de seções obrigatórias, scan ampliado para 2 níveis de profundidade, detecção de `.gitmodules` e tratamento de git submodules.
- **Spec-creator — awareness monorepo (MR3):** novo Passo 0d detecta `## Monorepo`, pergunta sub-projeto afetado, respeita modelo de distribuição (centralizado/distribuído/Notion). Bootstrap, path, header e SPECS_INDEX ajustados condicionalmente. Variante monorepo no SPECS_INDEX.template.md. Aviso para git submodules.
- **Backlog-update — awareness monorepo (MR4):** novo Passo 0a com mesmo pattern do MR3. Centralizado: subsecções por sub-projeto em Pendentes. Distribuído: opera no backlog.md do sub-projeto. Notion: property Sub-projeto. Opção de mover item entre sub-projetos.

## [2.41.0] — 2026-04-15

### Alterado

- **CLAUDE.template.md — linguagem comportamental inspirada em Karpathy Guidelines:** nova regra "Não assumir. Não esconder confusão." nas regras de operação. Princípios "Simplicidade primeiro" e "Mudanças cirúrgicas" com testes de sanidade na seção Regras de código. "Execução orientada por critérios verificáveis" na decomposição. Linguagem mais direta nas regras de delegação.

### Referência

- **Karpathy Guidelines** registrado em `references/ECOSYSTEM.md` como referência do ecossistema.

## [2.40.0] — 2026-04-15

### Adicionado

- **Skill `/onboarding`:** slash command que gera guia contextualizado do fluxo de trabalho para devs novos no projeto. Lê CLAUDE.md, PROJECT_CONTEXT.md, SETUP_REPORT.md e SKILLS_MAP para montar output com comandos reais, skills instaladas, agents disponíveis e fluxo adaptado ao que foi configurado. Output no chat (não cria arquivo).

## [2.39.0] — 2026-04-15

### Adicionado

- **Seção `## Monorepo` no CLAUDE.template.md (MR1):** fonte de verdade declarativa para projetos monorepo. 3 subsections: `### Estrutura` (tabela de sub-projetos), `### Distribuição de framework` (skills, agents, specs, verify.sh), `### Convenções de camada` (L0/L2/L3+). Seção opcional — single-repo não a usa.
- **Referências no setup-framework:** seção `## Monorepo` definida como output target canônico, com breadcrumbs para MR2-MR4.
- **Referências no update-framework:** detecção de seção ausente/incompleta em monorepos existentes, fallback para SETUP_REPORT.md.
- **Docs atualizados:** SETUP_GUIDE (exemplos de monorepo mostram seção no output), SPEC_DRIVEN_GUIDE (fonte de verdade para specs em monorepos), WORKFLOW_DIAGRAM (artefato no bloco de setup).

## [2.38.0] — 2026-04-10

### Adicionado

- **Skill `/pr`:** preenche template de PR com contexto de spec + diff e abre via `gh pr create` com confirmação. Detecta spec via STATE.md, branch name ou arquivos modificados. Suporta `--base` e `--draft`.
- **PR template distribuído:** `.github/pull_request_template.md` distribuído pelo setup-framework (strategy: structural). Seções: O que muda, Por quê, Como testar, Checklist.

## [2.37.3] — 2026-04-10

### Alterado

- **Posicionamento do framework:** reposicionado de "spec-driven" / "framework de documentação" para **harness engineering framework**. Spec-driven continua como skill — reposicionado de "o que o framework é" para "entry point do fluxo de conhecimento". Atualizado README, plugin.json, QUICK_START, SPEC_DRIVEN_GUIDE, SKILLS_MAP, SKILLS_GUIDE, CONCEPTUAL_MAP e SETUP_GUIDE.

## [2.37.2] — 2026-04-10

### Corrigido

- **Skill `/quick` — seção Checklist:** adicionada seção `## Checklist` exigida pelo `validate-structure.sh`. Sem ela o CI falhava.

## [2.37.1] — 2026-04-10

### Corrigido

- **Setup/Update — substituição de `{NOME_DO_PROJETO}`:** adicionado passo explícito (seção 3.6.2) para substituir `{NOME_DO_PROJETO}` em todos os arquivos copiados. Projetos ficavam com placeholder literal nos títulos de skills, docs e specs.

## [2.37.0] — 2026-04-10

### Adicionado

- **SA4 — Skill `/discuss`:** scout no codebase + identificação automática de gray areas + deep-dive guiado + spec gerada ao final. Dual-mode (repo + Notion), suporte a `--from` (Jira, Notion, Google Docs, Confluence), monorepo-aware. Complementa `/spec` como passo anterior para features com ambiguidades, domínio novo ou escopo vago.

## [2.36.0] — 2026-04-10

### Adicionado

- **DF13 — Slash command `/quick`:** fast-path para correções triviais (typo, bump, config, fix de 1-2 linhas sem lógica de negócio). Valida critérios, segue fluxo simplificado (implementar → testar → verify.sh → commit → PR) sem spec, sem STATE.md, sem DoD completo. Se a mudança complicou, redireciona para `/spec`. Integrado como item 1 na tabela de skills do CLAUDE.template. Completa o DF13 (Discovery Routing).

## [2.35.0] — 2026-04-10

### Removido

- **Skills eliminadas:** `syntax-check` (100% coberto por `code-quality`) e `performance-profiling` (~90% coberto por agent `performance-audit`). Referências atualizadas em todas as skills que os mencionavam.
- **Agent eliminado:** `plan-checker` (absorvido pela seção 7 do `spec-validator`).
- **CLAUDE.template:** sub-tabela "Agents custom deste projeto" removida (duplicava tabela principal de agents). Coluna "Modelo" removida da tabela de agents (modelo vive no frontmatter). Seção Worktrees compactada.
- **DoD:** 9 checklists tipo-específicos substituídos por `{Adaptar}` com exemplos. Mantidos: universal + feature grande.
- **Tríade spec-driven/execution-plan:** removida repetição de protocolo de waves e regras de despacho (fonte de verdade é `context-fresh`).
- **Overlap docs:** fluxo duplicado removido do SKILLS_GUIDE (já existe no SKILLS_MAP). Tabela de sizing removida do CONCEPTUAL_MAP (já existe no SPEC_DRIVEN_GUIDE).

### Adicionado

- **DF13 — Discovery Routing (fast-path):** gate de triagem antes do spec-driven classifica trabalho incoming em quick task (typo, bump, config → direto sem spec), spec única (fluxo normal) ou multi-spec (→ `/prd`). DoD simplificado para quick tasks: verify.sh + Conventional Commits + PR.

### Corrigido

- **"Agents são read-only":** regra reformulada para separar agents de auditoria (read-only) vs agents de execução (task-runner, refactor-agent operam em worktree).
- **TDD obrigatório:** `{Adaptar}` clarificado — TDD é default, só mudar se o projeto já define política diferente.
- **Coverage 100%:** defaults mudados de `100%/95%` para `{X}%/{Y}%` adaptável por módulo.
- **Default de execução:** invertido — implementar direto é o default, delegar via sub-agents é a opção.
- **STATE.md:** simplificado de 7 para 3 seções (Em andamento, Próximos passos, Notas). Estratégia mudada de `skip` para `manual` no MANIFEST para que update mostre diff da estrutura nova.
- **Contagens no docs-sync:** seção tornada opcional.

### Backlog

- SW3 (EARS) e OP1 (monitoramento ecossistema) descartados
- DF4 descartado junto com SW3
- SW10 movido para decisões futuras
- DF13 promovido para pendente (gatilho CE5 atingido)

## [2.34.0] — 2026-04-10

### Adicionado

- **AU4 — Skill `/resume` como slash command:** skill de retomada convertida de README.md (passiva) para SKILL.md (`user_invocable: true`), permitindo invocação direta via `/resume` após crash/timeout. Protocolo de 4 passos permanece inalterado.

- **Lógica de rename no update-framework:** nova seção "Renames" no MANIFEST.md para declarar renames explícitos entre versões. Nova Fase 3.1b no update-framework que detecta renames, migra customizações via merge structural e remove o arquivo antigo. Projetos existentes com `resume/README.md` serão migrados automaticamente para `resume/SKILL.md` preservando customizações.

## [2.33.0] — 2026-04-10

### Adicionado

- **SA3 — Agent `debugger`:** agent read-only que coleta contexto de falha automaticamente (erro, histórico git, STATE.md, ambiente) e produz diagnóstico estruturado com hipóteses ranqueadas, confiança global e próximos passos acionáveis. Inclui correção oportunística: `plan-checker` adicionado às listas de instalação/auditoria de setup e update onde estava ausente.

- **Exemplos de C#, Dart e Rust em skills e agents:** skills e agents distribuídos agora incluem exemplos concretos para stacks C#, Dart e Rust além dos já existentes.

## [2.32.0] — 2026-04-10

### Adicionado

- **SKILLS_GUIDE.md — Catálogo descritivo de todas as skills:** novo doc distribuído para projetos com descrição de cada uma das 25 skills do framework (o que faz, quando usar, o que produz). Organizado por fluxo principal + categoria funcional. Inclui seção `## Skills customizadas do projeto` para o projeto adicionar skills próprias. Estratégia `structural` — setup instala na primeira vez; update sugere adição/remoção de seções quando skills mudam. Setup e update agora verificam presença do arquivo na auditoria de completude.

## [2.31.0] — 2026-04-10

### Adicionado

- **AU4 — Skill `/resume`:** nova skill para recuperação de sessão após crash, timeout ou context limit. Lê `STATE.md` e execution-plan, apresenta resumo do estado anterior e confirma antes de continuar. Protocolo de 4 passos: ler STATE.md → ler execution-plan → apresentar resumo → confirmar antes de retomar.

- **SW7 — Seção `## Restrições inegociáveis` no `PROJECT_CONTEXT.md`:** nova seção para documentar decisões arquiteturais fixas (stack de banco, auth, infra, cobertura mínima) que toda spec e execution-plan deve respeitar. Inclui instrução de uso e exemplos comuns. `/update-framework` detecta a ausência e oferece adicionar via structural merge (severidade 🟡 médio).

- **TQ5 — Seções obrigatórias nas 16 skills distribuídas:** todas as skills agora têm `Quando usar`, `Quando NÃO usar`, `Checklist` e `Regras`. O `validate-structure.sh` agora falha (hard fail) se qualquer skill distribuída estiver sem essas seções — não é mais aviso não-bloqueante.

- **SW7 — `### Passo 0a — Verificar restrições inegociáveis` no `spec-creator`:** a skill `/spec` agora verifica, antes de criar a spec, se o `PROJECT_CONTEXT.md` tem a seção `## Restrições inegociáveis`. Em caso de conflito, a skill escala ao usuário antes de prosseguir.

## [2.30.0] — 2026-04-09

### Modificado

- **OP2 — Distribuição mais limpa**: `setup-framework` não distribui mais templates redundantes (`CLAUDE.template.md`, `SPECS_INDEX.template.md`, `MIGRATION_TEMPLATE.md`) nem migrations históricas para projetos novos. `update-framework` distribui apenas migrations do gap atual (versão instalada → nova versão) e remove migrations antigas do projeto automaticamente.

## [2.29.0] — 2026-04-09

### Adicionado

- **AU1 — Agent `stuck-detector`:** sub-agente de diagnóstico invocado quando a sessão principal detecta um loop de retry sem progresso. Analisa histórico de tentativas, identifica causa raiz (5 categorias: bloqueio externo, ambiguidade, limite técnico, estado corrompido, loop lógico) e propõe caminhos de resolução concretos. Read-only — apenas diagnostica, não implementa.
  - Protocolo de detecção integrado à skill `context-fresh`: após 2 tentativas sem progresso mensurável, o orquestrador invoca o stuck-detector antes de tentar novamente
  - Gatilhos de loop: tool denied 2x no mesmo passo, output idêntico em iterações consecutivas, N tentativas sem mudança de estado
  - Output estruturado: categoria, evidências, diagnóstico e 3 opções de resolução (escalar, contornar, redefinir)

- **SA2 — Agent `plan-checker`:** valida cobertura do execution-plan contra RFs e critérios de aceitação da spec antes de iniciar implementação. Detecta lacunas entre spec→plano que causariam retrabalho. Invocado após gerar execution-plan, antes de despachar task-runners.

## [2.28.0] — 2026-04-09

### Adicionado

- **SA1 — Skill `/map-codebase`:** análise paralela de codebase em 4 dimensões (stack tecnológico, arquitetura, convenções de código, concerns ativos) com confidence level por dimensão
  - Modos: sem flag (exibe na conversa), `--save` (persiste em `.claude/CODEBASE_MAP.md`), `--quick` (resumo executivo)
  - Princípio central: `Detecção → Especialização → Fallback genérico` — detecta stack antes de aplicar heurísticas
  - Guardrails: read-only, max 30 arquivos/dimensão, nunca entra em `node_modules/vendor/dist/build/`
  - Fallback sequencial quando Agent tool indisponível
  - Alimenta `PROJECT_CONTEXT.md` com confirmação obrigatória (nunca aplica automaticamente)
  - Integração com `/discuss`, `execution-plan` e `spec-creator`

## [2.27.0] — 2026-04-09

### Adicionado

- **`marketplace.json` distribuído para projetos:** arquivo `marketplace.json` agora incluído no template do setup — projetos que rodam `/setup-framework` ou `/update-framework` recebem o arquivo em `.claude-plugin/marketplace.json`

### Corrigido

- **Classificação Pequeno:** critério `<30min` substituído por critérios estruturais (`sem nova abstração, sem mudança de schema, sem regra de negócio nova`) — tempo estimado não é critério confiável para classificação de complexidade. Atualizado em `spec-creator`, `spec-driven`, `execution-plan`, `prd-creator`, `CLAUDE.template.md`, `specs/backlog-format.md` e docs relacionados

## [2.26.0] — 2026-04-09

### Adicionado

- **Execution-plan persistido em `{id}-plan.md`:**
  - `execution-plan`: regra 1 muda de "vive na conversa" para salvar obrigatoriamente em `.claude/specs/{id}-plan.md` com formato e template definidos
  - `spec-driven`: gate "aprovada → em andamento" exige `{id}-plan.md` no disco (Médio+) e `{id}-research.md` (Grande/Complexo) — artefatos verificáveis, não instrucionais
  - `definition-of-done`: novo check de verificação da implementação contra o plan salvo; artefatos de trabalho (`{id}-research.md` e `{id}-plan.md`) deletados na fase done
  - `CLAUDE.template.md`: enforcement explícito — "se o arquivo não existe no disco, NÃO iniciar implementação"
  - `docs/SPEC_DRIVEN_GUIDE.md`: nova seção "Lifecycle com artefatos persistidos" documentando fluxo completo com pausa natural entre plan e execute, tabela de ciclo de vida dos artefatos

- **Checklist de release melhorado no CLAUDE.md:**
  - Passo 3 (novo): copiar `plugin.json` para template após bump
  - Passo 5 (novo): sincronizar templates após atualizar tags + rodar `check-sync.sh`

## [2.25.0] — 2026-04-09

### Adicionado

- **CE4 — Research phase:**
  - `skills/research/README.md`: nova skill com protocolo estruturado de investigação antes do planning (6 eixos: stack, código existente, patterns de reuso, dependências, riscos, gaps de conhecimento)
  - Formato de saída `{id}-research.md` com seções padronizadas (achados, tabelas de código/dependências/riscos, decisões sugeridas)
  - Exemplo concreto: sistema de notificações em projeto Node.js + PostgreSQL
  - Integração com spec-driven (fase research referencia a skill) e execution-plan (achados alimentam o plan)
  - CLAUDE.template.md: skill #2 na tabela, ordem de precedência atualizada com research
  - Docs atualizados: SKILLS_MAP, WORKFLOW_DIAGRAM, SPEC_DRIVEN_GUIDE, CONCEPTUAL_MAP

- **CE2 — Waves paralelas:**
  - Terminologia unificada: "Fase N" → "Wave N" na ordem de execução (disambigua de "fase" do lifecycle research/plan/execute/verify)
  - `execution-plan`: wave derivation explícito com algoritmo (Wave 1 = sem deps, Wave 2 = deps em Wave 1, etc.) e conexão com context-fresh
  - `specs/TEMPLATE.md`: seção "Ordem de execução (waves)" com exemplos Wave 1/2/3
  - Todos os docs e exemplos alinhados com nova terminologia

### Corrigido

- **Ortografia:** "Parallelizável" → "Paralelizável" (português correto, 1 L) em 14 arquivos

## [2.24.1] — 2026-04-09

### Corrigido

- **Complexidade com emojis no Notion:** options da database agora incluem prefixo emoji (⚪ Pequeno, 🔵 Médio, 🟣 Grande, ⬛ Complexo) — alinhado com framework docs
- **Skills atualizadas para novos nomes:** `spec-creator`, `backlog-update` e `prd-creator` usam os valores com emoji ao setar `Complexidade` no Notion
- **SETUP_GUIDE atualizado:** tabela de templates e propriedades recomendadas com emojis de complexidade

## [2.24.0] — 2026-04-09

### Adicionado

- **CE3+SW2 — State machine e spec gates:**
  - `specs/STATE.md`: nova seção "Execução ativa" com fase atual (research/plan/execute/verify), entry/exit criteria e log de transições
  - `skills/spec-driven`: fluxo RPI formalizado como state machine com tabela de fases por tamanho (Pequeno/Médio/Grande/Complexo)
  - `skills/spec-driven`: gates de transição de status com critérios explícitos (rascunho→aprovada→em andamento→concluída)
  - `skills/definition-of-done`: checks de fase verify, log de transições e limpeza ao done

- **CE1+SW5 — Context-fresh execution e task graph:**
  - `agents/task-runner.md`: novo agent para execução isolada de tasks com contexto limpo (worktree: true, model: sonnet)
  - `skills/context-fresh/README.md`: protocolo de orquestração — waves de execução, briefing template, completion log, regras de falha
  - `specs/TEMPLATE.md`: seção "Grafo de dependências" com colunas Task/Depende de/Arquivos/Tipo/Paralelizável
  - `skills/execution-plan`: referências ao grafo da spec e protocolo context-fresh
  - `skills/spec-creator`: task graph obrigatório para Grande/Complexo (repo + Notion mode)

- **Documentação atualizada:**
  - `CLAUDE.template.md`: skill #3 (context-fresh), agent #14 (task-runner), worktrees section, ordem de precedência
  - `docs/SKILLS_MAP.md`: context-fresh no fluxo principal e tabela de dependências
  - `docs/WORKFLOW_DIAGRAM.md`: task-runner e 3 agents faltantes na tabela
  - `docs/SPEC_EXAMPLE.md`: breakdown de tasks atualizado com formato Grafo de dependências
  - `setup-framework` e `update-framework`: listas hardcoded de agents/skills atualizadas

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
