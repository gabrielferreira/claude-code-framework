#!/bin/bash
# release.sh — Gera nova versão do framework
# USO EXCLUSIVO no repo do framework. NAO e copiado para projetos.
#
# Uso:
#   ./scripts/release.sh patch   # 2.2.1 → 2.2.2
#   ./scripts/release.sh minor   # 2.2.1 → 2.3.0
#   ./scripts/release.sh major   # 2.2.1 → 3.0.0
#   ./scripts/release.sh 2.5.0   # versão explícita
#
# O que faz:
#   1. Calcula a nova versão (ou usa a informada)
#   2. Atualiza VERSION
#   3. Atualiza plugin.json
#   4. Atualiza todos os framework-tags nos .md
#   5. Commita
#   6. Cria tag
#   7. Pergunta se quer fazer push

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

cd "$ROOT"

# --- Validações ---
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory sujo. Commite ou stash antes de fazer release."
  exit 1
fi

CURRENT=$(cat VERSION | tr -d '[:space:]')
echo "Versão atual: v${CURRENT}"

# --- Calcular nova versão ---
BUMP="${1:-}"

if [ -z "$BUMP" ]; then
  echo "Uso: ./scripts/release.sh [patch|minor|major|X.Y.Z]"
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP" in
  patch)
    NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
    ;;
  minor)
    NEW_VERSION="${MAJOR}.$((MINOR + 1)).0"
    ;;
  major)
    NEW_VERSION="$((MAJOR + 1)).0.0"
    ;;
  *)
    # Versão explícita
    if [[ "$BUMP" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      NEW_VERSION="$BUMP"
    else
      echo "❌ Formato inválido: $BUMP (esperado: patch, minor, major ou X.Y.Z)"
      exit 1
    fi
    ;;
esac

echo "Nova versão: v${NEW_VERSION}"
echo ""

# --- Verificar se tag já existe ---
if git tag -l "v${NEW_VERSION}" | grep -q .; then
  echo "❌ Tag v${NEW_VERSION} já existe."
  exit 1
fi

# --- 1. Atualizar VERSION ---
echo "$NEW_VERSION" > VERSION
echo "✅ VERSION → ${NEW_VERSION}"

# --- 2. Atualizar plugin.json ---
if [ -f ".claude-plugin/plugin.json" ]; then
  sed -i '' "s/\"version\": \".*\"/\"version\": \"${NEW_VERSION}\"/" .claude-plugin/plugin.json
  echo "✅ plugin.json → ${NEW_VERSION}"
fi

# --- 3. Atualizar framework-tags ---
OLD_TAG="v${CURRENT}"
NEW_TAG="v${NEW_VERSION}"

COUNT=$(grep -rl "framework-tag: ${OLD_TAG}" --include="*.md" . | wc -l | tr -d ' ')

if [ "$COUNT" -eq "0" ]; then
  # Tentar sem v prefix ou com qualquer versão
  COUNT=$(grep -rl "framework-tag: v" --include="*.md" . | wc -l | tr -d ' ')
  if [ "$COUNT" -gt "0" ]; then
    grep -rl "framework-tag: v" --include="*.md" . | xargs sed -i '' "s/framework-tag: v[0-9]*\.[0-9]*\.[0-9]*/framework-tag: ${NEW_TAG}/g"
    echo "✅ ${COUNT} framework-tags → ${NEW_TAG}"
  else
    echo "⚠️  Nenhum framework-tag encontrado"
  fi
else
  grep -rl "framework-tag: ${OLD_TAG}" --include="*.md" . | xargs sed -i '' "s/framework-tag: ${OLD_TAG}/framework-tag: ${NEW_TAG}/g"
  echo "✅ ${COUNT} framework-tags → ${NEW_TAG}"
fi

# --- 4. Commit ---
echo ""
git add -A
git commit -m "release: v${NEW_VERSION}

Bump VERSION, plugin.json e framework-tags."

echo "✅ Commit criado"

# --- 5. Tag ---
git tag "v${NEW_VERSION}"
echo "✅ Tag v${NEW_VERSION} criada"

# --- 6. Push? ---
echo ""
read -p "Fazer push (branch + tag)? [y/N] " PUSH
if [[ "$PUSH" =~ ^[yY]$ ]]; then
  git push
  git push --tags
  echo "✅ Push feito"
else
  echo "Para fazer push depois:"
  echo "  git push && git push --tags"
fi

echo ""
echo "🎉 Release v${NEW_VERSION} concluída!"
