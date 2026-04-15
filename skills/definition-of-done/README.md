<!-- framework-tag: v2.42.0 framework-file: skills/definition-of-done/README.md -->
# Skill: Definition of Done — {NOME_DO_PROJETO}

> Use esta skill ANTES de finalizar qualquer entrega (feature, bugfix, refactor).
> Nenhuma entrega está pronta até que todos os itens aplicáveis estejam marcados.

## Quando usar

- Antes de finalizar qualquer entrega (feature, bugfix, refatoração)
- Ao abrir PR — verificar todos os itens aplicáveis antes de solicitar review
- Ao concluir item do backlog e mover spec para `done/`

## Quando NÃO usar

- Para commits intermediários em branch (não é entrega final)
- Para WIP (work in progress) — aguardar a entrega estar completa
- Para revisão de código de terceiros — este checklist é para quem implementa

## Quick tasks (fast-path)

Para quick tasks (typo, bump de dependência, ajuste de mensagem/config, fix trivial sem lógica de negócio nova), o DoD é simplificado:

- [ ] `bash scripts/verify.sh` passa sem erros
- [ ] Commit segue Conventional Commits
- [ ] PR aberto (não push direto para main)

Sem spec, sem STATE.md, sem checklist completo abaixo. Se a mudança toca lógica de negócio, não é quick task — usar o checklist universal.

## Checklist universal (toda entrega não-trivial)

O checklist tem duas partes: o que a **máquina verifica** (verify.sh) e o que precisa de **inteligência** (Claude). Sem duplicação — cada item existe em um lugar só.

### Verificação automatizada (máquina)
- [ ] `bash scripts/verify.sh` passa sem erros

> O verify.sh cobre: testes passam, console.log, test.skip/only, contagens nos docs, prepared statements, secrets hardcoded, OWASP checks mecânicos, specs indexadas. Se o verify.sh passa, esses itens estão ok — não precisa verificar manualmente.

### Planejamento (inteligência)

- [ ] Spec existe para este item (light para Pequeno, completa para Médio+)
- [ ] **Se Grande/Complexo:** `{id}-research.md` existe (ou existiu — pode já ter sido absorvido pela spec)
- [ ] **Se Médio+:** `{id}-plan.md` existe em `.claude/specs/` — plano na conversa ou mental não conta
- [ ] **Se Médio+:** verificar implementação contra o plan — cada parte do plan foi entregue? Waves foram respeitadas?
- [ ] **Se Médio+ e projeto usa sub-agents:** implementação delegada a sub-agents (sessão principal não implementou direto)
- [ ] **Se delegou via context-fresh:** completion log preenchido para todas as tasks
- [ ] STATE.md "Em andamento" está na fase `verify` (não pular direto para done)

### Testes — cobertura e qualidade (inteligência)

{Se o projeto usa TDD/testes (ver CLAUDE.md). Pular se testes não se aplicam.}

O verify.sh confirma que testes passam, mas não sabe se os **testes certos** existem. Isso precisa de julgamento:

- [ ] Toda nova feature tem testes (tipo correto — ver skill `testing` para pirâmide)
- [ ] Todo bugfix tem teste que reproduz o bug (TDD reverso)
- [ ] Branches de erro cobertos (não só happy path)
- [ ] Golden tests atualizados com review do diff (se aplicável)

### Segurança — decisões de design (inteligência)

O verify.sh pega patterns mecânicos (secrets, SQL concat), mas não avalia **decisões de segurança**:

- [ ] Endpoints novos têm auth middleware — sem auth = justificativa documentada
- [ ] Ownership check: ID do recurso vem do JWT/session, não do body (IDOR)
- [ ] Dados sensíveis removidos das respostas
- [ ] Se mudança tocou em segurança e o projeto tem agent `security-audit`: consultá-lo

### Documentação (inteligência)
- [ ] `CLAUDE.md` atualizado se houve mudança de regra, convenção ou estrutura
- [ ] Docs específicos atualizados se a feature os afeta (ver skill `docs-sync`)

### Reports (se testes foram adicionados/modificados)
- [ ] `bash scripts/reports.sh` executado (se existir)

### Commits
- [ ] Commits seguem Conventional Commits
- [ ] Commits atômicos — cada commit faz exatamente uma coisa

### Entrega
- [ ] **Abrir PR** para `main` (ou branch de integração) — nunca push direto
- [ ] Título do PR segue Conventional Commits
- [ ] Descrição do PR inclui contexto da mudança e link/referência para a spec

## Feature grande ou complexa (com breakdown de tasks)

