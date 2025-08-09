#!/usr/bin/env bash

# MCP Dev Tools - Main Launcher (Root)
# This is a convenience wrapper that calls the actual script in scripts/server/

set -euo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Delegate to the actual implementation
exec "$THIS_DIR/scripts/server/start-mcp-dev-tools.sh" "$@"
