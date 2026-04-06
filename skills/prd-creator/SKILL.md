---
name: prd-creator
description: Cria um novo PRD (Product Requirements Document) a partir do template, registra no SPECS_INDEX e opcionalmente no backlog
user_invocable: true
---
<!-- framework-tag: v2.12.0 framework-file: skills/prd-creator/SKILL.md -->

# /prd — Criar novo PRD

Cria um novo PRD (Product Requirements Document) para documentar analise de causa raiz antes de criar specs tecnicas. Um PRD pode gerar multiplas specs.

## Uso

```
/prd {ID} {Titulo}
```

Exemplos:
- `/prd SUPORTE Tempo de resposta do suporte alto`
- `/prd AUTH Autenticacao unificada para todos os canais`
- `/prd PERF Latencia critica no checkout`
- `/prd SUPORTE Tempo de resposta alto --from PROJ-789` (preenche a partir de um card do Jira)
- `/prd AUTH Autenticacao --from https://notion.so/page/abc123` (preenche a partir de pagina do Notion)
- `/prd PERF Latencia --export` (gera PRD formatado para copiar, sem criar arquivo)

## Instrucoes

### Passo 0 — Detectar modo (repo, Notion, externo, ou export)

Verificar no `CLAUDE.md` do projeto:

1. **Flag `--export` presente no comando?**
   - **Se sim:** modo export — gerar PRD formatado na conversa para copy-paste. Nao criar arquivo nem registrar. Pular para seção Export abaixo.
2. **Secao `## Integracao Notion (PRDs)` existe?**
   - **Se sim:** modo Notion — criar PRD direto no Notion via MCP
3. **Secao `## Integracao Notion (specs)` existe E config `prd_data_source_id` esta presente?**
   - **Se sim:** modo Notion — usar database separada para PRDs
4. **Secao menciona ferramenta externa para PRDs?**
   - **Se sim:** modo externo — pedir URL/ID do PRD e registrar referencia
5. **Nenhum dos anteriores:**
   - Modo repo — criar PRD como arquivo local

### Passo 0b — Resolver fonte externa (se `--from` fornecido)

Se o usuario passou `--from {referencia}`, resolver a fonte ANTES de iniciar a analise:

1. **Identificar tipo de fonte:**
   - Parece issue key (PROJ-123, ABC-456): buscar no Jira via `getJiraIssue`
   - URL do Jira (`*.atlassian.net/browse/*`): extrair key, buscar via `getJiraIssue`
   - URL do Notion (`notion.so/*`): buscar via `notion-fetch`
   - URL do Google Docs (`docs.google.com/document/*`): buscar via `google_drive_fetch`
   - URL do Confluence (`*.atlassian.net/wiki/*`): buscar via `getConfluencePage`

2. **Extrair informacoes da fonte:**
   - Titulo, descricao, acceptance criteria, labels, prioridade
   - Child issues/subtasks (se Jira epic)
   - Comentarios relevantes (resumir, nao copiar verbatim)

3. **Usar como base para preencher o PRD:**
   - Problema ← descricao da fonte
   - Prioridade ← prioridade da fonte (mapear: Critical→critica, High→alta, Medium→media, Low→baixa)
   - Como resolver ← subtasks/acceptance criteria da fonte
   - Evidencias ← dados mencionados na descricao

4. **Registrar referencia no header do PRD:**
   - Adicionar `> Fonte: [{tipo}]({url})` logo apos a data

5. **Informar ao usuario:** o que foi extraido e o que precisa de input manual.

---

### Modo Repo (PRDs locais)

1. **Validar ID:** verificar se ja existe PRD com esse ID no `PRDS_INDEX.md` (em `.claude/prds/PRDS_INDEX.md`). Se sim, avisar.

2. **Classificar complexidade:**
   - **Pequeno** (<=3 arquivos, <30min): PRD nao se aplica. Informar: "Classificado como Pequeno — nao precisa de PRD. Use `/spec` ou `/backlog-update` direto." Parar aqui.
   - **Medio** (<10 tasks, escopo claro): criar PRD light — preencher apenas Problema, Causas, Evidencias, Porques e Como resolver. Demais secoes opcionais.
   - **Grande** (multi-componente, >10 tasks): criar PRD completo com todas as secoes.
   - **Complexo** (ambiguidade, dominio novo, >20 tasks): criar PRD completo + sugerir sessao de pesquisa antes: "Feature complexa — recomendo uma sessao de pesquisa/discovery antes de preencher o PRD."
   Na duvida, classificar para cima.

3. **Criar arquivo:** copiar `.claude/prds/PRD_TEMPLATE.md` para `.claude/prds/{id-em-kebab-case}.md`

4. **Preencher header:**
   - Titulo: `# PRD — {ID}: {Titulo}`
   - Status: `rascunho`
   - Prioridade: perguntar ao usuario
   - Complexidade: conforme classificacao
   - Data: hoje

