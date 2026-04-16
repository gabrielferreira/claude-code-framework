<!-- framework-tag: v2.48.1 framework-file: skills/update-framework/NOTION_UPDATE_DETAILS.md -->
# Notion Update Details — update-framework

> Detalhes de integracao Notion no update: filtros pre-aplicacao (Passos 1-4) + Fase 4b completa.
> Carregado pelo SKILL.md quando `## Integracao Notion` e detectado no CLAUDE.md do projeto.

---

## Filtros pre-aplicacao — Passos Notion (1-4)

> Estes passos fazem parte da Fase 3.0 e devem ser executados ANTES de qualquer sub-fase (3.1, 3.2, etc.).
> So se aplicam quando `SPEC_MODE=notion`.

### Passo 1 — Detectar modo spec

Ler o `CLAUDE.md` do projeto e verificar se contem a string `## Integracao Notion`:
- Se sim: `SPEC_MODE=notion`
- Se nao: `SPEC_MODE=repo`

Se `SPEC_MODE=repo`, pular para a Fase 3.1. Os passos abaixo sao APENAS para `SPEC_MODE=notion`.

### Passo 2 — Remover arquivos locais desnecessarios

Executar estes comandos exatos. Para cada arquivo que existir, fazer backup e remover:

```bash
# Backup
mkdir -p .claude/.update-backup/notion-cleanup
cp .claude/specs/backlog.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/TEMPLATE.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/DESIGN_TEMPLATE.md .claude/.update-backup/notion-cleanup/ 2>/dev/null
cp .claude/specs/backlog-format.md .claude/.update-backup/notion-cleanup/ 2>/dev/null

# Remover (sem perguntar — em Notion estes arquivos nao devem existir)
rm -f .claude/specs/backlog.md
rm -f .claude/specs/TEMPLATE.md
rm -f .claude/specs/DESIGN_TEMPLATE.md
rm -f .claude/specs/backlog-format.md
```

Informar ao usuario quais arquivos foram removidos.

### Passo 3 — Limpar CLAUDE.md de referencias a artefatos locais

O CLAUDE.md do projeto pode ter secoes geradas pelo setup que referenciam arquivos locais que nao existem mais em modo Notion. **Ler o CLAUDE.md inteiro** e procurar CADA um destes padroes. Para cada padrao encontrado, aplicar a acao descrita:

| # | O que procurar | Acao |
|---|---|---|
| 1 | Secao `### Padrao do backlog` (qualquer H3 que mencione "backlog" e referencie `.claude/specs/backlog.md`) | **Remover a secao inteira** (H3 ate o proximo H2/H3). Backlog vive no Notion. |
| 2 | Linha contendo `Specs tecnicas locais:` ou `specs/` seguido de `(ativas)` e `done/` | **Substituir** por: `Specs: consultar SPECS_INDEX.md para localizar. Specs vivem na database do Notion (ver secao "Integracao Notion").` |
| 3 | Qualquer referencia a `.claude/specs/backlog.md` como local de backlog | **Remover** a linha ou substituir por referencia ao Notion |
| 4 | Linha tipo `backlog.md` na secao de estrutura de arquivos do projeto | **Remover** a linha |
| 5 | Secao mencionando `TEMPLATE.md` como template local para specs | **Remover** ou substituir por: "Templates vivem no Notion (ver secao Integracao Notion)." |

**Procedimento para cada padrao:**
1. Usar `grep -n` no CLAUDE.md para encontrar as linhas
2. Mostrar ao usuario o que encontrou e o que vai fazer
3. Aplicar a edicao (remover ou substituir)
4. Confirmar que a edicao foi aplicada

Se nenhum padrao for encontrado, informar: "CLAUDE.md ja esta limpo de referencias locais."

### Passo 4 — Excluir da lista de aplicacao

Os seguintes arquivos NAO devem ser tocados em NENHUMA sub-fase posterior (3.1, 3.2, 3.3, 3.4):
- `.claude/specs/TEMPLATE.md`
- `.claude/specs/backlog.md`
- `.claude/specs/DESIGN_TEMPLATE.md`
- `.claude/specs/backlog-format.md`

Se algum deles aparece no diff do framework, **ignorar silenciosamente**. Nao copiar, nao atualizar, nao mencionar como pendencia.

Informar no relatorio final: "Modo Notion detectado. Removidos {N} arquivos locais desnecessarios. CLAUDE.md limpo de {M} referencias a artefatos locais."

