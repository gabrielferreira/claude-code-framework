<!-- framework-tag: v2.49.0 framework-file: skills/setup-framework/NOTION_DETAILS.md -->
# Notion Details — setup-framework

> Conteudo condicional carregado pelo SKILL.md quando usuario escolhe modelo Notion.
> Nao editar sem atualizar o SKILL.md principal.

---

## Bloco F2 — Detalhes do modelo de specs (Notion/Externo)

**Se "Specs externas" ou "Hibrido":**
- Perguntar qual ferramenta: Jira, Linear, Notion, GitHub Issues, Confluence, outro
- Se hibrido: perguntar criterio de separacao (ex: "specs de produto no Jira, specs tecnicas/refatoracao no repo")

**Se ferramenta = Notion (com MCP conectado):**

O framework se integra nativamente com Notion via MCP. O setup nao configura autenticacao — apenas usa o MCP Notion que ja esta configurado no Claude Code do usuario.

> **Pre-requisito:** o MCP Notion precisa estar funcionando ANTES de rodar o setup.
> A configuracao do MCP e responsabilidade do usuario (token, OAuth, permissoes).
> O setup apenas detecta e usa — nao autentica nem configura o MCP.
>
> **Como verificar:** as tools `notion-fetch`, `notion-create-pages`, etc. devem aparecer na lista de tools disponiveis do Claude Code. Se nao aparecem, o usuario precisa configurar o MCP Notion primeiro.
>
> **Configuracao do MCP Notion** (referencia para o usuario):
> ```json
> // Em ~/.claude/settings.json ou .claude/settings.json
> {
>   "mcpServers": {
>     "notion": {
>       "command": "npx",
>       "args": ["-y", "@notionhq/notion-mcp-server"],
>       "env": {
>         "NOTION_TOKEN": "ntn_****"
>       }
>     }
>   }
> }
> ```
> Alternativa: usar `OPENAPI_MCP_HEADERS` com Bearer token (ver docs do `@notionhq/notion-mcp-server`).
> A database tambem precisa estar **compartilhada com a integration** no Notion: abrir database → "..." → "Connections" → adicionar a integration.

1. **Perguntar a URL completa da database de specs no Notion**
   - Exemplo: `https://www.notion.so/empresa/1cd1112ab3214e28bed8c09a71806d3f` ou `https://www.notion.so/1cd1112ab3214e28bed8c09a71806d3f?v=...`
   - A URL como o usuario a ve no browser.
2. **Fazer `notion-fetch` com a URL completa** para obter:
   - `data_source_id` (collection ID) — necessario para criar paginas
   - Schema da database (propriedades e opcoes)
   - Templates existentes (IDs e nomes)
   - **Se retornar erro 401/403:** o MCP Notion nao esta autenticado ou a database nao esta compartilhada com a integration. Orientar o usuario a verificar: (1) o token no settings.json esta correto, (2) a database esta compartilhada com a integration no Notion (menu "..." → "Connections")
3. **Apresentar os templates encontrados** e pedir para o usuario mapear cada complexidade:
   ```
   Templates encontrados na database:
   1. [TEMPLATE] Spec Pequena
   2. [TEMPLATE] Spec Média
   3. [TEMPLATE] Spec Grande/Complexa
   4. [TEMPLATE] Design Doc

   Mapeamento sugerido (confirme ou ajuste):
   - Pequeno  → 1. [TEMPLATE] Spec Pequena
   - Médio    → 2. [TEMPLATE] Spec Média
   - Grande   → 3. [TEMPLATE] Spec Grande/Complexa + 4. Design Doc (opcional)
   - Complexo → 3. [TEMPLATE] Spec Grande/Complexa + 4. Design Doc (obrigatório)
   ```
