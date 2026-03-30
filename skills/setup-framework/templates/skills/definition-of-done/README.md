# Skill: Definition of Done — {NOME_DO_PROJETO}

> Use esta skill ANTES de finalizar qualquer entrega (feature, bugfix, refactor).
> Nenhuma entrega está pronta até que todos os itens aplicáveis estejam marcados.

## Checklist universal (toda entrega)

### Código
- [ ] Testes passam sem erros (unitários + integração)
- [ ] Coverage respeita thresholds ({X}% módulos críticos, {Y}% global)
- [ ] Nenhum `console.log` de debug (usar logger estruturado)
- [ ] Nenhum `test.skip` ou `test.only` esquecido
- [ ] Nenhum TODO/FIXME sem issue vinculada

### Segurança (ver skill `security-review` para detalhes OWASP)
- [ ] Endpoints têm auth middleware — sem auth = justificativa documentada
- [ ] Inputs sanitizados antes de uso
- [ ] Queries SQL usam prepared statements (se aplicável)
- [ ] Dados sensíveis removidos das respostas (ver `FORBIDDEN_RESPONSE_FIELDS`)
- [ ] Ownership check: ID do recurso vem do JWT/session, não do body (IDOR)
- [ ] Secrets vêm de env vars — zero hardcoded no código
- [ ] {Checks específicos do projeto}

### Testes (ver skill `testing` para pirâmide e cenários)
- [ ] Toda nova feature tem testes (unitário + integração)
- [ ] Todo bugfix tem teste que reproduz o bug (TDD reverso)
- [ ] Branches de erro cobertos (não só happy path)
- [ ] Tipo de teste correto para o contexto (ver pirâmide):
  - Lógica isolada -> unitário
  - Endpoint / interação entre módulos -> integração
  - Fluxo crítico completo -> E2E (somente se necessário)
- [ ] Webhook: happy path + assinatura inválida + duplicata + payload inválido
- [ ] Testes chamam código de produção real — NUNCA testar template literals ou construções da linguagem
- [ ] Golden tests atualizados com review do diff (se aplicável)

### Documentação
- [ ] `CLAUDE.md` atualizado se houve mudança de regra, convenção ou estrutura
- [ ] Docs específicos atualizados se a feature os afeta (ver skill `docs-sync`)
- [ ] Contagem de testes nos docs ainda está correta

### Verificação automatizada
- [ ] `bash scripts/verify.sh` passa sem erros (se existir)

### Reports (se testes foram adicionados/modificados e `scripts/reports.sh` existe)
- [ ] `bash scripts/reports.sh` executado (regenera coverage + golden reports + backlog)
- [ ] Reports HTML atualizados

### Commits
- [ ] Commits seguem Conventional Commits (`feat`, `fix`, `security`, `test`, `docs`, `chore`, `refactor`)
- [ ] Commits atômicos — cada commit faz exatamente uma coisa

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
- [ ] Se era bug de segurança: audit atualizado, verificar OWASP top 10 (skill `security-review`)
- [ ] Se afetava dados: verificar se há dados corrompidos a corrigir

### Novo endpoint / rota

Tudo do checklist universal, mais:
- [ ] Checklist OWASP aplicado (skill `security-review`, seção por tipo de mudança)
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

1. **Abrir a spec** em `.claude/specs/` e reler integralmente
2. **Para cada critério de aceitação:**
   - Localizar no código onde foi implementado (arquivo + linha)
   - Confirmar que o comportamento descrito é o que o código faz
   - Se o critério é quantitativo, usar `grep` para confirmar
3. **Para cada checkbox do escopo:**
   - Verificar implementação no código
   - Marcar `- [x]` se confirmado
   - Se NÃO implementado: implementar agora OU criar sub-item no backlog
4. **Atualizar metadata da spec:**
   - Status: `concluída` (ou `parcial — itens X, Y pendentes`)
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
