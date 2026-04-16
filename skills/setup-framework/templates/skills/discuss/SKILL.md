---
name: discuss
description: Modo conversacional estruturado — scout + gray areas + spec gerada ao final
user_invocable: true
---
<!-- framework-tag: v2.46.1 framework-file: skills/discuss/SKILL.md -->

# /discuss — Discussão estruturada antes da spec

Fase conversacional de scout + decisões que gera uma spec completa ao final. Substitui o salto direto de "quero X" para `/spec` quando há gray areas, domínio novo ou ambiguidades que precisam ser resolvidas antes.

## Quando usar

- Há **2+ interpretações possíveis** da solução técnica
- Existem **decisões técnicas não triviais** (escolha de lib, pattern, schema, arquitetura)
- A spec exigiria **placeholders significativos** se criada direto via `/spec`
- Feature em **domínio novo** (primeira feature nessa área do projeto)
- Card externo (Jira, Notion) tem **descrição insuficiente** para gerar spec direto
- Escopo vago onde **critérios de aceitação ainda não estão claros**

## Quando NÃO usar

- Escopo já está claro e bem definido — usar `/spec` direto
- Apenas investigar codebase sem intenção de gerar spec — usar `/research`
- Spec já existe e precisa ser atualizada — editar a spec diretamente
- Hotfix urgente com causa raiz óbvia — criar spec mínima após o fix
- Tarefa trivial (≤3 arquivos, sem ambiguidade) — usar `/spec` com spec light

## Uso

```
/discuss {ID} {Título}
/discuss {ID} {Título} --from {url-ou-key}
/discuss --from {url-ou-key}
```

Exemplos:
- `/discuss AUTH5 SSO com SAML` — explorar opções de implementação SAML antes de especificar
- `/discuss FEAT8 Sistema de notificações --from PROJ-789` — discutir a partir de um card do Jira
- `/discuss --from https://notion.so/page/abc123` — ID e Título extraídos automaticamente

## Instruções

### Passo 0 — Detectar modo (repo ou Notion)

Verificar se o `CLAUDE.md` do projeto contém a seção `## Integracao Notion (specs)`.
- **Se sim:** modo Notion — spec será criada no Notion via MCP ao final
- **Se não:** modo repo — spec será criada como arquivo local ao final

---

### Passo 0a — Verificar restrições inegociáveis

> **Antes de iniciar:** verificar se `PROJECT_CONTEXT.md` tem seção `## Restrições inegociáveis`. Se sim, carregar e manter presente durante toda a discussão. Decisões que conflitem com restrições devem ser escaladas ao usuário.

---

### Passo 0b — Resolver fonte externa (se `--from` fornecido)

Se o usuario passou `--from {referencia}`, resolver a fonte ANTES de iniciar a discussão:

1. **Identificar tipo de fonte:**
   - Parece issue key (PROJ-123, ABC-456): buscar no Jira via `getJiraIssue`
   - URL do Jira (`*.atlassian.net/browse/*`): extrair key, buscar via `getJiraIssue`
   - URL do Notion (`notion.so/*`): buscar via `notion-fetch`
   - URL do Google Docs (`docs.google.com/document/*`): buscar via `google_drive_fetch`
   - URL do Confluence (`*.atlassian.net/wiki/*`): buscar via `getConfluencePage`

2. **Extrair informações da fonte:**
   - Título, descrição, acceptance criteria, labels, prioridade
   - Subtasks/child issues (se Jira)
   - Comentários relevantes (resumir, não copiar verbatim)

3. **Se ID ou Título não foram fornecidos na linha de comando:** usar os dados extraídos da fonte:
   - **ID ausente:** sugerir o issue key da fonte como ID (ex: `PROJ-123`). Confirmar com o usuário.
   - **Título ausente:** usar o título extraído da fonte. Confirmar com o usuário.

4. **Informar ao usuário:** o que foi extraído e usar como contexto base para a discussão.

---

### Passo 1 — Carregar contexto existente

