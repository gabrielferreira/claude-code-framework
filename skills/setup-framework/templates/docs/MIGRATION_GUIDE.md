<!-- framework-tag: v2.17.2 framework-file: docs/MIGRATION_GUIDE.md -->

# Guia de Migracao

Como atualizar o claude-code-framework entre versoes e resolver problemas comuns de migracao.

## Verificar versao atual

```bash
grep "framework-tag:" CLAUDE.md
# ou verificar qualquer arquivo do framework:
grep -r "framework-tag:" .claude/ docs/ scripts/ --include="*.md"
```

A tag mostra a versao instalada no formato `framework-tag: vX.Y.Z`.

## Como atualizar

Execute a skill de atualizacao na raiz do projeto:

```
/update-framework
```

O comando detecta automaticamente a versao instalada, compara com o framework source, e aplica as mudancas de acordo com a estrategia de cada arquivo.

Para ver o que mudaria sem aplicar:

```
/update-framework --dry-run
```

## Notas de migracao por versao

### v2.4 para v2.5

- **Novas skills:** `security-review`, `seo-performance`, `syntax-check` e `golden-tests` adicionadas ao framework. Sao instaladas automaticamente como `structural`.
- **Novo agent:** `seo-audit` para analise automatizada de SEO e performance. Instalado como `overwrite`.
- **Acao necessaria:** nenhuma. O `/update-framework` adiciona os novos arquivos automaticamente.

### v2.3 para v2.4

- **Selecao de modelo nos agents:** campo `model:` adicionado ao frontmatter de todos os agents (opus, sonnet, haiku).
- **Guidelines de dispatch autonomo:** agents agora incluem orientacoes sobre quando devem ser acionados.
- **Acao necessaria:** nenhuma. Agents sao `overwrite` — substituidos automaticamente.

### v2.2 para v2.3

- **Campo `worktree` nos agents:** todos os agents ganharam `worktree: true/false` no frontmatter.
- **Secao worktrees no CLAUDE.md:** o template inclui nova secao sobre worktrees e subagents.
- **Acao necessaria:** revisar o diff do CLAUDE.md (estrategia `manual`) e incorporar a secao de worktrees manualmente.

## Estrategias de atualizacao

O `/update-framework` trata cada arquivo conforme sua estrategia no MANIFEST:

| Estrategia | O que acontece | Seus arquivos |
|---|---|---|
| **overwrite** | Substituido direto. Sem customizacao. | Agents, templates de spec |
| **structural** | Secoes novas adicionadas, removidas se obsoletas. Conteudo customizado preservado. | Skills, docs |
| **manual** | Mostra diff completo. Voce decide o que aplicar. | CLAUDE.md, PROJECT_CONTEXT.md, scripts |
| **skip** | Nunca tocado. 100% seu. | Specs, backlog, STATE.md |

## Conflitos no CLAUDE.md

O CLAUDE.md e sempre `manual` — o framework **nunca** aplica mudancas automaticamente nele. Quando o `/update-framework` detecta diferenca:

1. Mostra o diff entre o template atualizado e seu arquivo atual
2. Voce decide o que incorporar, secao por secao
3. Merge manual — copie as secoes novas que fazem sentido para o projeto

## Rollback

Se algo deu errado apos uma atualizacao:

```bash
# Ver commits recentes
git log --oneline -10

# Encontrar o commit antes do update
# Restaurar arquivos especificos
git checkout <commit-hash> -- .claude/agents/
git checkout <commit-hash> -- docs/

# Ou restaurar tudo de uma vez
git checkout <commit-hash> -- .claude/ docs/ scripts/
```

Nunca faca `git reset --hard` sem certeza — isso descarta todas as mudancas nao commitadas.
