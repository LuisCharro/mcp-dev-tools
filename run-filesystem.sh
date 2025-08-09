#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="${REPO_ROOT:-/Users/luis/Repos/PDFExtractorAI}"
MCP_REF_DIR="/Users/luis/mcpServers/mcp-reference-servers"

node "$MCP_REF_DIR/src/filesystem/dist/index.js" "$REPO_ROOT"
