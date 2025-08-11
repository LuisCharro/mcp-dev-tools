#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$THIS_DIR/../.." && pwd)"

# Load .env if present
if [ -f "$PROJECT_ROOT/.env" ]; then
	# shellcheck disable=SC2046
	export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs -I{} echo {})
fi
if [ -f "$PROJECT_ROOT/.env.local" ]; then
	# shellcheck disable=SC2046
	export $(grep -v '^#' "$PROJECT_ROOT/.env.local" | xargs -I{} echo {})
fi

# Validate required environment variables
REPO_ROOT="${REPO_ROOT:-}"
if [ -z "$REPO_ROOT" ]; then
	echo "❌ REPO_ROOT is not set. Please set it in .env or .env.local" >&2
	echo "   Example: REPO_ROOT=/path/to/your/project" >&2
	exit 1
fi

if [ ! -d "$REPO_ROOT" ]; then
	echo "❌ REPO_ROOT directory does not exist: $REPO_ROOT" >&2
	exit 1
fi

# Set defaults for configuration
MCP_REF_DIR="${MCP_REF_DIR:-$HOME/mcpServers/mcp-reference-servers}"
SAFE_WRITE="${SAFE_WRITE:-false}"
ALLOW_GLOBS="${ALLOW_GLOBS:-**/*}"
DENY_GLOBS="${DENY_GLOBS:-**/.env*,**/*.pem,**/id_*,**/.git/**,**/.ssh/**,**/secrets/**}"
MAX_FILE_SIZE="${MAX_FILE_SIZE:-1048576}"

# Display configuration at startup (send to stderr to avoid JSON parsing issues)
echo "🚀 Starting MCP Filesystem Server" >&2
echo "   REPO_ROOT: $REPO_ROOT" >&2
echo "   SAFE_WRITE: $SAFE_WRITE" >&2
echo "   ALLOW_GLOBS: $ALLOW_GLOBS" >&2
echo "   DENY_GLOBS: $DENY_GLOBS" >&2
echo "   MAX_FILE_SIZE: $MAX_FILE_SIZE bytes" >&2
echo "" >&2

# Check if MCP reference servers are available
if [ ! -f "$MCP_REF_DIR/src/filesystem/dist/index.js" ]; then
	echo "❌ MCP reference servers not found at: $MCP_REF_DIR" >&2
	echo "   Please install them or set MCP_REF_DIR to the correct path" >&2
	exit 1
fi

node "$MCP_REF_DIR/src/filesystem/dist/index.js" "$REPO_ROOT"