1. **Ler `PROJECT_CONTEXT.md`** (se existir) — stack, decisões arquiteturais, restrições
2. **Ler `SPECS_INDEX.md`** — identificar specs existentes no mesmo domínio para evitar re-discussão
3. **Ler `.claude/CODEBASE_MAP.md`** (se existir, produzido por `/map-codebase`) — arquitetura e padrões mapeados

> **Se nem `PROJECT_CONTEXT.md` nem `CODEBASE_MAP.md` existirem:** sugerir ao usuário: "Recomendo rodar `/map-codebase` antes para melhorar a qualidade do scout. Quer prosseguir mesmo assim?"

4. Se `--from` foi usado, incorporar dados extraídos da fonte
5. **Classificação preliminar de complexidade** baseada na descrição + contexto carregado:
   - **Pequeno** (≤3 arquivos, sem nova abstração, sem mudança de schema)
   - **Médio** (<10 tasks, escopo estimável)
   - **Grande** (multi-componente, >10 tasks)
   - **Complexo** (ambiguidade significativa, domínio novo, >20 tasks)

6. **Informar ao usuário:**
   ```
   Contexto carregado:
   - PROJECT_CONTEXT: {presente|ausente}
   - CODEBASE_MAP: {presente|ausente}
   - {N} specs existentes no domínio {X}
   - Complexidade preliminar: {classificação} (pode mudar durante a discussão)
   ```

---

### Passo 2 — Scout no codebase

Busca rápida e direcionada (NÃO é research completo):

1. **Grep/glob por termos relacionados** ao título e domínio da feature
2. **Identificar:**
   - Módulos/arquivos que o tema provavelmente vai tocar
   - Patterns existentes similares (ex: "já existe autenticação via OAuth, padrão X")
   - Código reutilizável (funções, abstrações, tipos)
   - Schema/tabelas relacionadas (se aplicável)
   - Inconsistências ou padrões conflitantes no codebase

3. **Resumir achados em 3-5 bullets:**
   ```
   Scout — achados relevantes:
   • {padrão encontrado} em {arquivo/módulo}
   • {código reutilizável} em {local}
   • {schema relacionado} em {arquivo}
   ```

**Regras do scout:**
- Máximo **15-20 arquivos lidos** (ler imports + ~50 linhas por arquivo)
- Não entrar em `node_modules`, `vendor`, `dist`, `build`
- Se `CODEBASE_MAP.md` existe, usar como atalho (pular detecção de stack)
- Se monorepo detectado (seção `## Monorepo` no CLAUDE.md), focar no sub-projeto relevante

---

### Passo 3 — Identificar gray areas

Com base no contexto (Passo 1) e scout (Passo 2), identificar automaticamente áreas que precisam de decisão antes de gerar a spec.

**Fontes de gray areas:**
- **Do intent do usuário:** ambiguidades no que foi descrito, escopo indefinido, edge cases não cobertos
- **Do scout:** padrões conflitantes, abstrações ausentes, decisões técnicas necessárias, implicações de schema
- **Do contexto:** contradições com restrições inegociáveis, dependência de specs em `rascunho`, gaps na arquitetura

**Categorias:**
- **🔴 Ambiguidade** — requisito vago, escopo indefinido, edge case não coberto
- **🟠 Decisão técnica** — múltiplas abordagens possíveis, escolha de lib/pattern/schema
- **🟡 Dependência** — depende de spec/feature que não existe ou está em rascunho
- **⚪ Conflito** — contradiz padrão existente, restrição ou decisão anterior

**Apresentar lista numerada, ordenada por impacto/risco (maior primeiro):**

```
Gray areas identificadas (ordenadas por impacto):

1. 🔴 [Ambiguidade] Como tratar usuários existentes durante a migração?
   Impacto: bloqueia definição de escopo e estimativa

2. 🟠 [Decisão técnica] Usar WebSocket ou SSE para notificações real-time?
   Impacto: determina arquitetura do módulo inteiro

3. 🟡 [Dependência] Schema de permissões depende de AUTH-120 (status: em andamento)
   Impacto: pode atrasar início da implementação

4. ⚪ [Conflito] Projeto usa REST puro mas feature sugere GraphQL subscription
   Impacto: baixo se resolvido com SSE; alto se forçar novo protocolo

Quais você quer explorar? (números separados por vírgula, ou 'todas')
```

