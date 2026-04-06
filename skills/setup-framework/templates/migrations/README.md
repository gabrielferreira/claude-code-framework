# Migrations

> Guias de migracao manual entre versoes do framework — como migrations de banco de dados, mas para o claude-code-framework.

## O que e isso

Cada arquivo neste diretorio descreve **exatamente o que mudou** entre duas versoes e **como aplicar cada mudanca manualmente**. E a alternativa ao `/update-framework` para quem quer controle total sobre o que entra no projeto.

## Quando usar

| Cenario | Recomendacao |
|---|---|
| Quer atualizar tudo de uma vez | Use `/update-framework` |
| Quer escolher o que aplicar | Use as migrations |
| Quer entender o que mudou antes de decidir | Use as migrations |
| Esta em ambiente sem Claude Code | Use as migrations |
| Precisa justificar mudancas pro time | Use as migrations (servem como documentacao) |

## Como usar

1. Identifique sua versao atual:
   ```bash
   grep "framework-tag:" CLAUDE.md | head -1
   # ou
   cat .claude/specs/TEMPLATE.md | head -1
   ```

2. Aplique as migrations **em sequencia** (nao pule versoes):
   ```
   v2.10.0-to-v2.10.1.md  →  primeiro
   v2.10.1-to-v2.11.0.md  →  depois
   v2.11.0-to-v3.0.0.md   →  por ultimo
   ```

3. Para cada migration, siga o passo-a-passo. Cada acao tem:
   - **O que mudou** — descricao da mudanca
   - **Estrategia** — overwrite (substituir), structural (adicionar/remover secoes), ou manual (voce decide)
   - **Como aplicar** — instrucoes concretas com diffs ou comandos
   - **Impacto** — o que quebra se nao aplicar

4. Apos aplicar, atualize o `framework-tag` nos arquivos tocados para a versao nova.

## Convencao de nomes

```
v{de}-to-v{para}.md
```

Exemplos:
- `v2.10.0-to-v2.10.1.md` (patch — geralmente poucas mudancas)
- `v2.10.1-to-v2.11.0.md` (minor — features novas)
- `v2.11.0-to-v3.0.0.md` (major — breaking changes, leia com atencao)

## Geracao automatica

As migrations sao geradas automaticamente durante o processo de release do framework. Cada release cria um arquivo de migration baseado no `git diff` entre tags, classificado pelas estrategias do MANIFEST.md.

## Nota

As migrations sao **informativas e opcionais** — o `/update-framework` continua sendo a forma recomendada de atualizar. As migrations existem para dar visibilidade e controle a quem prefere aplicar manualmente.
