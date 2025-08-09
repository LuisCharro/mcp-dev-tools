# MCP Dev Tools - Structure Explanation

## What This Is

`mcp-dev-tools` is a complete MCP setup that lets AI assistants (ChatGPT, Claude, and others) read and understand your code repositories. It exposes a read-only filesystem MCP over HTTP/SSE using a lightweight gateway.

## Folder Structure

```
mcp-dev-tools/
├── start-mcp-dev-tools.sh   # 🚀 Main launcher (recommended)
├── start-http.sh            # HTTP/SSE gateway using supergateway (wraps stdio server)
├── run-filesystem.sh        # Launches filesystem MCP (stdio) via local MCP reference servers
├── start-search.sh          # Ripgrep search MCP via supergateway (optional)
├── start-all.sh             # Convenience launcher for multiple servers
├── health-check.sh          # Diagnostics and environment checks
├── test-stdio.sh            # Simple stdio smoke test (Claude Desktop)
├── .env.example             # Sample env file (copy to .env)
├── package.json             # Node dependencies (supergateway, mcp-ripgrep)
├── package-lock.json
├── README.md                # Main documentation
├── QUICK_REFERENCE.md       # Quick commands
├── TROUBLESHOOTING.md       # Help when things go wrong
├── MIGRATION.md
├── CONTRIBUTING.md
└── node_modules/
```

Notes:
- There is no `filesystem-core/` or `mcp-ref/` folder inside this repo. The filesystem MCP server is sourced from your local MCP reference servers installation.
- `run-filesystem.sh` uses `MCP_REF_DIR` (default `$HOME/mcpServers/mcp-reference-servers`) and runs `src/filesystem/dist/index.js` from there.

## How It Works

1. Filesystem MCP (stdio)
   - `run-filesystem.sh` starts the reference filesystem server in read-only mode with safe defaults:
     - `--read-only`, `--deny-symlinks`
     - Allow-list globs for common code/docs (ts, js, json, md, yml, sql, etc.)
   - Target repo root is controlled by `REPO_ROOT`.

2. HTTP/SSE Gateway
   - `start-http.sh` runs `supergateway` which wraps the stdio MCP as an HTTP/SSE service (default port 3333).
   - Endpoints: SSE at `/sse`, message POST at `/message`.

3. Orchestration
   - `start-mcp-dev-tools.sh` ties it all together, checks ports/paths, and starts the gateway with the right env.
   - `start-all.sh` can start the HTTP server and the search server (ripgrep) together.

4. Optional Search MCP
   - `start-search.sh` launches `mcp-ripgrep` via `supergateway` on port 3334 for fast code search.

## To Use

```bash
# Default repository (set in .env)
./start-mcp-dev-tools.sh

# Different repository
REPO_ROOT=/path/to/your/project ./start-mcp-dev-tools.sh

# Optional search server
./start-search.sh &
```

## External Dependency: Reference Servers

This repository relies on the local MCP reference servers for the filesystem MCP:
- Default path: `$HOME/mcpServers/mcp-reference-servers`
- Expected entry: `src/filesystem/dist/index.js`

If your installation lives elsewhere, edit `MCP_REF_DIR` in `run-filesystem.sh`.

## What Makes This a Complete MCP Setup

- ✅ Protocol implementation (via reference filesystem MCP)
- ✅ HTTP/SSE transport (supergateway)
- ✅ Configuration and scripts (this repo)
- ✅ Documentation and quick-start
- ✅ Optional search MCP (mcp-ripgrep)

This is one cohesive MCP setup exposed over HTTP/SSE, suitable for ChatGPT Desktop and others.