---

## Fase 4b — Verificar integracao Notion

> **Nota:** o update nao configura autenticacao do MCP Notion — apenas usa o que ja esta configurado.
> Se o MCP Notion nao estiver funcionando, orientar o usuario a configurar antes (ver docs do `/setup-framework`).

Detectar se o projeto usa Notion para specs. Sinais:
- CLAUDE.md menciona "Notion" ou "specs externas"
- SPECS_INDEX.md tem colunas de External ID ou links notion.so
- Existe `.claude/specs/README.md` com instrucoes de referencia externa

### Cenario A — Usa Notion mas NAO tem secao `## Integracao Notion (specs)` no CLAUDE.md

Este e o caso mais comum em projetos que atualizaram de v2.0.0 para v2.1.0+. O CLAUDE.md foi gerado antes da integracao nativa existir.

1. Informar: "O projeto usa specs no Notion mas o CLAUDE.md nao tem a configuracao de integracao nativa. Sem ela, `/spec` e `/backlog-update` nao conseguem criar/atualizar specs no Notion automaticamente."
2. Perguntar a **URL completa** da database de specs no Notion (como aparece no browser)
3. Fazer `notion-fetch` com a URL completa para obter dados da database
   - **Se retornar erro 401/403:** o MCP Notion nao esta autenticado ou a database nao esta compartilhada com a integration. Orientar: (1) verificar token no settings.json (`NOTION_TOKEN`), (2) compartilhar database com a integration no Notion (menu "..." -> "Connections")
4. Detectar data_source_id, schema e templates
5. Apresentar templates encontrados e pedir mapeamento por complexidade (mesmo fluxo do `/setup-framework` Bloco 2)
6. **Detectar campos adicionais** — mesmo fluxo do `/setup-framework` Bloco 2, passo 5: identificar properties extra no schema, perguntar regra de preenchimento para cada uma, gravar opcoes de select
7. **Inserir a secao `## Integracao Notion (specs)` no CLAUDE.md existente** — incluindo tabela "Campos adicionais" se houver — adicionar antes da ultima secao, sem alterar o restante do arquivo
8. Confirmar com o usuario que a secao foi adicionada

> **Importante:** esta e a unica situacao em que o `/update-framework` modifica o CLAUDE.md sem ser por diff do template. A secao Notion e config do projeto, nao conteudo do framework.

### Cenario B — Ja tem a secao `## Integracao Notion (specs)`

1. Fazer `notion-fetch` com a **URL completa** da database configurada no CLAUDE.md (nao extrair database_id)
2. Comparar template IDs configurados com os templates que existem na database
3. Se algum template foi removido/renomeado -> avisar e sugerir atualizar a tabela
4. Se ha templates novos na database que nao estao mapeados -> informar
5. **Verificar campos adicionais** (se a tabela "Campos adicionais" existir no CLAUDE.md):
   - Comparar cada campo listado com o schema atual da database
   - Se algum campo foi removido/renomeado na database -> avisar: "Campo '{nome}' nao encontrado na database. Atualizar a tabela 'Campos adicionais' em `## Integracao Notion (specs)`."
   - Se campo do tipo `select` e as opcoes mudaram -> informar as novas opcoes e perguntar se quer atualizar a coluna "Opcoes" no CLAUDE.md

### Cenario C — Nao usa Notion

Nada a fazer. Seguir para Fase 4c.

### Erros comuns de Notion no update

| Erro | Causa provavel | Acao |
|---|---|---|
| "notion-fetch failed" ou timeout | MCP Notion nao configurado ou token expirado | Avisar usuario: "MCP Notion nao esta acessivel. Pulando sync com Notion. Configure o MCP e rode /update-framework novamente." |
| "database not found" (404) | Database deletada ou URL incorreta no CLAUDE.md | Avisar: "Database Notion nao encontrada. Verifique a URL em ## Integracao Notion." |
| "unauthorized" (401/403) | Token sem acesso a database | Avisar: "Sem permissao para acessar a database Notion. Verifique se o MCP tem acesso." |
| Template IDs invalidos | Templates removidos da database | Listar IDs invalidos e sugerir atualizar secao Notion do CLAUDE.md |

**Regra:** Falha de Notion NUNCA bloqueia o update. Se Notion nao esta acessivel, pular a fase de sync e avisar. O update de arquivos locais continua normalmente.
