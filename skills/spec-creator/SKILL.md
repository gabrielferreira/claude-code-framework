---
name: spec
description: Cria uma nova spec a partir do template, atualiza SPECS_INDEX e backlog
user_invocable: true
---
<!-- framework-tag: v2.26.0 framework-file: skills/spec-creator/SKILL.md -->

# /spec — Criar nova spec

Cria uma nova spec a partir do TEMPLATE.md, registra no SPECS_INDEX.md e no backlog.

## Uso

```
/spec {ID} {Título}
/spec --from {url-ou-key}
/spec {ID} {Título} --from {url-ou-key}
```

Exemplos:
- `/spec AUTH3 Autenticação com SSO`
- `/spec FEAT5 Dashboard de métricas`
- `/spec SEC2 Rate limiting por IP`
- `/spec AUTH3 Autenticação com SSO --from PROJ-456` (preenche a partir de um card do Jira)
- `/spec FEAT5 Dashboard --from https://notion.so/page/abc123` (preenche a partir de pagina do Notion)
- `/spec --from PROJ-456` (ID e Título extraídos automaticamente do card)
- `/spec --from https://empresa.atlassian.net/browse/PROJ-456`

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

5. **Verificar se ja existem specs para esta fonte:**
   - Buscar no `SPECS_INDEX.md` por entradas com a mesma fonte/External ID
   - Se encontrou: informar ao usuario: "Ja existem specs para {fonte}: {lista de IDs}. Criar mais uma? Isso e normal quando um card grande e quebrado em multiplas specs."
   - **Multiplas specs por fonte e permitido e encorajado** para cards grandes (ex: epic do Jira → N specs no framework)

6. **Informar ao usuario:** o que foi extraido e o que precisa de input manual.

7. **Se ID ou Título não foram fornecidos na linha de comando:** usar os dados extraídos da fonte:
   - **ID ausente:** sugerir o issue key da fonte como ID (ex: `PROJ-123`). Confirmar com o usuário — ele pode aceitar ou digitar outro.
   - **Título ausente:** usar o título extraído da fonte como default. Confirmar com o usuário.
   Isso permite `/spec --from {url}` sem informar ID nem título manualmente.

---

### Modo Repo (specs locais)

0c. **Bootstrap check (modo repo):** verificar que a infraestrutura existe antes de operar:
   - Se `.claude/specs/` não existe → criar diretório
   - Se `.claude/specs/done/` não existe → criar diretório
   - Se `.claude/specs/TEMPLATE.md` não existe → avisar: "Template de spec não encontrado. Rodar `/setup-framework` ou criar manualmente."
   - Se `SPECS_INDEX.md` não existe → criar com estrutura mínima (header + seção vazia do domínio)
   - Se `.claude/specs/backlog.md` não existe → criar com estrutura padrão (4 seções vazias: Pendentes, Concluídos, Decisões futuras, Notas)

1. **Validar ID:** verificar se já existe em `SPECS_INDEX.md`. Se sim, avisar.
1b. **Classificar complexidade:** antes de criar a spec, avaliar o tamanho. Toda mudança cria spec — a complexidade determina o nível de detalhe:
   - **Pequeno** (≤3 arquivos, <30min, sem regra de negócio): criar spec light — preencher apenas Contexto (2 frases) e Critério de aceitação mínimo.
   - **Médio** (<10 tasks, escopo claro): criar spec breve — preencher Contexto, Requisitos Funcionais e Critérios de aceitação. Demais seções opcionais.
   - **Grande** (multi-componente, >10 tasks): criar spec completa + oferecer: "Quer criar um design doc também? (recomendado para features grandes)"
   - **Complexo** (ambiguidade, domínio novo, >20 tasks): criar spec completa + criar design doc + sugerir fluxo RPI: "Feature complexa — recomendo pesquisar em sessão separada, planejar, e implementar em sessão limpa."
   Na dúvida, classificar para cima.
