#!/bin/bash
# Instala ou atualiza as skills do claude-code-framework no diretório pessoal (~/.claude/skills/).
# Isso torna /setup-framework, /update-framework, /spec e /backlog-update disponíveis em qualquer projeto.
#
# Uso:
#   curl -fsSL <url-raw>/scripts/install-skills.sh | bash
#   # ou
#   git clone git@github.com:gabrielferreira/claude-code-framework.git /tmp/claude-code-framework
#   /tmp/claude-code-framework/scripts/install-skills.sh

set -euo pipefail

# Pre-requisitos
if ! command -v git &>/dev/null; then
  echo "ERROR: git nao encontrado. Instale git antes de continuar."
  exit 1
fi

# Detectar metodo de clone (SSH ou HTTPS)
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  REPO_URL="git@github.com:gabrielferreira/claude-code-framework.git"
else
  echo "SSH nao configurado. Usando HTTPS."
  REPO_URL="https://github.com/gabrielferreira/claude-code-framework.git"
fi

# Se rodou via clone local, usar o diretório do script como source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"

# Se não encontrou o framework no diretório pai, clonar
if [ ! -f "$FRAMEWORK_DIR/VERSION" ]; then
  echo "Framework não encontrado localmente. Clonando..."
  FRAMEWORK_DIR="/tmp/claude-code-framework"
  rm -rf "$FRAMEWORK_DIR"
  git clone "$REPO_URL" "$FRAMEWORK_DIR"
fi

VERSION=$(cat "$FRAMEWORK_DIR/VERSION")
DEST="$HOME/.claude/skills"

echo "Instalando skills do claude-code-framework v${VERSION}..."
echo ""

mkdir -p "$DEST"

SKILLS=(setup-framework update-framework spec-creator backlog-update)

for skill in "${SKILLS[@]}"; do
  if [ -d "$DEST/$skill" ]; then
    echo "  ↻ $skill (atualizado)"
  else
    echo "  + $skill (novo)"
  fi
  rm -rf "$DEST/$skill"
  cp -r "$FRAMEWORK_DIR/skills/$skill" "$DEST/$skill"
done

echo ""
echo "✔ Skills instaladas em $DEST (v${VERSION})"
echo ""
echo "Comandos disponíveis em qualquer projeto:"
echo "  /setup-framework    — instalar framework em um repo"
echo "  /update-framework   — atualizar framework instalado"
echo "  /spec               — criar nova spec"
echo "  /backlog-update     — gerenciar backlog"
