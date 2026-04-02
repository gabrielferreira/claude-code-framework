---
name: prd-creator
description: Cria um novo PRD (Product Requirements Document) a partir do template, registra no SPECS_INDEX e opcionalmente no backlog
user_invocable: true
---
<!-- framework-tag: v2.5.0 framework-file: skills/prd-creator/SKILL.md -->

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

## Instrucoes

### Passo 0 — Detectar modo (repo, Notion, ou externo)

Verificar no `CLAUDE.md` do projeto:

1. **Secao `## Integracao Notion (specs)` existe?**
   - **Se sim:** modo Notion — criar PRD direto no Notion via MCP
2. **Secao menciona ferramenta externa para PRDs?**
   - **Se sim:** modo externo — pedir URL/ID do PRD e registrar referencia
3. **Nenhum dos anteriores:**
   - Modo repo — criar PRD como arquivo local

---

### Modo Repo (PRDs locais)

1. **Validar ID:** verificar se ja existe PRD com esse ID no `SPECS_INDEX.md`. Se sim, avisar.

2. **Classificar complexidade:**
   - **Pequeno** (<=3 arquivos, <30min): PRD nao se aplica. Informar: "Classificado como Pequeno — nao precisa de PRD. Use `/spec` ou `/backlog-update` direto." Parar aqui.
   - **Medio** (<10 tasks, escopo claro): criar PRD light — preencher apenas Problema, Causas, Evidencias, Porques e Como resolver. Demais secoes opcionais.
   - **Grande** (multi-componente, >10 tasks): criar PRD completo com todas as secoes.
   - **Complexo** (ambiguidade, dominio novo, >20 tasks): criar PRD completo + sugerir sessao de pesquisa antes: "Feature complexa — recomendo uma sessao de pesquisa/discovery antes de preencher o PRD."
   Na duvida, classificar para cima.

3. **Criar arquivo:** copiar `.claude/specs/PRD_TEMPLATE.md` para `.claude/specs/prd-{id-em-kebab-case}.md`

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

6. **Registrar no SPECS_INDEX.md:**
   - Adicionar na secao "PRDs" (criar secao se nao existir)
   - Formato: `| {ID} | {Titulo} | rascunho | — | {resumo} |`

7. **Registrar no backlog** (opcional):
   - Perguntar: "Quer criar uma entrada no backlog para acompanhar este PRD?"
   - Se sim: criar com Tipo `Analise` via `/backlog-update`

8. **Informar o usuario:**
   - Path do arquivo criado
   - Classificacao de complexidade aplicada
   - Proximo passo: "Quando o PRD estiver aprovado, crie specs derivadas com `/spec {SPEC-ID} {Titulo}` e vincule a este PRD."
   - Lembrar que PRD `rascunho` precisa ser discutido/aprovado pelo time antes de gerar specs

---

### Modo Notion (PRDs via MCP)

Quando a secao `## Integracao Notion (specs)` existe no CLAUDE.md e o projeto usa PRDs no Notion.

1. **Ler configuracao do CLAUDE.md:**
   - `data_source_id` — ID da collection no Notion (pode ser a mesma de specs ou database separada para PRDs)
   - Template de PRD (se configurado na tabela de templates)

2. **Classificar complexidade:** mesma logica do modo repo. Pequeno = nao cria PRD.

3. **Coletar informacoes** (guiar analise de causa raiz — mesmas perguntas do modo repo)

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
     }
   }]
   ```
   Se nao houver template de PRD na database, criar a pagina sem template e preencher o conteudo usando o formato do PRD_TEMPLATE.md como referencia.

5. **Registrar no SPECS_INDEX.md** (se existir):
   - Secao "PRDs"
   - Formato: `| {ID} | {Titulo} | [Notion]({url}) | rascunho | — | {resumo} |`

6. **Informar o usuario:**
   - URL da pagina criada no Notion
   - Classificacao de complexidade
   - Proximo passo: vincular specs ao PRD conforme acoes forem priorizadas

---

### Modo Externo (PRD em outra ferramenta)

Quando PRDs vivem em Jira, Confluence, Google Docs, ou outra ferramenta.

1. **Pedir referencia:** "Qual a URL ou ID do PRD nessa ferramenta?"

2. **Registrar no SPECS_INDEX.md:**
   - Secao "PRDs"
   - Formato: `| {ID} | {Titulo} | [{ferramenta}]({url}) | rascunho | — | {resumo} |`

3. **Informar o usuario:**
   - Referencia registrada
   - Proximo passo: criar specs derivadas e vincular ao PRD

---

## Regras

- PRD criado sempre comeca como `rascunho`
- Pequeno nunca gera PRD — ir direto para spec ou backlog
- Sempre registrar no SPECS_INDEX.md na secao "PRDs"
- **Modo repo:** nomes de arquivo `prd-{id-kebab-case}.md` no diretorio `.claude/specs/`
- **Modo Notion:** criar via `notion-create-pages` — nunca criar arquivo local quando Notion esta configurado
- **Modo externo:** apenas registrar referencia — nao criar arquivo local
- Secoes obrigatorias: Problema, Causas, Evidencias, Porques, Como resolver
- Secoes opcionais para Medio: Historias de usuario, Restricoes, Metricas de sucesso
- Na duvida sobre complexidade, classificar para cima
- O PRD captura o "o que/por que/para quem" — nao detalhar "como implementar" (isso e da spec)
- PRD `rascunho` precisa ser aprovado pelo time antes de gerar specs