5. **Guiar analise de causa raiz:** perguntar ao usuario em sequencia:
   - **Problema:** "Qual o problema ou oportunidade? O que esta acontecendo? Quem e afetado?"
   - **Causas:** "O que esta gerando esse problema? Liste as causas que voce identifica."
   - **Evidencias:** "Que dados sustentam isso? Metricas, reclamacoes, incidentes, feedbacks?"
   - **Porques:** "Por que essas causas existem? Vamos aprofundar — por que a causa X acontece?"
   - **Quem:** "Quem sao as personas afetadas? Qual a dor principal de cada uma?"
   - **Como resolver:** "Quais acoes concretas resolvem as causas raiz? Cada acao pode virar uma spec."

   > Nao e necessario preencher tudo de uma vez. O usuario pode deixar campos como placeholder e iterar depois. O importante e capturar o maximo possivel na primeira passada.

6. **Registrar no PRDS_INDEX.md** (em `.claude/prds/PRDS_INDEX.md`):
   - Adicionar linha na secao "PRDs ativos"
   - Formato: `| {ID} | {Titulo} | rascunho | — | {resumo} |`

7. **Registrar no backlog** (opcional):
   - Perguntar: "Quer criar uma entrada no backlog para acompanhar este PRD?"
   - Se sim: criar com Tipo `Analise` via `/backlog-update`

8. **Verificacao pos-criacao** (OBRIGATORIO):
   Ler o arquivo criado e validar que o conteudo foi preenchido:

   | Secao | Medio | Grande/Complexo |
   |---|---|---|
   | Problema | obrigatorio — ≥2 frases concretas | obrigatorio |
   | Causas | obrigatorio — ≥1 causa real | obrigatorio |
   | Evidencias | obrigatorio — ≥1 dado concreto | obrigatorio |
   | Porques | obrigatorio — ≥1 nivel de profundidade | obrigatorio |
   | Como resolver | obrigatorio — ≥1 acao concreta | obrigatorio |
   | Quem e afetado | — | obrigatorio |
   | Metricas de sucesso | — | obrigatorio |

   **Se alguma secao obrigatoria esta vazia ou so tem placeholder** (`{...}`, `*...*`, `TBD`):
   - Perguntar ao usuario as informacoes faltantes
   - Preencher antes de finalizar
   - So informar "PRD criado" quando o check passar

   **Se o usuario nao tem a informacao agora:**
   - Marcar a secao com `{A DETALHAR — pendente de input do usuario}`
   - Avisar: "PRD criado com N secoes pendentes. Complete antes de aprovar."

9. **Informar o usuario:**
   - Path do arquivo criado (`.claude/prds/{id}.md`)
   - Classificacao de complexidade aplicada
   - Resultado da verificacao: ✅ completo | ⚠️ N secoes pendentes
   - Se `--from` foi usado: resumo do que foi extraido da fonte
   - Proximo passo: "Quando o PRD estiver aprovado, crie specs derivadas com `/spec {SPEC-ID} {Titulo}` e vincule a este PRD."
   - Lembrar que PRD `rascunho` precisa ser discutido/aprovado pelo time antes de gerar specs

---

### Modo Notion (PRDs via MCP)

Quando a secao `## Integracao Notion (PRDs)` existe no CLAUDE.md, ou o `prd_data_source_id` esta configurado na secao de specs.

1. **Ler configuracao do CLAUDE.md:**
   - `prd_data_source_id` — ID da collection de PRDs no Notion (se database separada)
   - Ou `data_source_id` da secao de specs (se PRDs compartilham database, usar property `"Tipo": "PRD"`)
   - Template de PRD (se configurado na tabela de templates)

2. **Classificar complexidade:** mesma logica do modo repo. Pequeno = nao cria PRD.

3. **Coletar informacoes** (guiar analise de causa raiz — mesmas perguntas do modo repo):
   - Problema, Causas, Evidencias, Porques, Como resolver (obrigatorias)
   - Quem e afetado, Historias de usuario, Metricas, Escopo (conforme complexidade)
   - Se `--from` foi usado, usar dados extraidos como base

   > **REGRA:** Nunca criar pagina no Notion com body vazio ou so com placeholders.
   > O conteudo coletado neste passo DEVE ser usado como body no passo 4.

4. **Criar pagina no Notion** usando `notion-create-pages`:
   ```
   parent: { data_source_id: "{data_source_id}" }
   pages: [{
     template_id: "{template_id_prd se existir}",
     properties: {
       "Titulo": "PRD — {ID}: {titulo}",
       "Status": "rascunho",
       "Complexidade": "{Medio|Grande|Complexo}",
       "Tipo": "PRD",
       "Projeto": "{nome do projeto}"
     },
     content: "{conteudo coletado no passo 3, formatado em markdown}"
   }]
   ```
   O content deve incluir todas as secoes coletadas (Problema, Causas, Evidencias, etc.).
   Se o template do Notion ja tem secoes (H2/H3), preencher dentro dessas secoes.
   Se nao houver template de PRD na database, criar a pagina sem template e preencher o conteudo usando o formato do PRD_TEMPLATE.md como referencia.
   Se o usuario nao tiver todas as informacoes, preencher o que tem e marcar secoes pendentes com `{A DETALHAR}`.