Tudo do checklist universal, mais:
- [ ] Design doc existe e tem status `implementado` (se classificada como Grande/Complexo)
- [ ] Decisões arquiteturais registradas na spec ou design doc
- [ ] Todas as tasks do breakdown concluídas e marcadas
- [ ] Tasks `[P]` integradas e testadas em conjunto (não só isoladamente)
- [ ] `STATE.md` atualizado: "Em andamento" limpo, próximos passos e notas atualizados
- [ ] Status da spec transicionou seguindo os gates (não pulou etapas — ver skill spec-driven)
- [ ] Nenhuma mudança fora do escopo da task foi incluída (scope guardrail)
- [ ] Design doc movido junto com spec para `done/` (se aplicável)
- [ ] **Artefatos de trabalho deletados:** `{id}-research.md` e `{id}-plan.md` removidos de `.claude/specs/`

## Checklists por tipo de entrega

Os checklists acima (universal + feature grande) cobrem o caso mais complexo. Para tipos específicos, adicionar checks relevantes ao projeto:

{Adaptar: criar seções para os tipos de entrega relevantes ao projeto. Exemplos de tipos e checks típicos:
- Nova feature: docs do projeto, guia/FAQ, E2E para fluxo crítico
- Bugfix: teste reproduz bug ANTES do fix, root cause no commit
- Novo endpoint: OWASP, testes de integração (200/400/401/403/404/500), rate limit, docs API
- Auth/permissões: timing-safe, anti-enumeração, token rotation, bloqueio progressivo
- Webhook: assinatura verificada, idempotência, timeout
- CLI: --help, exit codes, stdout/stderr
- Infra: plan sem drift, rollback, secrets via vault
- Library: semver, CHANGELOG, migration guide}

## Verificação da spec (ANTES de mover para done/)

### Processo

1. **Abrir a spec** — em `.claude/specs/` (modo repo) ou via `notion-fetch` (modo Notion) — e reler integralmente
2. **Para cada critério de aceitação:**
   - Localizar no código onde foi implementado (arquivo + linha)
   - Confirmar que o comportamento descrito é o que o código faz
   - Se o critério é quantitativo, usar `grep` para confirmar
3. **Para cada checkbox do escopo:**
   - Verificar implementação no código
   - Marcar `- [x]` se confirmado
   - Se NÃO implementado: implementar agora OU criar sub-item no backlog
4. **Atualizar metadata da spec:**
   - Status: `concluída` (ou `parcial — {detalhe}`, ex: `parcial — RF-001 e RF-003 implementados, RF-002 pendente`)
   - Responsavel: identidade de quem implementou. No modo Notion, usar `notion-get-users` com `user_id: "self"` para property tipo People. No modo repo, tentar `git config user.name`; se disponivel, usar como default e confirmar; senao, perguntar
   - Concluida em: data de hoje
   - No Notion: atualizar as properties "Responsavel" e "Concluida em" via `notion-update-page`
5. **Validação final:**
   - Todos checkboxes `[x]` e status `concluída` -> mover para `done/`
   - Checkboxes `[ ]` restantes -> manter em `specs/` (NÃO mover)

### Red flags (parar e corrigir)

- Spec em `done/` com status "rascunho" -> bug de processo
- Spec em `done/` com checkboxes desmarcados -> implementação incompleta
- Critério de aceitação que não consegue verificar no código -> não foi implementado
- "Eu lembro que fiz" sem confirmar no código -> não conta

## Verificação rápida pré-commit

```bash
# 1. Testes passam?
{comando de teste}

# 2. Coverage OK?
{comando de coverage}

# 3. Debug esquecido?
grep -rn "console.log" {src}/ --include="*.{ext}" | grep -v "node_modules"

# 4. test.only/skip?
grep -rn "test.only\|test.skip\|describe.only\|describe.skip" {tests}/

# 5. TODO sem issue?
grep -rn "TODO\|FIXME\|HACK" {src}/ --include="*.{ext}"

# 6. Secrets hardcoded?
grep -rn "sk_live\|sk_test\|AKIA\|password\s*=\s*['\"]" {src}/ --include="*.{ext}" | grep -v "process.env\|node_modules\|.test."
```

## Regra de ouro

> Se está em dúvida se precisa atualizar um doc, a resposta é sim.
> Se está em dúvida se implementou tudo da spec, a resposta é não — abrir o código e confirmar.
> Se está em dúvida se precisa de teste, a resposta é sim — e provavelmente mais de um.

## Regras

1. **Nenhuma entrega sem checklist universal completo** — os itens aplicáveis devem estar marcados antes de abrir PR
2. **Spec deve ser verificada 1 a 1** — não confirmar "de memória", abrir o código e verificar cada critério
3. **Spec `parcial` não vai para `done/`** — manter ativa com os checkboxes desmarcados e criar sub-itens no backlog
4. **PR é a unidade de entrega** — nunca push direto para `main`
5. **Artefatos temporários limpos** — `{id}-research.md` e `{id}-plan.md` deletados após verificação
