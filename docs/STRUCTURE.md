# MCP Dev Tools - Structure Explanation

## What This Is

`mcp-dev-tools` is a complete MCP setup that lets AI assistants (ChatGPT, Claude, and others) read and understand your code repositories. It exposes a read-only filesystem MCP over HTTP/SSE using a lightweight gateway.

## Folder Structure

```
mcp-dev-tools/
├── README.md                    # Main documentation
├── package.json                 # Dependencies for HTTP gateway
├── package-lock.json
├── .gitignore
├── .env.example                 # Environment template
├── .env.local                   # Your local config (auto-generated)
├── scripts/                     # All executable scripts
│   ├── server/                  # Server startup and management
│   │   ├── start-mcp-dev-tools.sh   # Main launcher
│   │   ├── start-http.sh            # HTTP gateway server
│   │   ├── start-search.sh          # Search server
│   │   ├── start-all.sh             # Start all servers
│   │   └── run-filesystem.sh        # Filesystem server runner
│   ├── health/                  # Health checks and diagnostics
│   │   ├── health-check.sh          # System health verification
│   │   └── smoke-test.sh            # HTTP/SSE functionality test
│   ├── dev/                     # Development utilities
│   │   └── test-stdio.sh            # Direct MCP protocol testing
│   ├── build/                   # Future: build and deployment scripts
│   └── README.md                # Scripts documentation
├── docs/                        # All documentation
│   ├── QUICK_REFERENCE.md       # Command cheat sheet
│   ├── TROUBLESHOOTING.md       # Common issues and solutions
│   ├── STRUCTURE.md             # This file
│   ├── MIGRATION.md             # Upgrade guide
│   ├── CONTRIBUTING.md          # Development guide
│   └── FEATURE_BACKLOG.md       # Planned features
├── tests/                       # Future: automated test suite
├── examples/                    # Future: client configurations
├── logs/                        # Server logs (auto-generated)
│   └── .gitkeep
├── start-mcp-dev-tools.sh       # Convenience launcher (→ scripts/server/)
└── mcp-gateway.log              # Main server log (auto-generated)
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