**Se nenhuma gray area identificada:**
- Informar: "Nenhuma gray area identificada — escopo parece claro para este contexto."
- Oferecer: "Quer gerar a spec direto ou quer explorar algum aspecto específico?"
- Se o usuário escolher gerar direto, pular para **Passo 5**.

---

### Passo 4 — Deep-dive nas gray areas selecionadas

Para cada gray area que o usuário escolheu explorar, **uma por vez**:

1. **Apresentar o contexto específico** (o que o scout encontrou sobre o tema)
2. **Listar alternativas concretas** (quando aplicável):
   ```
   Opções para [Gray area N]:
   A) {alternativa 1} — trade-off: {benefício} vs {custo}
   B) {alternativa 2} — trade-off: {benefício} vs {custo}
   C) Outra (descreva)
   ```
3. **Aguardar decisão do usuário**
4. **Registrar a decisão internamente:** `{gray area} → {decisão} + {justificativa breve}`

**Regras do deep-dive:**
- **UMA gray area por vez** — não misturar
- **Máximo 3 interações por gray area** — se não houver decisão após 3 rodadas, registrar como `{A DETALHAR}` com impacto documentado e seguir para a próxima
- Se o usuário quiser explorar mais (ex: "e se fizéssemos X?"), continuar dentro do limite de 3
- **NUNCA inventar decisão** — se o usuário não decidiu, registrar como pendente
- Se durante o deep-dive surgir nova gray area, adicioná-la à lista e perguntar se quer explorar também
- Ao terminar cada gray area, informar: "Decidido: {resumo}. Próxima: {gray area seguinte} ou 'pular restantes'?"

---

### Passo 4b — Consolidar decisões (OBRIGATÓRIO)

Antes de gerar a spec, apresentar o resumo completo das decisões:

```
Decisões consolidadas:

| # | Gray area | Decisão | Motivo | Trade-off aceito |
|---|-----------|---------|--------|-----------------|
| 1 | {descrição} | {decisão tomada} | {justificativa} | {o que foi sacrificado} |
| 2 | {descrição} | {A DETALHAR} | — | Impacto: {descrição do impacto da indefinição} |
| ...

Confirma? (sim / ajustar N / adicionar decisão)
```

- O usuário pode ajustar qualquer decisão antes de prosseguir
- Decisões pendentes (`{A DETALHAR}`) devem ter o campo "Impacto" preenchido — qual o risco de implementar sem essa definição
- Só prosseguir para a geração da spec após confirmação

---

### Passo 5 — Classificação final de complexidade

Reclassificar com base nas decisões tomadas:
- Contar arquivos afetados (estimativa baseada no scout + decisões)
- Contar tasks implícitas
- Avaliar se há nova abstração, mudança de schema, regra de negócio nova

**Se a classificação mudou em relação à preliminar (Passo 1):**
- Informar explicitamente: "Complexidade reclassificada de **{X}** para **{Y}**. Motivo: {explicação concreta — ex: decisão de criar novo schema aumentou escopo de 3 para 12 arquivos}."

**Regra de proporcionalidade:** o nível de detalhe da spec deve ser proporcional à complexidade final. Não expandir decisões além do necessário para implementação.

---

### Passo 6 — Gerar spec

A spec segue o mesmo formato e fluxo do `/spec`, incorporando as decisões do discuss.

#### Modo Repo

0c. **Bootstrap check:** verificar que a infraestrutura existe:
   - Se `.claude/specs/` não existe → criar diretório
   - Se `.claude/specs/done/` não existe → criar diretório
   - Se `.claude/specs/TEMPLATE.md` não existe → avisar: "Template de spec não encontrado. Rodar `/setup-framework` ou criar manualmente."
   - Se `SPECS_INDEX.md` não existe → criar com estrutura mínima
   - Se `.claude/specs/backlog.md` não existe → criar com estrutura padrão

