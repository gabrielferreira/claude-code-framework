---
name: spec-creator
description: Cria uma nova spec a partir do template, atualiza SPECS_INDEX e backlog
user_invocable: true
---
<!-- framework-tag: v2.6.0 framework-file: skills/spec-creator/SKILL.md -->

# /spec — Criar nova spec

Cria uma nova spec a partir do TEMPLATE.md, registra no SPECS_INDEX.md e no backlog.

## Uso

```
/spec {ID} {Título}
```

Exemplos:
- `/spec AUTH3 Autenticação com SSO`
- `/spec FEAT5 Dashboard de métricas`
- `/spec SEC2 Rate limiting por IP`
- `/spec AUTH3 Autenticação com SSO --from PROJ-456` (preenche a partir de um card do Jira)
- `/spec FEAT5 Dashboard --from https://notion.so/page/abc123` (preenche a partir de pagina do Notion)

## Instruções

### Passo 0 — Detectar modo (repo ou Notion)

Verificar se o `CLAUDE.md` do projeto contém a seção `## Integracao Notion (specs)`.
- **Se sim:** modo Notion — criar specs direto no Notion via MCP (ver seção Notion abaixo)
- **Se não:** modo repo — criar specs como arquivos locais (ver seção Repo abaixo)

---

### Passo 0b — Resolver fonte externa (se `--from` fornecido)

Se o usuario passou `--from {referencia}`, resolver a fonte ANTES de criar a spec:

1. **Identificar tipo de fonte:**
   - Parece issue key (PROJ-123, ABC-456): buscar no Jira via `getJiraIssue`
   - URL do Jira (`*.atlassian.net/browse/*`): extrair key, buscar via `getJiraIssue`
   - URL do Notion (`notion.so/*`): buscar via `notion-fetch`
   - URL do Google Docs (`docs.google.com/document/*`): buscar via `google_drive_fetch`
   - URL do Confluence (`*.atlassian.net/wiki/*`): buscar via `getConfluencePage`

2. **Extrair informacoes da fonte:**
   - Titulo, descricao, acceptance criteria, labels, prioridade
   - Subtasks/child issues (se Jira)
   - Comentarios relevantes (resumir, nao copiar verbatim)

3. **Usar como base para preencher a spec:**
   - Contexto ← descricao da fonte
   - Prioridade ← prioridade da fonte (mapear: Critical→critica, High→alta, Medium→media, Low→baixa)
   - Requisitos Funcionais ← acceptance criteria da fonte
   - Breakdown de tasks ← subtasks da fonte (se existirem)
   - Criterios de aceitacao ← acceptance criteria ou definition of done da fonte

4. **Registrar referencia no header da spec:**
   - Adicionar `> Fonte: [{tipo}]({url})` logo apos a data

5. **Informar ao usuario:** o que foi extraido e o que precisa de input manual.

---

### Modo Repo (specs locais)

1. **Validar ID:** verificar se já existe em `SPECS_INDEX.md`. Se sim, avisar.
1b. **Classificar complexidade:** antes de criar a spec, avaliar o tamanho:
   - **Pequeno** (≤3 arquivos, <30min, sem regra de negócio): criar APENAS entrada no backlog via `/backlog-update {ID} add`. Não criar spec. Informar: "Classificado como Pequeno — só precisa de entrada no backlog." Parar aqui.
   - **Médio** (<10 tasks, escopo claro): criar spec breve — preencher apenas Contexto, Requisitos Funcionais e Critérios de aceitação. Demais seções opcionais.
   - **Grande** (multi-componente, >10 tasks): criar spec completa + oferecer: "Quer criar um design doc também? (recomendado para features grandes)"
   - **Complexo** (ambiguidade, domínio novo, >20 tasks): criar spec completa + criar design doc + sugerir fluxo RPI: "Feature complexa — recomendo pesquisar em sessão separada, planejar, e implementar em sessão limpa."
   Na dúvida, classificar para cima.
2. **Criar arquivo:** copiar `.claude/specs/TEMPLATE.md` para `.claude/specs/{id-em-kebab-case}.md`
3. **Preencher header:**
   - Título: `# {ID} — {Título}`
   - Status: `rascunho`
   - Prioridade: perguntar ao usuário
   - Data: hoje
