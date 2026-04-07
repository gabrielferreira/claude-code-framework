---
name: prd-creator
description: Cria um novo PRD (Product Requirements Document) a partir do template, registra no SPECS_INDEX e opcionalmente no backlog
user_invocable: true
---
<!-- framework-tag: v2.17.2 framework-file: skills/prd-creator/SKILL.md -->

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
   - **Medio** (<10 tasks, escopo claro): criar PRD light — preencher secoes obrigatorias. Demais secoes opcionais.
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

5. **Guiar analise de causa raiz (10 passos):**

   Conduzir a analise fazendo **uma pergunta de cada vez**. Esperar a resposta antes de avancar. Nao pular etapas.

   ---

   #### Passo 1 — Problema
   Pergunte: "Qual o problema ou oportunidade? O que esta acontecendo? Quem e afetado?"

   Objetivo: capturar o que o usuario percebe como problema, em 2-3 frases concretas.

   ---

   #### Passo 2 — Validacao do problema (CRITICO)

   **Nao aceitar o problema declarado sem questionar.** Avaliar criticamente:

   - O que foi descrito parece uma **causa** (algo que gera um efeito) ou um **sintoma** (consequencia visivel) ao inves de um problema raiz?
   - Existe algo **acima** do que foi declarado?

   **Aplicar o teste de resolucao:**
   Pergunte: "Se resolvermos '{problema declarado}', o problema maior desaparece completamente? Ou continua existindo de alguma forma?"

   - **Se o usuario diz que continua existindo** → o que foi declarado e causa ou sintoma. Pergunte: "Entao qual seria o problema real que queremos resolver? O que esta acima de '{problema declarado}'?"
   - **Se o usuario diz que desaparece** → provavelmente e o problema raiz. Confirme e siga.

   **Repetir ate 3 rodadas** para evitar frustrar o usuario. Se apos 3 rodadas ainda parecer causa/sintoma mas o usuario insiste, aceitar e registrar a observacao:
   > "Nota: o problema declarado pode ser causa intermediaria de algo maior. Considerar revisitar se as solucoes nao resolverem a dor raiz."

   **Registrar no PRD:**
   - Declaracao original (o que o usuario trouxe primeiro)
   - Nivel identificado: `problema raiz`, `causa intermediaria`, ou `sintoma`
   - Problema raiz real (se diferente do original)
   - Resultado do teste de resolucao

   ---

   #### Passo 3 — Causas
   Pergunte: "O que esta gerando esse problema? Liste as causas que voce identifica."

   Objetivo: listar pelo menos 3 causas possiveis. Ajudar o usuario a ir alem do obvio:
   - "Alem dessas, existe alguma causa organizacional, de processo, ou tecnica que contribui?"
   - "Alguma dessas causas depende de outra? Uma gera a outra?"

   ---

   #### Passo 4 — Evidencias
   Pergunte: "Que dados sustentam isso? Metricas, reclamacoes, incidentes, feedbacks?"

   Objetivo: ancorar as causas em dados concretos. Sem evidencias, o PRD fica fragil.

   ---

   #### Passo 5 — Porques encadeados (5 Whys profundo)

   **Para cada causa principal**, conduzir uma cadeia de "por que?" com **minimo 3 niveis**, idealmente 5:

   Pergunte: "Vamos aprofundar a Causa 1: '{causa}'. Por que isso acontece?"
   - Ao receber resposta: "E por que '{resposta}' acontece?"
   - Repetir ate chegar numa resposta que nao tem mais "por que" (a raiz real)
   - Minimo 3 niveis, maximo 5 (parar se estiver circular ou o usuario nao souber mais)

   **Apos encadear todas as causas, cruzar as cadeias:**
   - Alguma resposta aparece em mais de uma cadeia? → E um **no compartilhado** (causa raiz que alimenta multiplos problemas)
   - Exemplo: se "falta de documentacao" aparece como resposta no nivel 3 da Causa 1 E no nivel 2 da Causa 3, sinalizar: "'{resposta}' aparece em multiplas cadeias — pode ser uma causa raiz de alto impacto."

   **Registrar cada cadeia no formato:**
   ```
   ### Causa N — {titulo}
   1. Por que? → {resposta}
   2. Por que? → {resposta}
   3. Por que? → {resposta}
   **Causa raiz identificada:** {resumo}
   ```

   ---

   #### Passo 6 — Mapa causal

   **Sintetizar** todas as cadeias de porques em um mapa de relacoes. Este passo e feito pelo assistente (nao e uma pergunta ao usuario), mas apresentado para validacao:

   1. **Nos compartilhados** — causas raiz que alimentam multiplos efeitos:
      - "{Causa raiz X} → afeta {efeito 1}, {efeito 2}, {efeito 3}"
   2. **Convergencias** — efeitos que tem multiplas causas contribuindo:
      - "{Efeito Y} ← causado por {causa 1}, {causa 2}"
   3. **Causa raiz principal** — a que, se resolvida, tem o maior efeito cascata

   Apresentar ao usuario: "Baseado na analise, identifiquei que a causa raiz de maior impacto e '{causa}' porque afeta {N} cadeias. Concorda?"

   ---

   #### Passo 7 — Quem e afetado
   Pergunte: "Quem sao as personas afetadas? Qual a dor principal de cada uma? Que workaround usam hoje?"

   Objetivo: mapear personas com dor concreta e comportamento atual.

   ---

   #### Passo 8 — Como resolver (derivacao encadeada)

   **Para cada causa raiz identificada** (nao as causas superficiais — as raizes encontradas nos Porques), conduzir cadeia de "como?":

   Pergunte: "Como resolvemos a causa raiz '{causa raiz}'?"
   - Ao receber resposta: "Como especificamente fazemos '{resposta}'?"
   - Ao receber resposta: "O que concretamente precisa ser feito para '{resposta}'?"

   **Regras:**
   - Cada acao deve rastrear para uma causa raiz especifica ("esta acao resolve a causa raiz X")
   - Acoes que nao rastreiam para nenhuma causa raiz devem ser questionadas: "Essa acao resolve qual causa raiz?"
   - Acoes vagas ("melhorar o sistema") nao servem — a cadeia de "como?" forca o detalhamento
   - Cada acao detalhada pode virar uma spec

   **Registrar cada acao no formato:**
   ```
   ### Acao N — {titulo}
   **Causa raiz atacada:** {ref}
   **Cadeia de derivacao:**
   1. Como? → {resposta}
   2. Como especificamente? → {resposta}
   3. O que concretamente? → {resposta}
   ```

   ---

   #### Passo 9 — Calibracao de escopo

   **Validar que o PRD e epic-level, nao task-level.** Checar:

   | Criterio | Resultado esperado |
   |----------|-------------------|
   | Total de acoes | >=3 (se <3, provavelmente e uma task, nao um epic) |
   | Specs estimadas | >=3 (cada acao deve gerar pelo menos 1 spec) |
   | Acoes sao de produto (o que/por que) vs implementacao (como tecnico)? | Devem ser de produto |
   | Resolver todas as acoes elimina o problema raiz? | Sim — se nao, falta acao |

   **Se <3 acoes:**
   Avisar: "Este PRD tem apenas {N} acoes — pode ser mais adequado como uma spec unica ou item de backlog. Quer reformular expandindo o escopo, ou prefere converter para spec?"

   **Se acoes sao muito tecnicas:**
   Avisar: "Algumas acoes parecem detalhes de implementacao (ex: '{acao}'). O PRD deve descrever O QUE resolver, nao COMO implementar. Quer reformular em nivel mais alto?"

   **Registrar no PRD:**
   - Total de acoes, specs estimadas, nivel validado (epic/feature/task)

   ---

   #### Passo 10 — Diagrama de padronizacao

   **Gerar automaticamente** um diagrama Mermaid que visualiza as 4 camadas do PRD, seguindo o modelo de padronizacao. O diagrama e gerado pelo assistente (nao e uma pergunta ao usuario), usando os dados coletados nos passos anteriores.

   O diagrama segue este template estrutural — substituir os placeholders pelos dados reais do PRD:

   ~~~mermaid
   flowchart TD
       subgraph problema["🔴 Qual o problema a ser resolvido?"]
           P["Impacto no usuario + Job que falha<br/><i>{problema raiz validado no passo 2}</i>"]
       end

       subgraph causas["🟠 Causas — Camada do usuario"]
           direction LR
           C1["{evidencia/causa 1}"]
           C2["{evidencia/causa 2}"]
           C3["{evidencia/causa 3}"]
       end

       subgraph porques["🟡 Porques — Camada da plataforma"]
           direction LR
           W1["{causa raiz 1}"]
           W2["{causa raiz 2}"]
           W3["{causa raiz 3}"]
           WH["🔮 Hipoteses<br/><i>Necessita validacao</i>"]
       end

       subgraph comos["🟢 Como resolver — Solucoes"]
           direction LR
           S1["{acao 1}"]
           S2["{acao 2}"]
           S3["{acao 3}"]
       end

       P --> C1 & C2 & C3
       C1 & C2 & C3 --> W1 & W2 & W3
       W1 & W2 & W3 --> S1 & S2 & S3

       style problema fill:#f8d7da,stroke:#dc3545,color:#000
       style causas fill:#ffe0b2,stroke:#ff9800,color:#000
       style porques fill:#fff9c4,stroke:#fbc02d,color:#000
       style comos fill:#c8e6c9,stroke:#4caf50,color:#000
   ~~~

   **Regras do diagrama:**

   1. **Camada 🔴 Problema:** usar o problema raiz validado (passo 2), descrito como impacto no usuario + job que falha
   2. **Camada 🟠 Causas (usuario):** preencher com as causas do passo 3 e evidencias do passo 4 — sao os sintomas observaveis pelos usuarios (comentarios classificados, dados de uso, evidencias concretas)
   3. **Camada 🟡 Porques (plataforma):** preencher com as causas raiz dos porques encadeados (passo 5-6). Categorizar cada uma como: `Inexistencia da solucao`, `Caracteristicas ou regras`, `Limitacoes tecnicas`, `UX`, `Erros ou Bugs`, `Questoes alheias a Tecnologia`, ou `Direcional estrategico`. Se alguma causa raiz nao tem evidencia solida, adicionar como `Hipotese` com nota "Necessita validacao"
   4. **Camada 🟢 Como (solucoes):** preencher com as acoes do passo 8. Cada acao ou combinacao de acoes pode virar 1 ou N tasks, stories, bugs, etc.
   5. **Conexoes:** tracar setas de cima para baixo mostrando o fluxo problema → causas → porques → solucoes. Quando possivel, mostrar conexoes especificas (qual causa leva a qual porque, qual porque leva a qual solucao)
   6. **Incluir o no `Hipoteses`** apenas se houver causas raiz sem evidencia suficiente
   7. Ajustar a quantidade de nos em cada camada conforme o PRD real — o template acima e apenas referencia

   **Salvar arquivo Mermaid separado (PADRAO):**

   Alem de incluir o diagrama no corpo do PRD, **sempre** criar um arquivo `.mmd` standalone:
   - **Modo repo:** salvar em `.claude/prds/{id-em-kebab-case}.mmd`
   - **Modo Notion/externo/export:** salvar em `.claude/prds/{id-em-kebab-case}.mmd` (mesmo sem PRD local, o diagrama fica no repo como referencia visual)

   O arquivo `.mmd` contem apenas o codigo Mermaid puro (sem code fences), pronto para abrir em qualquer ferramenta que suporte Mermaid (VS Code com extensao, Mermaid Live Editor, GitHub preview, etc.).

   Apresentar o diagrama ao usuario para validacao: "Gerei o diagrama de padronizacao do PRD. Ele mostra as 4 camadas: problema → causas (usuario) → porques (plataforma) → solucoes. Arquivo Mermaid salvo em `.claude/prds/{id}.mmd`. Confere?"

   **Apos validacao, oferecer exportacao para ferramenta visual:**

   Perguntar: "Quer exportar o diagrama para uma ferramenta visual? Posso criar direto no Miro, FigJam, Lucidchart, ou outra ferramenta se houver integracao MCP disponivel."

   **Detectar ferramentas visuais disponiveis:**

   Verificar se algum MCP de ferramenta visual esta configurado no ambiente:

   | Ferramenta | MCP / Integracao | Como detectar |
   |---|---|---|
   | **Miro** | `miro` MCP server | Verificar se tools `miro_*` ou `miro-*` estao disponiveis (ex: `miro_create_sticky_note`, `miro_create_shape`, `miro_create_connector`) |
   | **FigJam** | `figma` MCP server | Verificar se tools `figma_*` estao disponiveis |
   | **Lucidchart** | `lucidchart` MCP server | Verificar se tools `lucidchart_*` estao disponiveis |
   | **Excalidraw** | `excalidraw` MCP server | Verificar se tools `excalidraw_*` estao disponiveis |
   | **Outra** | Qualquer MCP de diagramacao | Listar tools disponiveis que parecem ser de ferramenta visual |

   **Se ferramenta visual disponivel:**

   1. Criar um board/frame dedicado ao PRD com titulo "PRD — {ID}: {Titulo} — Diagrama de Padronizacao"
   2. Criar as 4 camadas como areas/frames/sections com cores correspondentes:
      - Vermelho (#f8d7da) para Problema
      - Laranja (#ffe0b2) para Causas
      - Amarelo (#fff9c4) para Porques
      - Verde (#c8e6c9) para Solucoes
   3. Criar cada no como shape/sticky note dentro da camada correspondente
   4. Criar conectores/setas entre as camadas
   5. Informar URL do board criado ao usuario

   **Exemplo com Miro (se MCP disponivel):**
   ```
   1. miro_create_frame → frame "PRD — {ID}" no board
   2. miro_create_shape → retangulo vermelho "Problema: {titulo}"
   3. miro_create_sticky_note → sticky laranja para cada causa
   4. miro_create_sticky_note → sticky amarelo para cada porque
   5. miro_create_sticky_note → sticky verde para cada solucao
   6. miro_create_connector → setas entre os nos
   ```

   **Se nenhuma ferramenta visual disponivel:**

   Informar: "Nenhuma integracao com ferramenta visual detectada. O diagrama Mermaid foi incluido no PRD. Se quiser, voce pode copiar o codigo Mermaid para o Miro, FigJam, ou qualquer ferramenta que suporte importacao de diagramas."

   ---

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
   | Validacao do problema | obrigatorio — teste de resolucao feito | obrigatorio |
   | Causas | obrigatorio — ≥3 causas | obrigatorio |
   | Evidencias | obrigatorio — ≥1 dado concreto | obrigatorio |
   | Porques encadeados | obrigatorio — ≥3 niveis por causa | obrigatorio |
   | Mapa causal | — | obrigatorio |
   | Como resolver (com derivacao) | obrigatorio — ≥1 acao com cadeia | obrigatorio |
   | Calibracao de escopo | obrigatorio — nivel validado | obrigatorio |
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
   - Causa raiz principal identificada
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

3. **Coletar informacoes** (guiar analise de causa raiz — **mesmos 10 passos do modo repo**):
   - Passo 1-2: Problema + validacao
   - Passo 3-4: Causas + evidencias
   - Passo 5-6: Porques encadeados + mapa causal
   - Passo 7: Quem e afetado
   - Passo 8-9: Como resolver encadeado + calibracao de escopo
   - Passo 10: Diagrama de padronizacao (incluir no body da pagina + oferecer exportacao para ferramenta visual)
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
   O content deve incluir todas as secoes coletadas (Problema, Validacao, Causas, Porques encadeados, Mapa causal, Como resolver com derivacao, Calibracao, etc.).
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
   | Validacao do problema | obrigatorio | obrigatorio |
   | Causas | obrigatorio | obrigatorio |
   | Evidencias | obrigatorio | obrigatorio |
   | Porques encadeados | obrigatorio | obrigatorio |
   | Mapa causal | — | obrigatorio |
   | Como resolver (com derivacao) | obrigatorio | obrigatorio |
   | Calibracao de escopo | obrigatorio | obrigatorio |
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
   - Causa raiz principal identificada
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
2. **Coletar informacoes** (mesmos 10 passos de analise de causa raiz)
3. **Gerar PRD formatado** usando a estrutura do `PRD_TEMPLATE.md`:
   - Output completo em markdown na conversa
   - Incluir header, todas as secoes preenchidas (com validacao, porques encadeados, mapa causal, derivacao de comos, calibracao), e checklist
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
- **Nunca aceitar o problema declarado sem questionar.** Sempre aplicar o teste de resolucao (passo 2) antes de prosseguir
- **Porques devem ter minimo 3 niveis** por causa. Um unico "por que?" nao e suficiente
- **Cruzar cadeias de porques** para identificar nos compartilhados e convergencias
- **Cada acao deve rastrear para uma causa raiz.** Acoes orfas (sem causa raiz vinculada) devem ser questionadas
- **Derivar comos das causas raiz**, nao de causas superficiais. A cadeia Como? → Como especificamente? → O que concretamente? e obrigatoria
- **PRD com <3 acoes provavelmente e task.** Avisar o usuario e sugerir reformulacao ou conversao para spec
- Secoes obrigatorias: Problema, Validacao, Causas, Evidencias, Porques encadeados, Como resolver com derivacao, Calibracao de escopo
- Secoes opcionais para Medio: Mapa causal, Historias de usuario, Restricoes, Metricas de sucesso
- Na duvida sobre complexidade, classificar para cima
- O PRD captura o "o que/por que/para quem" — nao detalhar "como implementar" (isso e da spec)
- PRD `rascunho` precisa ser aprovado pelo time antes de gerar specs