1. **Validar ID:** verificar se já existe em `SPECS_INDEX.md`. Se sim, avisar.
2. **Criar arquivo:** copiar `.claude/specs/TEMPLATE.md` para `.claude/specs/{id-em-kebab-case}.md`
3. **Preencher header:**
   - Título: `# {ID} — {Título}`
   - Status: `rascunho`
   - Prioridade: inferir das decisões ou perguntar
   - Autor: tentar `git config user.name`; se disponível, usar como default e confirmar; senão, perguntar
   - Data: hoje
   - Se `--from` usado: `> Fonte: [{tipo}]({url})`
4. **Preencher seções com decisões do discuss:**
   - **Contexto:** sintetizar do Passo 1 + decisões tomadas
   - **Requisitos Funcionais:** derivar das decisões (RF-001, RF-002...) — proporcional à complexidade
   - **Escopo:** derivar dos arquivos identificados no scout + decisões (se Grande/Complexo)
   - **Critérios de aceitação:** derivar das decisões tomadas
   - **Possíveis riscos:** derivar dos trade-offs discutidos (se Grande/Complexo)
   - **Arquivos afetados:** do scout (Passo 2)
   - **Breakdown de tasks:** se Grande/Complexo, derivar das decisões
   - **Não fazer:** itens descartados durante o discuss
   - **Notas — Decisões do /discuss:** incluir tabela de decisões consolidadas do Passo 4b (decisão + motivo + trade-off)
5. **Gray areas não exploradas:** inserir placeholder `{A DETALHAR — impacto: "{descrição do impacto da indefinição}"}`
6. **Verificar PRD pai** (se o projeto usa PRDs) — mesma lógica do `/spec` Passo 4b
7. **Registrar no SPECS_INDEX.md** com status `rascunho` e coluna Fonte
8. **Registrar no backlog** (se não existir): usar `/backlog-update {ID} add` ou adicionar manualmente

#### Modo Notion

Quando a seção `## Integracao Notion (specs)` existe no CLAUDE.md:

1. **Ler configuração do CLAUDE.md:** `data_source_id`, templates por complexidade, campos adicionais
2. **Coletar properties:** usar dados das decisões para preencher Título, Status (`rascunho`), Complexidade, Tipo, Severidade, Fase, Camadas, Impacto, Estimativa, Domínio, Projeto, Autor, campos adicionais
3. **Preencher body** com conteúdo das decisões (mesmo formato do modo repo) — **NUNCA criar página vazia**
4. **Criar página** via `notion-create-pages` com template conforme complexidade. Se `template_id` falhar, reenviar sem ele
5. **Se Grande/Complexo:** oferecer Design Doc (segunda página no Notion)
6. **Registrar no SPECS_INDEX.md** (se existir) com link para página do Notion

---

### Passo 7 — Verificação pós-criação (OBRIGATÓRIO)

Ler o artefato criado (arquivo ou página Notion) e validar:

**7a. Seções obrigatórias por complexidade:**

| Seção | Pequeno | Médio | Grande/Complexo |
|---|---|---|---|
| Contexto | obrigatório — ≥2 frases | obrigatório | obrigatório |
| Requisitos Funcionais | — | obrigatório — ≥1 RF | obrigatório |
| Critérios de aceitação | obrigatório — ≥1 | obrigatório | obrigatório |
| Escopo | — | — | obrigatório |
| Breakdown de tasks | — | — | obrigatório |

**7b. Validação específica do /discuss:**
- Cada gray area **explorada** tem decisão refletida na spec (em Requisitos, Escopo ou Notas)
- Cada gray area **não explorada** tem placeholder `{A DETALHAR — impacto: "..."}` na seção relevante
- Seção "Notas — Decisões do /discuss" contém a tabela de decisões consolidadas

**Se alguma seção obrigatória está vazia ou só tem placeholder:**
- Perguntar ao usuário as informações faltantes
- Preencher antes de finalizar
- Só informar "spec criada" quando o check passar

**Se o usuário não tem a informação agora:**
- Marcar com `{A DETALHAR — pendente de input do usuário}`
- Avisar explicitamente: "Spec criada com N seções pendentes. Complete antes de implementar."