2. **Criar arquivo:** copiar `.claude/specs/TEMPLATE.md` para `.claude/specs/{id-em-kebab-case}.md`
3. **Preencher header:**
   - Título: `# {ID} — {Título}`
   - Status: `rascunho`
   - Prioridade: perguntar ao usuário
   - Autor: tentar `git config user.name`; se disponivel, usar como default e confirmar; senao, perguntar (no modo Notion, a resolucao e feita pelas properties — ver Regras)
   - Responsavel: deixar vazio (sera preenchido ao concluir)
   - Data: hoje
   - Concluida em: deixar vazio (sera preenchido ao concluir)
4. **Preencher contexto:** se `--from` foi usado, usar dados extraidos da fonte. Caso contrario, perguntar ao usuário ou inferir da conversa
4b. **Verificar PRD pai (se o projeto usa PRDs):**
   Detectar se o projeto tem PRD habilitado — sinais: existe `.claude/prds/PRD_TEMPLATE.md`, ou `.claude/prds/PRDS_INDEX.md`, ou `.claude/skills/prd-creator/`, ou CLAUDE.md menciona `/prd`.
   - **Se o projeto usa PRDs:** perguntar "Este spec esta vinculada a algum PRD existente?"
     - Se sim: adicionar `> PRD pai: {PRD-ID}` no header da spec, logo abaixo do Status. Atualizar o `PRDS_INDEX.md` adicionando o ID desta spec na coluna "Specs vinculadas" do PRD. Se o PRD for local (`.claude/prds/{id}.md`), atualizar tambem a tabela "Como resolver" ou "Decisoes tomadas" no PRD
     - Se nao: prosseguir sem PRD
   - **Se o projeto NAO usa PRDs:** pular este passo silenciosamente (nao perguntar)
5. **Registrar no SPECS_INDEX.md:**
   - Identificar o domínio correto
   - Adicionar linha com status `rascunho` e coluna Fonte (ID externo se `--from` foi usado, `—` caso contrario)
   - Formato: `| {ID} | {path ou link Notion} | rascunho | {autor} | {fonte ou —} | {resumo} |`
6. **Registrar no backlog** (se não existir):
   - Usar `/backlog-update {ID} add` ou adicionar manualmente
7. **Verificação pós-criação** (OBRIGATÓRIO):
   Ler o arquivo criado e validar que o conteúdo foi preenchido:

   | Seção | Pequeno | Médio | Grande/Complexo |
   |---|---|---|---|
   | Contexto | obrigatório — ≥2 frases | obrigatório — ≥2 frases concretas, não placeholder | obrigatório |
   | Requisitos Funcionais | — | obrigatório — ≥1 RF-XXX com descrição real | obrigatório |
   | Critérios de aceitação | obrigatório — ≥1 critério | obrigatório — ≥1 critério testável | obrigatório |
   | Escopo | — | — | obrigatório |
   | Breakdown de tasks | — | — | obrigatório |
   | Grafo de dependências | — | — | obrigatório (dentro do breakdown) |

   **Se alguma seção obrigatória está vazia ou só tem placeholder** (`{...}`, `*...*`, `TBD`):
   - Perguntar ao usuário as informações faltantes
   - Preencher antes de finalizar
   - Só informar "spec criada" quando o check passar

   **Se o usuário não tem a informação agora:**
   - Marcar a seção com `{A DETALHAR — pendente de input do usuário}`
   - Avisar explicitamente: "Spec criada com N seções pendentes. Complete antes de implementar."

8. **Informar o usuário:**
   - Path do arquivo criado
   - Classificação de complexidade aplicada (Pequeno/Médio/Grande/Complexo)
   - Resultado da verificação: ✅ completa | ⚠️ N seções pendentes
   - Se Grande/Complexo: lembrar de criar design doc e breakdown de tasks
   - Lembrar que spec `rascunho` precisa ser aprovada antes de implementar

9. **Próximos passos obrigatórios** (informar conforme complexidade):

   | Complexidade | Próximos passos |
   |---|---|
   | **Pequeno** | Aprovar spec → ler `.claude/skills/spec-driven/README.md` → implementar → testar → commit |
   | **Médio** | Aprovar spec → ler `.claude/skills/spec-driven/README.md` → criar **execution-plan** (`.claude/skills/execution-plan/README.md`) → implementar → commit |
   | **Grande** | Aprovar spec → criar design doc → ler spec-driven → criar **execution-plan** → implementar → commit |
   | **Complexo** | Aprovar spec → criar design doc → fluxo RPI (research → plan → implement em sessões separadas) |

   > **Gate:** Para Médio+, **não iniciar implementação sem execution-plan escrito.** Ver skill `spec-driven` para o fluxo completo.