4. **Se nao encontrar templates:** avisar e perguntar se quer criar specs sem template (so propriedades)
5. **Detectar campos adicionais da database:**
   A partir do schema retornado pelo `notion-fetch`, identificar properties que NAO estao na lista padrao do framework:
   > Lista padrao: `Titulo`, `Status`, `Complexidade`, `Tipo`, `Severidade`, `Fase`, `Camadas`, `Impacto`, `Estimativa`, `Dominio`, `Projeto`, `Spec detail`, `Autor`, `Responsavel`, `Concluida em`

   Para cada propriedade extra encontrada no schema:
   - Apresentar ao usuario: nome, tipo (select, url, text, number, etc.), opcoes disponiveis se select
   - Perguntar: "Este campo deve ser preenchido ao criar specs? Como?"
     - **Perguntar ao usuario** → registrar como `Perguntar ao usuario`. Para campos select: registrar as opcoes disponiveis na coluna "Opcoes" (separadas por virgula) para que o `/spec` possa apresenta-las sem precisar consultar o Notion novamente
     - **Preencher com a URL/key do --from (origem)** → registrar como `auto: url-from`
     - **Preencher com o nome do projeto** → registrar como `auto: projeto`
     - **Deixar vazio** → registrar como `deixar vazio`
   - Se nao houver campos extras: omitir a secao "Campos adicionais" na configuracao
6. **Guardar configuracao** para uso pelo `/spec` e `/backlog-update` (ver secao sobre geracao no CLAUDE.md)

**Se ferramenta != Notion:**
- Perguntar formato de referencia: URL base (ex: `https://empresa.atlassian.net/browse/`) e prefixo de IDs (ex: `PROJ-`)

---

## Bloco 2b — PRD Notion

Se PRD opt-in e modelo Notion:

Perguntar: "PRDs ficam na mesma database de specs ou em database separada?"
- **Mesma database:** usar `data_source_id` existente com property `"Tipo": "PRD"`. Verificar se ha template de PRD na database
- **Database separada:** perguntar URL da database de PRDs. Fazer `notion-fetch` para obter `prd_data_source_id`. Adicionar secao `## Integracao Notion (PRDs)` no CLAUDE.md com o `prd_data_source_id` e templates mapeados
- Ainda criar `.claude/prds/PRDS_INDEX.md` local para rastreabilidade

---

## Secao 3.2 — Geracao do CLAUDE.md (Notion)

Se **Notion com MCP**: **OBRIGATORIO** adicionar secao `## Integracao Notion (specs)` no CLAUDE.md com a configuracao coletada. Sem esta secao, `/spec` e `/backlog-update` operam em modo local (arquivos .md) em vez de Notion:

```markdown
## Integracao Notion (specs)

- **Database URL:** {url}
- **Data source ID:** {data_source_id}
- **Templates por complexidade:**
  | Complexidade | Template | Template ID | Design Doc |
  |---|---|---|---|
  | Pequeno | {nome} | {id} | — |
  | Médio | {nome} | {id} | — |
  | Grande | {nome} | {id} | {id} (opcional) |
  | Complexo | {nome} | {id} | {id} (obrigatório) |
- **Campos adicionais:** (incluir apenas se houver campos custom alem dos padrao)
  | Campo Notion | Tipo | Obrigatorio | Como preencher | Opcoes |
  |---|---|---|---|---|
  | Frente de produto | select | sim | Perguntar ao usuario | Mobile, Web, Backend, Plataforma |
  | Origem | url | nao | auto: url-from | — |

### Regras de integracao
- `/spec` cria pagina no Notion usando `notion-create-pages` com o template correto
- `/backlog-update done` atualiza Status no Notion via `notion-update-page`
- Para ler uma spec: usar `notion-fetch` com o URL da pagina
- Nunca criar specs locais em `.claude/specs/` — Notion e a fonte de verdade
- SPECS_INDEX.md serve como indice local com links para o Notion
```

Se **PRD opt-in + Notion com database separada de PRDs:** adicionar tambem:

