#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load .env if present
if [ -f "$THIS_DIR/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi

REPO_PORT="${PORT:-3333}"
SEARCH_PORT="${SEARCH_PORT:-3334}"
GIT_PORT="${GIT_PORT:-3335}"

# Start filesystem server
PORT="$REPO_PORT" "$THIS_DIR/start-http.sh" &> "$THIS_DIR/mcp-gateway.log" &
FS_PID=$!

# Start search server
SEARCH_PORT="$SEARCH_PORT" "$THIS_DIR/start-search.sh" &> "$THIS_DIR/mcp-search.log" &
SEARCH_PID=$!

# Placeholder for git server (coming soon)
# GIT_PORT="$GIT_PORT" "$THIS_DIR/start-git-http.sh" &> "$THIS_DIR/mcp-git.log" &
# GIT_PID=$!

sleep 2

echo ""
echo "✅ Started servers:"
echo "  - mcp-dev-tools: http://127.0.0.1:$REPO_PORT/    (PID $FS_PID)"
echo "  - repo-search:   http://127.0.0.1:$SEARCH_PORT/  (PID $SEARCH_PID)"
echo "  - repo-git:      http://127.0.0.1:$GIT_PORT/     (coming soon)"
echo ""
echo "Logs:"
echo "  tail -f $THIS_DIR/mcp-gateway.log $THIS_DIR/mcp-search.log"