---

### Modo Notion (specs externas via MCP)

Quando a seção `## Integracao Notion (specs)` existe no CLAUDE.md, as specs são criadas diretamente no Notion.

1. **Ler configuração do CLAUDE.md:**
   - `data_source_id` — ID da collection no Notion
   - Tabela de templates por complexidade (template IDs + Design Doc IDs)
   - Tabela **"Campos adicionais"** (se existir) — lista de campos custom com regra de preenchimento (`Perguntar ao usuario`, `auto: url-from`, `auto: projeto`, `deixar vazio`)

2. **Classificar complexidade:** Toda mudança cria spec — a complexidade determina o nível de detalhe:
   - **Pequeno** (≤3 arquivos, <30min): usar template Pequeno (spec light)
   - **Médio** (<10 tasks, escopo claro): usar template Médio
   - **Grande** (>10 tasks): usar template Grande/Complexa + oferecer Design Doc
   - **Complexo** (>20 tasks, domínio novo): usar template Grande/Complexa + Design Doc obrigatório + sugerir RPI

3. **Coletar informações para properties** (perguntar ao usuário):
   - Título da spec
   - Domínio, Tipo, Fase, Camadas, Impacto
   - **Severidade** — obrigatório; sugerir baseado na complexidade e aguardar confirmação (não pode ficar em branco):
     - Pequeno → `baixa` | Médio → `media` | Grande → `alta` | Complexo → `critica`
     - Se `--from` tem prioridade, mapear: Critical→`critica`, High→`alta`, Medium→`media`, Low→`baixa`
     - Formato da pergunta: `Severidade: **{sugestão}** *(sugestão para {complexidade})* — confirma ou ajusta?`
   - **Estimativa** — obrigatório; sugerir baseado na complexidade e aguardar confirmação (não pode ficar em branco):
     - Pequeno → `< 4h` | Médio → `1-2 dias` | Grande → `1-2 semanas` | Complexo → `> 2 semanas`
     - Se `--from` tem story points, converter em estimativa legível (ex: 5 SP → `~3 dias`)
     - Formato da pergunta: `Estimativa: **{sugestão}** *(sugestão para {complexidade})* — confirma ou ajusta?`
   - Projeto (nome do repositório atual)
   - **Campos adicionais** — para cada campo na tabela "Campos adicionais" do CLAUDE.md (se existir):
     - `Perguntar ao usuario`: perguntar o valor ao usuário. Se o campo for select, apresentar as opções listadas na coluna "Opcoes" da tabela. Se o nome do campo indicar severidade ou estimativa/esforço, aplicar a mesma lógica de sugestão por complexidade acima. Campo obrigatório: bloquear criação até ser preenchido.
     - `auto: url-from`: preencher automaticamente com a URL/key do `--from` (se disponível; senão omitir)
     - `auto: projeto`: preencher com o nome do repositório atual
     - `deixar vazio`: não incluir nas properties

4. **Coletar conteúdo da spec** (OBRIGATÓRIO — não criar página vazia):
   Antes de criar a página, coletar o conteúdo que vai no body. Se `--from` foi usado, usar dados extraídos. Caso contrário, perguntar ao usuário ou inferir da conversa:
   - **Contexto:** por que essa mudança é necessária
   - **Requisitos Funcionais:** o que o sistema deve fazer (RF-001, RF-002...)
   - **Critérios de aceitação:** condições testáveis para considerar pronto
   - Se **Grande/Complexo:** também coletar Escopo, Riscos, Breakdown de tasks (incluindo Grafo de dependências com colunas Task | Depende de | Arquivos | Tipo | Paralelizável?)

   > **REGRA:** Nunca criar a página no Notion com body vazio ou só com placeholders do template.
   > O template do Notion fornece a estrutura, mas o conteúdo DEVE ser preenchido pela skill.
   > Se o usuário não tiver todas as informações, preencher o que tem e marcar seções pendentes com `{A DETALHAR}`.

