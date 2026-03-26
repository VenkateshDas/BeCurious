#!/bin/bash

# publish.sh — Sync Obsidian Published Articles → Quartz → GitHub Pages
# Usage: ./publish.sh            (sync + deploy)
#        ./publish.sh --preview  (local preview only, no deploy)

set -e

# ─── Paths ───────────────────────────────────────────────────────────────────
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Tiny experiments/Published Articles"
QUARTZ_DIR="$HOME/BeCurious"
CONTENT_DIR="$QUARTZ_DIR/content"

# ─── Node version guard ───────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm use 22 --silent 2>/dev/null || true

# ─── Flags ────────────────────────────────────────────────────────────────────
PREVIEW=false
if [ "$1" = "--preview" ]; then
  PREVIEW=true
fi

echo "🌱 BeCurious — publish pipeline"
echo "  Source : $VAULT"
echo "  Target : $CONTENT_DIR"
echo ""

# ─── Sync vault → Quartz content ─────────────────────────────────────────────
echo "→ Syncing content..."
rsync -av --delete \
  --exclude="drafts/" \
  --exclude=".obsidian/" \
  --exclude="*.canvas" \
  --exclude=".DS_Store" \
  "$VAULT/" "$CONTENT_DIR/"

echo ""

# ─── Preview mode: serve locally and exit ────────────────────────────────────
if [ "$PREVIEW" = true ]; then
  echo "→ Starting local preview at http://localhost:8080"
  cd "$QUARTZ_DIR"
  npx quartz build --serve
  exit 0
fi

# ─── Build ────────────────────────────────────────────────────────────────────
echo "→ Building site..."
cd "$QUARTZ_DIR"
npx quartz build

# ─── Deploy ───────────────────────────────────────────────────────────────────
echo "→ Deploying to GitHub..."
git add -A
git commit -m "publish: $(date '+%Y-%m-%d %H:%M')" || echo "  Nothing new to commit."
git push origin main

echo ""
echo "✓ Live at https://venkateshdas.github.io/BeCurious"
echo "  (GitHub Actions will build in ~2 min)"
