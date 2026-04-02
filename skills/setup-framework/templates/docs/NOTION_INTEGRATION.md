<!-- framework-tag: v2.5.0 framework-file: docs/NOTION_INTEGRATION.md -->

# Integracao Notion

O framework suporta modo dual para gestao de specs e backlog: arquivos no repositorio e/ou paginas no Notion.

## Visao geral

As skills `/spec` e `/backlog-update` detectam automaticamente se o Notion esta disponivel. Se estiver, operam em modo Notion — criando paginas, preenchendo propriedades e atualizando status diretamente na database. Se nao, operam em modo repositorio com arquivos Markdown.

## Pre-requisitos

1. **Workspace Notion** com uma database para specs
2. **MCP Notion configurado** no Claude Code com acesso a database
3. **Templates na database** — o setup detecta e mapeia os templates disponiveis

## O que o framework NAO faz

- **Nao configura o MCP.** Voce precisa configurar o MCP Notion no Claude Code antes de usar o framework.
- **Nao pede tokens ou credenciais.** A autenticacao e gerenciada pelo MCP, fora do escopo do framework.
- **Nao cria databases.** A database de specs precisa existir antes do setup.
- **Nao gerencia permissoes.** Voce precisa compartilhar a database com a integracao Notion.

## Como o /setup-framework detecta Notion

Durante o setup, o framework:

1. Verifica se as tools do MCP Notion estao disponiveis
2. Pede o link da database de specs
3. Consulta a database para listar templates existentes
4. Gera a secao `## Integracao Notion (specs)` no CLAUDE.md do projeto

A secao gerada contem:

- `data_source_id` da database
- IDs dos templates mapeados (ex: Bug, Feature, Improvement)
- Mapeamento de propriedades (Status, Priority, Owner, etc.)

## Como /spec funciona em modo Notion

Quando a secao Notion existe no CLAUDE.md:

1. Classifica a spec (complexidade, tipo)
2. Seleciona o template correspondente na database
3. Cria uma pagina Notion a partir do template
4. Preenche propriedades: titulo, status, prioridade, owner
5. Escreve o conteudo da spec no corpo da pagina

## Como /backlog-update funciona em modo Notion

Em modo Notion, o `/backlog-update`:

1. Consulta a database para listar specs existentes
2. Atualiza propriedades (status, prioridade) conforme comandos
3. Sincroniza o SPECS_INDEX.md local com o estado do Notion

## Problemas comuns

| Problema | Solucao |
|---|---|
| MCP nao configurado | Configure o MCP Notion no Claude Code antes de rodar o setup |
| Database nao encontrada | Verifique se o link da database esta correto e compartilhado |
| Templates nao detectados | Crie pelo menos um template na database antes do setup |
| Propriedades nao mapeadas | Confirme que a database tem as propriedades esperadas (Status, Priority, etc.) |
| Secao Notion nao gerada | Rode `/setup-framework` novamente com o MCP configurado |
