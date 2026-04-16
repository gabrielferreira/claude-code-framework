<!-- framework-tag: v2.49.0 framework-file: docs/VERIFY_HOOK.md -->
# Hook: Verificação pós-commit (verify.sh)

Hook que roda `scripts/verify.sh` automaticamente após cada `git commit`, sem bloquear a sessão e sem gastar tokens quando passa.

**O setup-framework configura este hook automaticamente** em `.claude/settings.json` quando detecta `scripts/verify.sh`. Esta documentação serve para configuração manual ou para entender como funciona.

## Por que usar

Sem este hook, o Claude Code não sabe que um commit introduziu falha no verify.sh — e pode continuar trabalhando em cima de código quebrado. Com ele:

- **Zero tokens quando passa** — silêncio total, a sessão segue normalmente
- **Acorda a sessão quando falha** — injeta apenas as linhas com `❌` como contexto, sem interromper o fluxo
- **Roda em background** — não bloqueia enquanto verifica

## Pré-requisitos

- `jq` instalado (`brew install jq` ou `apt install jq`)
- `scripts/verify.sh` existe no projeto e imprime linhas com `❌` nas falhas
- Sai com código não-zero em caso de falha

## Como o setup configura automaticamente

Ao rodar `/setup-framework`:

1. Detecta `scripts/verify.sh` (ou `scripts/check.sh`)
2. Verifica se `jq` está disponível
3. Faz merge do hook em `.claude/settings.json` (cria o arquivo se não existir)
4. Valida o JSON resultante
5. Registra no SETUP_REPORT.md

`.claude/settings.json` é versionado no repo — todos os devs compartilham o mesmo hook automaticamente.

## Configuração manual

Se preferir configurar sem rodar o setup, adicionar em `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"${CLAUDE_TOOL_INPUT_COMMAND:-}\" | grep -q 'git commit'; then FAILS=$(bash scripts/verify.sh 2>&1 | grep '❌' | head -20); if [ -n \"$FAILS\" ]; then echo \"$FAILS\" | jq -Rs '{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":(\"verify.sh falhou:\\n\" + .)}}'; exit 2; fi; fi"
          }
        ]
      }
    ]
  }
}
```

**Se o arquivo já tem conteúdo** (ex: permissões), fazer merge manual adicionando apenas a chave `hooks`.

**Se o script tem nome diferente** (ex: `scripts/check.sh`), substituir `scripts/verify.sh` no comando.

## Verificar

```bash
jq -e '.hooks.PostToolUse[0].hooks[0].command' .claude/settings.json
```

Deve retornar o comando sem erro.

## Testar

```bash
# Commit qualquer coisa — se verify.sh passar, silêncio total
git commit -m "test: hook verification"

# Para testar falha: introduzir temporariamente uma checagem que falhe no verify.sh,
# fazer commit e ver as linhas ❌ injetadas como contexto na sessão
```

## Desativar

Remover o bloco `PostToolUse` de `.claude/settings.json` ou apagar o arquivo.

## Limitações

- O hook detecta `git commit` via grep no comando Bash — commits feitos fora do Claude Code não disparam o hook
- Se `jq` não estiver instalado, o hook não é configurado automaticamente; instale e rode `/setup-framework` novamente ou configure manualmente
- Em monorepos, o hook roda o `scripts/verify.sh` da raiz — se quiser verificar um sub-projeto específico, adapte o caminho no comando
