<!-- framework-tag: v2.20.0 framework-file: skills/definition-of-done/README.md -->
# Skill: Definition of Done — {NOME_DO_PROJETO}

> Use esta skill ANTES de finalizar qualquer entrega (feature, bugfix, refactor).
> Nenhuma entrega está pronta até que todos os itens aplicáveis estejam marcados.

## Checklist universal (toda entrega)

O checklist tem duas partes: o que a **máquina verifica** (verify.sh) e o que precisa de **inteligência** (Claude). Sem duplicação — cada item existe em um lugar só.

### Verificação automatizada (máquina)
- [ ] `bash scripts/verify.sh` passa sem erros

> O verify.sh cobre: testes passam, console.log, test.skip/only, contagens nos docs, prepared statements, secrets hardcoded, OWASP checks mecânicos, specs indexadas. Se o verify.sh passa, esses itens estão ok — não precisa verificar manualmente.

### Planejamento (inteligência)

- [ ] Spec existe para este item (light para Pequeno, completa para Médio+)
- [ ] **Se Médio+:** execution-plan foi criado e seguido (plano escrito, não mental)
- [ ] **Se Médio+ e projeto usa sub-agents:** implementação delegada a sub-agents (sessão principal não implementou direto)

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

## Checklists específicos por tipo

### Nova feature

Tudo do checklist universal, mais:
- [ ] Feature documentada nos docs do projeto
- [ ] Se visível ao usuário: guia/help/FAQ atualizado
- [ ] Se afeta fluxo financeiro: docs de arquitetura atualizados
- [ ] Se afeta segurança: audit docs atualizados
- [ ] Se é fluxo crítico (cadastro, pagamento, onboarding): considerar E2E test

### Bugfix

Tudo do checklist universal, mais:
- [ ] Teste reproduz o bug ANTES do fix (TDD reverso)
- [ ] Root cause documentado no commit message
- [ ] Se era bug de segurança: audit atualizado, verificar OWASP top 10 (agent `security-audit` se disponível)
- [ ] Se afetava dados: verificar se há dados corrompidos a corrigir

### Novo endpoint / rota

Tudo do checklist universal, mais:
- [ ] Checklist OWASP aplicado (agent `security-audit` se disponível, ou verificação manual)
- [ ] Testes de integração cobrem todos os status: 200, 400, 401, 403, 404, 500
- [ ] Rate limit configurado
- [ ] Docs de API atualizados

### Mudança em autenticação / permissões

Tudo do checklist universal, mais:
- [ ] Timing-safe comparison em toda comparação de secret
- [ ] Anti-enumeração: respostas uniformes ("credenciais inválidas")
- [ ] Token rotation funcionando (revoga antigo + emite novo)
- [ ] Bloqueio progressivo após falhas consecutivas
- [ ] Testes cobrem: login OK, token expirado, token inválido, rate limit, bloqueio

### Webhook / integração externa

Tudo do checklist universal, mais:
- [ ] Assinatura verificada antes de processar evento
- [ ] Raw body recebido antes do JSON parser
- [ ] Idempotência garantida (reference_id, event_id, ON CONFLICT)
- [ ] Timeout configurado
- [ ] Testes: happy path, assinatura inválida, evento duplicado, payload inválido

### Feature grande ou complexa (com breakdown de tasks)

Tudo do checklist universal, mais:
- [ ] Design doc existe e tem status `implementado` (se classificada como Grande/Complexo)
- [ ] Decisões arquiteturais registradas no `STATE.md` (AD-NNN)
- [ ] Todas as tasks do breakdown concluídas e marcadas
- [ ] Tasks `[P]` integradas e testadas em conjunto (não só isoladamente)
- [ ] `STATE.md` atualizado: lições, blockers resolvidos, ideias adiadas registradas
- [ ] Nenhuma mudança fora do escopo da task foi incluída (scope guardrail)
- [ ] Design doc movido junto com spec para `done/` (se aplicável)

### Novo comando CLI

Tudo do checklist universal, mais:
- [ ] `--help` mostra usage correto
- [ ] Exit codes: 0 (sucesso), 1 (erro), 2 (uso incorreto)
- [ ] stdout para output, stderr para erros/logs
- [ ] Flags obrigatórias ausentes geram mensagem clara
- [ ] Testes cobrem todos os cenários de "CLI / Tool" (skill `testing`)

### Mudança em infraestrutura (IaC)

Tudo do checklist universal, mais:
- [ ] `plan` mostra apenas as mudanças esperadas (sem drift acidental)
- [ ] Mudanças destrutivas identificadas e justificadas
- [ ] Secrets via variáveis/vault — zero hardcoded
- [ ] Rollback plan documentado (como reverter se der errado)
- [ ] State lock testado (se state remoto)

### Publicação de library / package

Tudo do checklist universal, mais:
- [ ] Versão bumped seguindo semver (major se breaking, minor se feature, patch se fix)
- [ ] CHANGELOG atualizado com mudanças desta versão
- [ ] Breaking changes documentados com guia de migração
- [ ] API pública tipada e documentada
- [ ] Testes cobrem cenários de "Library / Package" (skill `testing`)

### {Tipo específico do domínio — ex: Regras fiscais, Compliance, etc.}

Tudo do checklist universal, mais:
- [ ] {Checks do domínio}

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
