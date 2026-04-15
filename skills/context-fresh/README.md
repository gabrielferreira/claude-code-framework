<!-- framework-tag: v2.41.0 framework-file: skills/context-fresh/README.md -->
# Skill: Context-Fresh Execution — Orquestração por sub-agents

> Protocolo para despachar tasks de um spec a sub-agents com contexto limpo, evitando context rot.
> A sessão principal lê esta skill e segue o protocolo. Sub-agents recebem briefing focado e executam como `task-runner`.

## Quando usar

- Item **Médio+** com execution-plan pronto
- Spec com **breakdown de tasks** e grafo de dependências preenchido
- Projeto que **usa sub-agents** (ver CLAUDE.md seção "Worktrees e subagents")
- Sessão principal atingindo **~40-50% do context budget**

## Quando NÃO usar

- Item **Pequeno** (implementar direto, sem sub-agents)
- Projeto **sem sub-agents** (seguir execution-plan sequencialmente)
- Sessão com **budget confortável** (<40%) e task simples
- Task com **alto acoplamento** entre partes (melhor implementar sequencialmente)

## Pré-requisitos

- [ ] Spec aprovada com breakdown de tasks e grafo de dependências
- [ ] Execution-plan escrito (skill `.claude/skills/execution-plan/README.md`)
- [ ] STATE.md "Execução ativa" na fase `execute`
- [ ] Overlap analysis feita (do execution-plan, seção 5)

## Protocolo de orquestração

### 1. Extrair tasks e dependências

Ler o grafo de dependências da spec (tabela Task | Depende de | Arquivos | Tipo | Paralelizável?).

Montar waves de execução:
- **Wave 1:** tasks sem dependências (Depende de = —)
- **Wave 2:** tasks cujas dependências estão todas na Wave 1
- **Wave N:** tasks cujas dependências estão em waves anteriores
- Dentro de cada wave: tasks marcadas `[P]` e sem overlap de arquivos rodam em **paralelo**

Exemplo:
```
Grafo: T1(—), T2(T1), T3(T1) [P], T4(T2,T3)
Wave 1: T1 (sequencial — única)
Wave 2: T2 [P] | T3 [P] (paralelo — sem overlap)
Wave 3: T4 (sequencial — integração)
```

### 2. Compor briefing por task

Para cada task, copiar e preencher este template:

```markdown
## Briefing: {Task ID} — {Título}

### Task
- **O que:** {copiar do spec}
- **Onde:** {arquivos do spec}
- **Tipo:** {implementação|teste|integração|config}
- **Pronto quando:** {criterios do spec}

### Contexto do spec (só o necessário)
{Copiar APENAS: RF-XXX que esta task implementa + contexto mínimo da seção "Contexto" do spec.
NÃO copiar o spec inteiro — apenas o que o sub-agent precisa para esta task.}

### Design doc (se existe)
{Copiar APENAS a seção relevante do design doc para esta task, ou "N/A"}

### Arquivos a ler
{Lista de arquivos que o sub-agent deve ler para entender o contexto:}
- `path/to/file1` — {por que ler}
- `path/to/file2` — {por que ler}

### Arquivos a modificar
{Lista de arquivos que o sub-agent pode editar:}
- `path/to/file` — {o que mudar}

### NÃO tocar (negative scope)
{Arquivos de outras tasks — extrair do overlap analysis do execution-plan:}
- `path/to/other-task-file` — pertence a {Task ID}

### Completion criteria
{Copiar "Pronto quando" da task + RFs referenciados:}
1. {criterio 1 — RF-XXX}
2. {criterio 2}

### Contracts
{Interfaces com outras tasks, se houver:}
- "T3 espera que esta task exporte a função `createSession(userId)` de `src/session.js`"
- Ou "Sem contracts" se a task é independente

### Skills a seguir
{Skills de domínio que o sub-agent deve ler ANTES de implementar:}
- `.claude/skills/testing/README.md`
- `.claude/skills/security-review/README.md` (se toca em auth/segurança)
```

**Princípio:** cada briefing deve ser auto-contido. O sub-agent não precisa ler a spec completa, o execution-plan, ou o STATE.md. Tudo que ele precisa está no briefing.

### 3. Despachar

- **Tasks sequenciais (mesma wave, com deps entre si):** despachar `task-runner`, aguardar relatório PASS, despachar próxima.
- **Tasks paralelas (`[P]` na mesma wave):** despachar múltiplos `task-runner` simultaneamente usando múltiplas chamadas do Agent tool na mesma mensagem.
- **Model:** seguir tabela de decisão do CLAUDE.md. Default para implementação: `sonnet`.

Exemplo de despacho paralelo:
```
Wave 2: T2 [P] e T3 [P] sem overlap
→ Despachar Agent(task-runner, briefing T2) e Agent(task-runner, briefing T3) na mesma mensagem
→ Ambos rodam em paralelo com contexto limpo
→ Aguardar ambos reportarem antes de iniciar Wave 3
```