---

### Passo 8 — Informar o usuário

Apresentar resumo final:

```
Spec gerada: {path do arquivo ou URL do Notion}

Métricas do /discuss:
- Gray areas: {N} identificadas / {M} exploradas / {K} decididas / {J} pendentes

Complexidade: {preliminar} → {final} {(motivo da mudança, se houve)}
Verificação: {✅ completa | ⚠️ N seções pendentes}
```

**Próximo passo claro** (conforme complexidade e estado):

| Situação | Próximo passo |
|---|---|
| **Pequeno, spec completa** | Aprovar spec → ler `spec-driven` → implementar → testar → commit |
| **Médio, spec completa** | Aprovar spec → criar **execution-plan** (`/execution-plan`) → implementar → commit |
| **Grande, spec completa** | Aprovar spec → criar design doc → criar **execution-plan** → implementar → commit |
| **Complexo, spec completa** | Aprovar spec → criar design doc → fluxo RPI (research → plan → implement em sessões separadas) |
| **Qualquer, com pendentes críticas** | Resolver pendências críticas antes de implementar — itens marcados `{A DETALHAR}` com impacto alto |

> **Gate:** Para Médio+, **não iniciar implementação sem execution-plan escrito.** Ver skill `spec-driven` para o fluxo completo.

## Regras

- **NUNCA inventar decisão** — se o dev não decidiu, registrar como `{A DETALHAR}` com impacto. Não assumir, não preencher por conta própria
- **UMA pergunta/gray area por vez** — não sobrecarregar o usuário com múltiplas decisões simultâneas
- **Máximo 3 interações por gray area** — sem decisão após 3 rodadas → `{A DETALHAR}` + impacto e seguir
- **Scout é rápido e direcionado** — máximo 15-20 arquivos. NÃO é research completo
- **Detalhe proporcional à complexidade** — não gerar spec Grande para feature Pequena. Não expandir decisões além do necessário para implementação
- **Spec gerada segue o mesmo formato do `/spec`** (TEMPLATE.md) — indistinguível de uma spec criada via `/spec`
- Spec começa como `rascunho` — mesma regra do `/spec`
- **Dual-mode:** repo + Notion (mesma detecção do `/spec`). Ambos devem produzir resultados equivalentes
- **`--from`:** mesma resolução de fonte externa do `/spec`. Registrar referência no header
- Complexidade classifica para cima na dúvida
- Se durante o discuss ficar claro que **não há gray areas**, oferecer gerar spec direto (atalho com contexto já coletado)
- Registrar sempre no SPECS_INDEX.md e backlog
- **Autor:** mesma lógica de resolução do `/spec` — Notion: `notion-get-users` com `user_id: "self"`. Repo: `git config user.name`
- **Gray areas ordenadas por impacto/risco** — itens que bloqueiam escopo ou estimativa primeiro
- **Consolidação obrigatória** (Passo 4b) — nunca pular direto para geração de spec sem confirmar decisões

## Checklist

- [ ] `PROJECT_CONTEXT.md` e specs existentes carregados antes de perguntar
- [ ] Scout no codebase realizado (patterns, código reutilizável, 15-20 arquivos max)
- [ ] Gray areas identificadas, categorizadas e ordenadas por impacto
- [ ] Deep-dive realizado nas áreas selecionadas (max 3 interações cada)
- [ ] Decisões consolidadas e confirmadas pelo usuário (Passo 4b)
- [ ] Complexidade classificada (preliminar e final, com motivo se mudou)
- [ ] Spec gerada com decisões incorporadas nas seções corretas
- [ ] Gray areas não exploradas marcadas como `{A DETALHAR — impacto: "..."}` com impacto documentado
- [ ] Spec registrada no SPECS_INDEX.md com status `rascunho`
- [ ] Item no backlog (se não existia)
- [ ] Verificação pós-criação aprovada (seções obrigatórias + decisões refletidas)
- [ ] Métricas apresentadas: identificadas / exploradas / decididas / pendentes
- [ ] Próximo passo claro informado ao usuário
