#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load .env if present
if [ -f "$THIS_DIR/.env" ]; then
	# shellcheck disable=SC2046
	export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi
if [ -f "$THIS_DIR/.env.local" ]; then
	# shellcheck disable=SC2046
	export $(grep -v '^#' "$THIS_DIR/.env.local" | xargs -I{} echo {})
fi

REPO_ROOT="${REPO_ROOT:-}"
if [ -z "$REPO_ROOT" ]; then
	echo "REPO_ROOT is not set. Please set it in .env or environment."
	exit 1
fi
MCP_REF_DIR="/Users/luis/mcpServers/mcp-reference-servers"

# Safety defaults: read-only, deny symlinks, allow common code/doc types
ALLOW_GLOBS=("**/*.cs" "**/*.ts" "**/*.tsx" "**/*.js" "**/*.jsx" "**/*.json" "**/*.md" "**/*.yml" "**/*.yaml" "**/*.sql")

node "$MCP_REF_DIR/src/filesystem/dist/index.js" "$REPO_ROOT"