4. **Preencher contexto:** se `--from` foi usado, usar dados extraidos da fonte. Caso contrario, perguntar ao usuário ou inferir da conversa
4b. **Verificar PRD pai (se o projeto usa PRDs):**
   Detectar se o projeto tem PRD habilitado — sinais: existe `.claude/prds/PRD_TEMPLATE.md`, ou `.claude/prds/PRDS_INDEX.md`, ou `.claude/skills/prd-creator/`, ou CLAUDE.md menciona `/prd`.
   - **Se o projeto usa PRDs:** perguntar "Este spec esta vinculada a algum PRD existente?"
     - Se sim: adicionar `> PRD pai: {PRD-ID}` no header da spec, logo abaixo do Status. Atualizar o `PRDS_INDEX.md` adicionando o ID desta spec na coluna "Specs vinculadas" do PRD. Se o PRD for local (`.claude/prds/{id}.md`), atualizar tambem a tabela "Como resolver" ou "Decisoes tomadas" no PRD
     - Se nao: prosseguir sem PRD
   - **Se o projeto NAO usa PRDs:** pular este passo silenciosamente (nao perguntar)
5. **Registrar no SPECS_INDEX.md:**
   - Identificar o domínio correto
   - Adicionar linha com status `rascunho`
6. **Registrar no backlog** (se não existir):
   - Usar `/backlog-update {ID} add` ou adicionar manualmente
7. **Informar o usuário:**
   - Path do arquivo criado
   - Classificação de complexidade aplicada (Pequeno/Médio/Grande/Complexo)
   - Se Grande/Complexo: lembrar de criar design doc e breakdown de tasks
   - Lembrar que spec `rascunho` precisa ser aprovada antes de implementar

---

### Modo Notion (specs externas via MCP)

Quando a seção `## Integracao Notion (specs)` existe no CLAUDE.md, as specs são criadas diretamente no Notion.

1. **Ler configuração do CLAUDE.md:**
   - `data_source_id` — ID da collection no Notion
   - Tabela de templates por complexidade (template IDs + Design Doc IDs)

2. **Classificar complexidade:**
   - **Pequeno** (≤3 arquivos, <30min): usar template Pequeno
   - **Médio** (<10 tasks, escopo claro): usar template Médio
   - **Grande** (>10 tasks): usar template Grande/Complexa + oferecer Design Doc
   - **Complexo** (>20 tasks, domínio novo): usar template Grande/Complexa + Design Doc obrigatório + sugerir RPI

   > **Diferença do modo repo:** no Notion, **todas as complexidades criam página** (incluindo Pequeno). O template da database define o nível de detalhe — não pular a criação.

3. **Coletar informações** (perguntar ao usuário):
   - Título da spec
   - Contexto (ou inferir da conversa)
   - Domínio, Tipo, Severidade, Fase, Camadas, Impacto
   - Estimativa (opcional)
   - Projeto (nome do repositório atual)

4. **Criar página no Notion** usando `notion-create-pages`:
   ```
   parent: { data_source_id: "{data_source_id}" }
   pages: [{
     template_id: "{template_id conforme complexidade}",
     properties: {
       "Título": "{título}",
       "Status": "rascunho",
       "Complexidade": "{Pequeno|Médio|Grande|Complexo}",
       "Tipo": "{tipo}",
       "Severidade": "{severidade}",
       "Fase": "{fase}",
       "Camadas": "{camadas como JSON array}",
       "Impacto": "{impacto}",
       "Estimativa": "{estimativa}",
       "Domínio": "{domínio}",
       "Projeto": "{nome do projeto}",
       "Spec detail": "sem spec"
     }
   }]
   ```
   O template preenche o conteúdo da página automaticamente — não precisamos escrever o body.

5. **Se Grande/Complexo com Design Doc:**
   - Criar segunda página no Notion com o template Design Doc
   - Mesmas properties (Título com prefixo "Design — ", mesmo Status, Projeto, etc.)

6. **Registrar no SPECS_INDEX.md** (se existir):
   - Adicionar linha com link para a página criada no Notion
   - Formato: `| {ID} | {Título} | [Notion]({url}) | rascunho | — | {resumo} |`

7. **Informar o usuário:**
   - URL da página criada no Notion
   - Classificação de complexidade aplicada
   - Se Grande/Complexo: URL do Design Doc também
   - Lembrar que spec `rascunho` precisa ser aprovada antes de implementar
   - Spec detail será atualizado conforme preenchimento (sem spec → light → completa)

## Regras

- Spec criada sempre começa como `rascunho`
- Sempre registrar no SPECS_INDEX.md (se existir)
- **Modo repo:** nomes de arquivo `{id-kebab-case}.md`
- **Modo Notion:** criar via `notion-create-pages` com template correto — nunca criar arquivo local
- **`--from`:** quando fornecido, resolver fonte externa ANTES de criar a spec. Registrar referencia no header
- Seções obrigatórias do template devem ser mantidas (podem ficar com placeholder)
- Pequeno: **modo repo** = só backlog (sem spec). **Modo Notion** = cria página com template Pequeno
- Grande/Complexo = oferecer design doc
- Complexo = sugerir fluxo RPI (research → plan → implement em sessões separadas)
- Na dúvida sobre complexidade, classificar para cima
