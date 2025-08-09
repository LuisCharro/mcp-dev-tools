#!/usr/bin/env bash

# MCP Dev Tools - HTTP/SSE Smoke Test
# - Verifies supergateway is listening
# - Opens SSE and captures sessionId
# - Sends initialize and tools/list JSON-RPC messages
# - Waits for responses on SSE and reports PASS/FAIL

set -euo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$THIS_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load env (project then local overrides)
if [ -f "$PROJECT_ROOT/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs -I{} echo {})
fi
if [ -f "$PROJECT_ROOT/.env.local" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$PROJECT_ROOT/.env.local" | xargs -I{} echo {})
fi

PORT="${PORT:-3333}"
BASE_URL="http://127.0.0.1:${PORT}"

echo ""
echo "🚦 MCP HTTP/SSE Smoke Test (port ${PORT})"
echo "======================================="
echo ""

fail() { echo -e "${RED}✖ $*${NC}"; exit 1; }
warn() { echo -e "${YELLOW}⚠ $*${NC}"; }
pass() { echo -e "${GREEN}✔ $*${NC}"; }

# 1) Check gateway is listening
if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  pass "Gateway listening on ${PORT}"
else
  fail "Gateway not listening on ${PORT}. Start it with ./scripts/server/start-mcp-dev-tools.sh or PORT=${PORT} ./scripts/server/start-http.sh --port ${PORT}"
fi

# 2) Open SSE and capture sessionId
WORKDIR=$(mktemp -d 2>/dev/null || mktemp -d -t mcp-smoke)
SSE_LOG="$WORKDIR/sse.log"
SESSION=""

cleanup() {
  [ -n "${SSE_PID:-}" ] && kill "$SSE_PID" >/dev/null 2>&1 || true
  rm -rf "$WORKDIR" 2>/dev/null || true
}
trap cleanup EXIT

# Open SSE stream in background
( curl -sN --no-buffer "$BASE_URL/sse" > "$SSE_LOG" ) &
SSE_PID=$!

# Wait for sessionId to appear
for i in {1..50}; do
  if grep -q "sessionId=" "$SSE_LOG" 2>/dev/null; then break; fi
  sleep 0.1
done

if grep -q "sessionId=" "$SSE_LOG" 2>/dev/null; then
  SESSION=$(grep -Eo 'sessionId=[0-9a-fA-F-]+' "$SSE_LOG" | head -1 | cut -d= -f2)
fi

if [ -z "$SESSION" ]; then
  echo "--- SSE (head) ---"; sed -n '1,80p' "$SSE_LOG" || true
  fail "Failed to obtain sessionId from SSE"
fi
pass "SSE session established (sessionId=$SESSION)"

# Helper: wait for SSE pattern
wait_for_sse() {
  local pattern="$1"; local max_tries="${2:-50}"; local delay="${3:-0.1}"
  for _ in $(seq 1 "$max_tries"); do
    if grep -Eq "$pattern" "$SSE_LOG" 2>/dev/null; then return 0; fi
    sleep "$delay"
  done
  return 1
}

# 3) Send initialize and verify SSE response
INIT_JSON="$WORKDIR/init.json"
cat > "$INIT_JSON" <<JSON
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0.1.0"}}}
JSON

HTTP_R=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/message?sessionId=$SESSION" -H "Content-Type: application/json" --data-binary @"$INIT_JSON" || true)
if [ "$HTTP_R" != "202" ] && [ "$HTTP_R" != "200" ]; then
  fail "initialize POST returned HTTP $HTTP_R"
fi

if wait_for_sse '"id"\s*:\s*1' 80 0.1 && wait_for_sse '"serverInfo"' 80 0.1; then
  pass "initialize acknowledged on SSE"
else
  echo "--- SSE (tail) ---"; tail -n 80 "$SSE_LOG" || true
  fail "Did not observe initialize response on SSE"
fi

# 4) Send tools/list and verify SSE response
LIST_JSON="$WORKDIR/list.json"
cat > "$LIST_JSON" <<JSON
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
JSON

HTTP_R=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/message?sessionId=$SESSION" -H "Content-Type: application/json" --data-binary @"$LIST_JSON" || true)
if [ "$HTTP_R" != "202" ] && [ "$HTTP_R" != "200" ]; then
  fail "tools/list POST returned HTTP $HTTP_R"
fi

if wait_for_sse '"id"\s*:\s*2' 80 0.1 && wait_for_sse '"tools"\s*:\s*\[' 80 0.1; then
  pass "tools/list returned tools on SSE"
else
  echo "--- SSE (tail) ---"; tail -n 80 "$SSE_LOG" || true
  fail "Did not observe tools/list response on SSE"
fi

echo ""
pass "Smoke test passed!"
echo "(Tip) tail -f mcp-gateway.log for live server logs"