5. **Criar página no Notion** usando `notion-create-pages`:
   ```
   parent: { data_source_id: "{data_source_id}" }
   pages: [{
     template_id: "{template_id conforme complexidade}",
     properties: {
       "Título": "{título}",
       "Status": "rascunho",
       "Complexidade": "{⚪ Pequeno|🔵 Médio|🟣 Grande|⬛ Complexo}",
       "Tipo": "{tipo}",
       "Severidade": "{severidade}",
       "Fase": "{fase}",
       "Camadas": "{camadas como JSON array}",
       "Impacto": "{impacto}",
       "Estimativa": "{estimativa}",
       "Domínio": "{domínio}",
       "Projeto": "{nome do projeto}",
       "Spec detail": "{sem spec|light|completa}",
       "Autor": "{nome do usuario que solicitou}",
       // + campos adicionais coletados no Passo 3 (incluir apenas os que têm valor):
       "{Campo adicional 1}": "{valor coletado}"
     },
     content: "{conteúdo coletado no passo 4, formatado em markdown}"
   }]
   ```
   Se o template do Notion já tem seções (H2/H3), o content preenche dentro dessas seções.
   Se não tem template, usar a estrutura do `TEMPLATE.md` como referência para o body.
   **`template_id` é best-effort:** se o MCP retornar erro indicando que o campo não é suportado, reenviar a chamada sem `template_id` — o `content` sempre garante que o body está preenchido.

   **Atualizar "Spec detail"** conforme o que foi preenchido:
   - `sem spec` — só properties, sem body (NÃO PERMITIDO — sempre preencher algo)
   - `light` — Contexto + Requisitos Funcionais + Critérios de aceitação
   - `completa` — todas as seções preenchidas (Escopo, Riscos, Breakdown, etc.)

6. **Se Grande/Complexo com Design Doc:**
   - Criar segunda página no Notion com o template Design Doc
   - Mesmas properties (Título com prefixo "Design — ", mesmo Status, Projeto, etc.)
   - Preencher body com decisões de arquitetura coletadas

6. **Registrar no SPECS_INDEX.md** (se existir):
   - Adicionar linha com link para a página criada no Notion
   - Formato: `| {ID} | [Notion]({url}) | rascunho | — | {fonte ou —} | {resumo} |`

7. **Verificação pós-criação** (OBRIGATÓRIO):
   Ler a página criada no Notion via `notion-fetch` e validar **duas dimensões**: properties e conteúdo.

   **7a. Validar properties:**
   Verificar que os campos obrigatórios foram de fato gravados na página:

   | Property | Obrigatório |
   |---|---|
   | Tipo | sim |
   | Severidade | sim |
   | Fase | sim |
   | Complexidade | sim |
   | Domínio | sim |
   | Impacto | sim |
   | Autor | sim |
   | Estimativa | não (mas perguntar se vazio) |
   | Campos adicionais marcados como "sim" na tabela do CLAUDE.md | sim |

   **Se algum campo obrigatório está vazio:** perguntar ao usuário o valor e atualizar via `notion-update-page` antes de continuar.

   **7b. Validar conteúdo do body:**

   | Seção | Pequeno | Médio | Grande/Complexo |
   |---|---|---|---|
   | Contexto | obrigatório | obrigatório | obrigatório |
   | Requisitos Funcionais | — | obrigatório | obrigatório |
   | Critérios de aceitação | — | obrigatório | obrigatório |
   | Escopo | — | — | obrigatório |
   | Breakdown de tasks | — | — | obrigatório |
   | Grafo de dependências | — | — | obrigatório (dentro do breakdown) |

   **Validar que cada seção obrigatória tem conteúdo real** (≥2 frases ou ≥1 item concreto).
   Placeholders do template (`{...}`, `*...*`, texto genérico) NÃO contam como preenchido.

   **Se alguma seção obrigatória está vazia ou só tem placeholder:**
   - Perguntar ao usuário as informações faltantes
   - Atualizar a página no Notion via `notion-update-page` com o conteúdo coletado
   - Atualizar `"Spec detail"` conforme o nível de preenchimento real

   **Se o usuário não tem a informação agora:**
   - Marcar seção com `{A DETALHAR}`
   - Avisar: "Spec criada com N seções pendentes. Complete antes de implementar."

