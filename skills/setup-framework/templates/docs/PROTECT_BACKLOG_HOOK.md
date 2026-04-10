<!-- framework-tag: v2.37.2 framework-file: docs/PROTECT_BACKLOG_HOOK.md -->
# Hook: Protect Backlog

Hook opcional que impede edição direta nos arquivos de backlog e SPECS_INDEX, forçando o uso dos slash commands `/backlog-update` e `/spec`.

## Por que usar

Sem este hook, é fácil editar acidentalmente o backlog.md com o Editor/Write tool durante uma sessão, quebrando o formato ou adicionando itens sem spec. O hook bloqueia a edição e mostra a mensagem correta.

## Como configurar

### 1. Criar o script do hook

Criar `.claude/hooks/protect-backlog.sh`:

```bash
#!/bin/bash
# Hook: bloqueia edição direta em backlog e SPECS_INDEX
# Permite bypass quando slash command está ativo (flag temporário)

PROTECTED_FILES="backlog-pending.md|backlog-done.md|SPECS_INDEX.md"
FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"

# Se não tem file path, deixar passar
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Se slash command está ativo, permitir
if [ -f "/tmp/.claude-slash-cmd-active" ]; then
  exit 0
fi

# Verificar se o arquivo é protegido
if echo "$FILE_PATH" | grep -qE "$PROTECTED_FILES"; then
  echo "BLOCK: Arquivo protegido. Use o slash command correspondente:"
  echo "  - Backlog: /backlog-update {ID} {ação}"
  echo "  - Specs: /spec {ID} {Título}"
  echo "  - Para edição manual: remova temporariamente este hook em .claude/settings.json"
  exit 2
fi

exit 0
```

```bash
chmod +x .claude/hooks/protect-backlog.sh
```

### 2. Configurar em settings.json

Adicionar em `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": ".claude/hooks/protect-backlog.sh \"$CLAUDE_TOOL_INPUT_FILE_PATH\""
          }
        ]
      }
    ]
  }
}
```

### 3. Testar

Tentar editar `backlog-pending.md` diretamente — deve ser bloqueado com a mensagem acima.

## Desativar temporariamente

Se precisar editar manualmente (ex: migração, correção de formato):
1. Remover ou comentar o hook em `.claude/settings.json`
2. Fazer a edição
3. Reativar o hook

## Limitações

- O hook usa `/tmp/.claude-slash-cmd-active` como flag — se a sessão crashar durante um slash command, o flag pode ficar residual. Limpar com `rm /tmp/.claude-slash-cmd-active`.
- O hook só protege via Claude Code (Edit/Write tools). Edições via git, editor externo ou CLI não são bloqueadas.