5. **Registrar no PRDS_INDEX.md** (se existir em `.claude/prds/`):
   - Secao "PRDs ativos"
   - Formato: `| {ID} | {Titulo} | rascunho | — | {resumo} |`
   - Adicionar nota com link Notion: `[Notion]({url})`

6. **Verificacao pos-criacao** (OBRIGATORIO):
   Ler a pagina criada no Notion via `notion-fetch` e validar que o conteudo foi preenchido:

   | Secao | Medio | Grande/Complexo |
   |---|---|---|
   | Problema | obrigatorio | obrigatorio |
   | Causas | obrigatorio | obrigatorio |
   | Evidencias | obrigatorio | obrigatorio |
   | Porques | obrigatorio | obrigatorio |
   | Como resolver | obrigatorio | obrigatorio |
   | Quem e afetado | — | obrigatorio |
   | Metricas de sucesso | — | obrigatorio |

   **Validar que cada secao obrigatoria tem conteudo real** (≥2 frases ou ≥1 item concreto).
   Placeholders do template NÃO contam.

   **Se alguma secao obrigatoria esta vazia:**
   - Perguntar ao usuario as informacoes faltantes
   - Atualizar a pagina no Notion via `notion-update-page`

   **Se o usuario nao tem a informacao agora:**
   - Marcar com `{A DETALHAR}` e avisar quantas secoes ficaram pendentes

7. **Informar o usuario:**
   - URL da pagina criada no Notion
   - Classificacao de complexidade
   - Resultado da verificacao: ✅ completo | ⚠️ N secoes pendentes
   - Se `--from` foi usado: resumo do que foi extraido da fonte
   - Proximo passo: vincular specs ao PRD conforme acoes forem priorizadas

---

### Modo Externo (PRD em outra ferramenta)

Quando PRDs vivem em Jira, Confluence, Google Docs, ou outra ferramenta.

1. **Pedir referencia:** "Qual a URL ou ID do PRD nessa ferramenta?"

2. **Registrar no PRDS_INDEX.md** (se existir em `.claude/prds/`):
   - Secao "PRDs ativos"
   - Formato: `| {ID} | {Titulo} | rascunho | — | {resumo} |`
   - Adicionar nota com link: `[{ferramenta}]({url})`

3. **Informar o usuario:**
   - Referencia registrada
   - Proximo passo: criar specs derivadas e vincular ao PRD

---

### Modo Export (PRD para copiar)

Quando o usuario passa `--export` ou o projeto tem `prd_mode: export` no CLAUDE.md. O PRD e gerado como output formatado na conversa, sem criar arquivo nem registrar em nenhum index.

1. **Classificar complexidade** (mesma logica)
2. **Coletar informacoes** (mesma sequencia de perguntas, ou usar `--from` se fornecido)
3. **Gerar PRD formatado** usando a estrutura do `PRD_TEMPLATE.md`:
   - Output completo em markdown na conversa
   - Incluir header, todas as secoes preenchidas, e checklist
4. **Informar o usuario:**
   - "PRD gerado para copy-paste. Nenhum arquivo foi criado."
   - Sugerir destino: "Copie para o Jira, Confluence, ou ferramenta de produto do time."
   - Se o usuario quiser salvar depois: "Use `/prd {ID} {Titulo}` sem `--export` para salvar localmente."

---

## Regras

- PRD criado sempre comeca como `rascunho`
- Pequeno nunca gera PRD — ir direto para spec ou backlog
- Sempre registrar no `PRDS_INDEX.md` (em `.claude/prds/`) — exceto modo export
- **Modo repo:** nomes de arquivo `{id-kebab-case}.md` no diretorio `.claude/prds/`
- **Modo Notion:** criar via `notion-create-pages` — nunca criar arquivo local quando Notion esta configurado
- **Modo externo:** apenas registrar referencia — nao criar arquivo local
- **Modo export:** gerar output formatado na conversa — nao criar arquivo nem registrar
- **`--from`:** quando fornecido, resolver fonte externa ANTES de iniciar analise. Registrar referencia no header do PRD
- Secoes obrigatorias: Problema, Causas, Evidencias, Porques, Como resolver
- Secoes opcionais para Medio: Historias de usuario, Restricoes, Metricas de sucesso
- Na duvida sobre complexidade, classificar para cima
- O PRD captura o "o que/por que/para quem" — nao detalhar "como implementar" (isso e da spec)
- PRD `rascunho` precisa ser aprovado pelo time antes de gerar specs