### 4. Rastrear completion

Manter completion log no contexto da sessão:

| Task | Wave | Status | Arquivos modificados | Notas |
|------|------|--------|---------------------|-------|
| T1 | 1 | PASS | `auth.js`, `auth.test.js` | — |
| T2 | 2 | FAIL | `session.js` | Timeout no teste — retry 1 |
| T2 | 2 | PASS | `session.js`, `session.test.js` | Retry OK |
| T3 | 2 | PASS | `LoginForm.jsx`, `LoginForm.test.jsx` | — |
| T4 | 3 | — | — | Aguardando Wave 2 |

Atualizar STATE.md campo "Tasks": "3/4 completas"

### 5. Tratar falhas

| Situação | Ação |
|----------|------|
| **FAIL — causa clara** | Corrigir briefing (mais contexto, clarificar ambiguidade), re-despachar (máximo 1 retry) |
| **FAIL — ambiguidade** | Resolver na sessão principal, re-despachar com contexto adicional no briefing |
| **FAIL 2x** | Escalar: implementar na sessão principal ou redesenhar a task no execution-plan |
| **PARTIAL** | Avaliar o que falta — completar na sessão principal ou criar sub-task |
| **Conflito entre tasks** | Resolver na sessão principal (integração é responsabilidade dela) |

### 5b. Detecção de loop

Antes de cada retry, verificar os indicadores abaixo. **3 ou mais = loop detectado.**

| Indicador | O que checar |
|-----------|-------------|
| Mesma chamada de ferramenta com parâmetros idênticos | Tool calls repetidas sem variação de argumento |
| Mesmo erro após retry | Mensagem de erro idêntica ou equivalente na 2ª tentativa |
| 3+ abordagens distintas tentadas para o mesmo problema | Log de tentativas no completion log |
| Ciclo de arquivo (criado → deletado → criado) | Diff entre arquivos modificados nas tentativas |
| Ciclo de teste (passou → falhou → passou → falhou) | Output de testes consecutivos da mesma task |

**Quando loop detectado:**

1. **Parar** — não fazer mais retries na task
2. **Invocar `stuck-detector`** com: Task ID + lista de tentativas + erros encontrados
3. **Aguardar diagnóstico** — ler o relatório do stuck-detector
4. **Registrar no STATE.md** (seção "Blockers ativos") com root cause identificada
5. **Apresentar ao usuário** o relatório + caminhos de resolução — não avançar sem decisão humana

> **Relação com max 1 retry:** A regra "máximo 1 retry" ainda vale. A detecção de loop é uma salvaguarda anterior — para casos onde o padrão de loop é evidente antes mesmo de esgotar o retry.

### 6. Integrar

Após cada wave completar:
1. Verificar que outputs se encaixam (contracts honrados entre tasks)
2. Rodar testes de integração (se existem)
3. Verificar que nenhuma task modificou arquivo fora do seu escopo
4. Se conflito: resolver na sessão principal

### 7. Transição de fase

Ao completar **todas** as tasks:
1. Completion log mostra todos PASS
2. Testes de integração passam
3. Transicionar STATE.md de `execute` → `verify`
4. Registrar transição no log de transições do STATE.md
5. Prosseguir para Definition of Done (skill definition-of-done)

## Regras

1. **Sessão principal NUNCA implementa** — delega. Se a sessão principal começa a escrever código de implementação, está violando o protocolo.
2. **Cada sub-agent recebe contexto mínimo necessário.** Não enviar o spec inteiro, o execution-plan inteiro, ou o STATE.md. Apenas o briefing focado.
3. **Ambiguidades voltam para sessão principal.** Sub-agent reporta, sessão principal decide.
4. **Integração é da sessão principal.** Nunca pedir para um sub-agent integrar o trabalho de outro.
5. **Fail 2x = escalar.** Não re-despachar infinitamente. Se falhou 2x, o problema é no briefing ou na decomposição.
6. **Verificar overlap analysis ANTES de despachar paralelo.** Duas tasks editando o mesmo arquivo = conflito garantido.
7. **Atualizar STATE.md "Tasks" após cada task completar.** O STATE.md é a memória persistente — se a sessão cair, o próximo retoma de onde parou.
8. **Funciona igual em repo mode e Notion mode.** O briefing é montado pela sessão principal, independente de onde a spec vive. O sub-agent não acessa Notion — recebe tudo no briefing.

## Checklist

- [ ] Grafo de dependências da spec lido e waves montadas
- [ ] Briefing composto para cada task (auto-contido, contexto mínimo)
- [ ] Overlap analysis verificada antes de despacho paralelo
- [ ] Dispatch respeitando dependências (waves sequenciais, tasks paralelas dentro da wave)
- [ ] Completion log atualizado após cada task
- [ ] STATE.md "Tasks" atualizado
- [ ] Integração verificada após cada wave
- [ ] Transição `execute` → `verify` registrada ao completar