8. **Informar o usuário:**
   - URL da página criada no Notion
   - Classificação de complexidade aplicada
   - Resultado da verificação: ✅ completa | ⚠️ N seções pendentes
   - Se Grande/Complexo: URL do Design Doc também
   - Lembrar que spec `rascunho` precisa ser aprovada antes de implementar

9. **Próximos passos obrigatórios** (mesma tabela do modo repo — informar conforme complexidade):

   | Complexidade | Próximos passos |
   |---|---|
   | **Pequeno** | Aprovar spec → ler `.claude/skills/spec-driven/README.md` → implementar → testar → commit |
   | **Médio** | Aprovar spec → ler `.claude/skills/spec-driven/README.md` → criar **execution-plan** → implementar → commit |
   | **Grande** | Aprovar spec → criar design doc → ler spec-driven → criar **execution-plan** → implementar → commit |
   | **Complexo** | Aprovar spec → criar design doc → fluxo RPI (research → plan → implement em sessões separadas) |

   > **Gate:** Para Médio+, **não iniciar implementação sem execution-plan escrito.** Ver skill `spec-driven` para o fluxo completo.

## Regras

- Spec criada sempre começa como `rascunho`. Para avançar de status, validar os gates de transição em `.claude/skills/spec-driven/README.md` seção "Gates de transição de status"
- Sempre registrar no SPECS_INDEX.md. Se não existir, criar com estrutura mínima (ver passo 0c)
- **Autor:** preencher na criacao com a identidade de quem solicitou a spec. Resolucao de identidade por modo: **Notion** → usar `notion-get-users` com `user_id: "self"` para obter o usuario logado. **Repo** → tentar `git config user.name`; se disponivel, usar como default e confirmar com o usuario; se nao, perguntar. No Notion, preencher a property "Autor" (tipo People). No modo repo, preencher o campo `> Autor:` no header
- **Responsavel:** preencher APENAS ao concluir a spec — e quem implementou (o usuario da sessao que executou a implementacao). Mesma logica de resolucao de identidade do Autor por modo. No Notion, preencher a property "Responsavel" (tipo People). No modo repo, preencher o campo `> Responsavel:` no header
- **Concluida em:** preencher APENAS ao marcar status como `concluida` — data do dia. No Notion, preencher a property "Concluida em". No modo repo, preencher o campo `> Concluida em:` no header
- **Modo repo:** nomes de arquivo `{id-kebab-case}.md`
- **Modo Notion:** criar via `notion-create-pages` com template correto — nunca criar arquivo local. **Sempre preencher o body** com conteúdo coletado (Contexto, Requisitos, Critérios). Nunca criar página com body vazio
- **Modo Notion — campo "Arquivo":** se a database do Notion tem uma property "Arquivo" (ou similar referenciando path no repo), deixar vazio — a spec vive no Notion, nao como arquivo local. Se o projeto usa modo hibrido (spec no Notion + implementacao no repo), o campo pode conter o path do branch ou PR associado, mas nao um path de arquivo .md
- **`--from`:** quando fornecido, resolver fonte externa ANTES de criar a spec. Registrar referencia no header
- **Multiplas specs por fonte:** um card/epic externo pode gerar N specs. Cada spec tem seu proprio ID unico, mas todas referenciam a mesma Fonte. Isso e normal e encorajado para cards grandes. A coluna Fonte no SPECS_INDEX.md permite rastrear quais specs vieram do mesmo card
- Seções obrigatórias do template devem ser mantidas (podem ficar com placeholder)
- Pequeno: cria spec light (contexto + critério mínimo) em ambos os modos. No modo repo: arquivo `.claude/specs/{id}.md`. No modo Notion: página com template Pequeno
- Grande/Complexo = oferecer design doc
- Complexo = sugerir fluxo RPI (research → plan → implement em sessões separadas)
- Na dúvida sobre complexidade, classificar para cima