```markdown
## Integracao Notion (PRDs)

- **Database URL:** {url}
- **Data source ID:** {prd_data_source_id}
- **Templates de PRD:**
  | Complexidade | Template | Template ID |
  |---|---|---|
  | Médio | {nome} | {id} |
  | Grande | {nome} | {id} |
  | Complexo | {nome} | {id} |

### Regras de integracao
- `/prd` cria pagina no Notion usando `notion-create-pages` na database de PRDs
- Para ler um PRD: usar `notion-fetch` com o URL da pagina
- PRDS_INDEX.md serve como indice local com links para o Notion
```

---

## Secao 3.4 — SPECS_INDEX.md modo Notion

Se **modelo externo (incluindo Notion):**
- Usar a variante external comentada no template (descomentar e remover a variante local)
- Colunas: `ID | Spec | Status | Owner | Fonte | Resumo` (mesma estrutura, Fonte = External ID)
- Preencher regras de acesso com a ferramenta escolhida no Bloco 2
- Adicionar instrucao: "Specs completas vivem em {ferramenta}. Este indice serve como ponte."

---

## Secao 3.5 — Skip de arquivos locais quando Notion

Se **modelo externo (incluindo Notion):**
- **NAO copiar** TEMPLATE.md, backlog.md, STATE.md nem DESIGN_TEMPLATE.md locais
- **NAO criar** `.claude/specs/` — specs vivem na ferramenta externa
- Criar apenas `SPECS_INDEX.md` na raiz como indice de referencia (links para Notion/Jira/etc.)
- Se Notion: a `/spec` cria paginas direto no Notion via `notion-create-pages`. O SPECS_INDEX.md serve so como ponte local → Notion.
- Se outra ferramenta: criar `.claude/specs/README.md` com instrucoes de como referenciar specs externas

> **CRITICO para Notion:** o backlog do projeto **NAO e local** (`backlog.md`). O backlog vive no Notion. NAO copiar `backlog.md` para o projeto. A skill `/backlog-update` deve atualizar direto no Notion via MCP. Se o CLAUDE.md tiver a secao "Integracao Notion (specs)", a `/spec` e `/backlog-update` operam em modo Notion automaticamente.

---

## Auditoria Categoria 1 — Severidades Notion

A severidade de arquivos depende do modelo de specs escolhido:

| Arquivo | Modo repo | Modo Notion | Modo externo |
|---|---|---|---|
| `CLAUDE.md` | 🔴 critico | 🔴 critico | 🔴 critico |
| `SPECS_INDEX.md` | 🔴 critico | 🔴 critico (ponte local→Notion) | 🔴 critico |
| `SPECS_INDEX_ARCHIVE.md` | 🟡 medio | 🟡 medio | 🟡 medio |
| `.claude/specs/TEMPLATE.md` | 🔴 critico | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |
| `.claude/specs/backlog.md` | 🔴 critico | ⚪ **desnecessario** — backlog e a database do Notion | ⚪ desnecessario |
| `scripts/verify.sh` | 🔴 critico | 🔴 critico | 🔴 critico |
| `.claude/specs/STATE.md` | 🟠 alto | 🟠 alto | 🟠 alto |
| `.claude/specs/DESIGN_TEMPLATE.md` | 🟡 medio | ⚪ **desnecessario** — templates vivem no Notion | ⚪ desnecessario |

---

## Secao 3.10 — Slash commands Notion

Se ferramenta = Notion (com MCP):
Os SKILL.md de `/spec` e `/backlog-update` ja suportam Notion nativamente — basta que a secao "Integracao Notion" exista no CLAUDE.md (gerada na secao 3.2). As skills detectam essa secao e usam os MCP tools do Notion automaticamente:
- `/spec` cria pagina no Notion com template correto e preenche propriedades
- `/backlog-update` le e atualiza propriedades direto no Notion

Se ferramenta != Notion (sem MCP):
- `/spec` adaptado: em vez de criar arquivo local, instrucao para registrar no SPECS_INDEX.md com link externo
- Sugerir formato de ID consistente com a ferramenta (ex: `PROJ-123`)
- `/backlog-update` adaptado: acao `done` atualiza SPECS_INDEX.md com status, sem mover arquivo local
