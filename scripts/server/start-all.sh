#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$THIS_DIR/../.." && pwd)"

# Load .env if present
if [ -f "$PROJECT_ROOT/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs -I{} echo {})
fi

REPO_PORT="${PORT:-3333}"
SEARCH_PORT="${SEARCH_PORT:-3334}"
GIT_PORT="${GIT_PORT:-3335}"

# Start filesystem server
PORT="$REPO_PORT" "$THIS_DIR/start-http.sh" &> "$PROJECT_ROOT/mcp-gateway.log" &
FS_PID=$!

# Start search server
SEARCH_PORT="$SEARCH_PORT" "$THIS_DIR/start-search.sh" &> "$PROJECT_ROOT/mcp-search.log" &
SEARCH_PID=$!

# Placeholder for git server (coming soon)
# GIT_PORT="$GIT_PORT" "$THIS_DIR/start-git-http.sh" &> "$PROJECT_ROOT/mcp-git.log" &
# GIT_PID=$!

sleep 2

echo ""
echo "✅ Started servers:"
echo "  - mcp-dev-tools: http://127.0.0.1:$REPO_PORT/    (PID $FS_PID)"
echo "  - repo-search:   http://127.0.0.1:$SEARCH_PORT/  (PID $SEARCH_PID)"
echo "  - repo-git:      http://127.0.0.1:$GIT_PORT/     (coming soon)"
echo ""
echo "Logs:"
echo "  tail -f $PROJECT_ROOT/mcp-gateway.log $PROJECT_ROOT/mcp-search.log"
