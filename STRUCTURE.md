# MCP Dev Tools - Structure Explanation

## What This Is

`mcp-dev-tools` is a complete MCP server that allows AI assistants (ChatGPT, Claude, and others) to read and understand your code repositories.

## Folder Structure

```
mcp-dev-tools/
│
├── filesystem-core/           # ← CORE COMPONENT (not a separate MCP!)
│   ├── mcp-ref/              # Official MCP filesystem implementation
│   └── run-filesystem.sh     # Script that starts the filesystem server
│
├── node_modules/             # Dependencies (supergateway, etc.)
├── package.json             # Node.js configuration
│
├── start-mcp-dev-tools.sh   # 🚀 MAIN LAUNCHER - Use this!
├── start-http.sh            # Lower-level starter (called by main launcher)
│
└── Documentation/
    ├── README.md            # Main documentation
    ├── TROUBLESHOOTING.md   # Help when things go wrong
    └── QUICK_REFERENCE.md   # Quick commands

```

## How It Works

1. **filesystem-core/** contains the actual MCP server code
   - This is NOT a separate MCP server
   - It's the core component that makes this whole thing work
   - It provides read-only access to your repository

2. **supergateway** (in node_modules) wraps the filesystem server
   - Converts stdio protocol to HTTP/SSE
   - Makes it accessible to ChatGPT Desktop

3. **start-mcp-dev-tools.sh** ties everything together
   - Sets up the repository path
   - Starts the HTTP proxy
   - Provides clear feedback

## To Use

```bash
# Default repository (PDFExtractorAI)
./start-mcp-dev-tools.sh

# Different repository
REPO_ROOT=/path/to/your/project ./start-mcp-dev-tools.sh
```

## What Makes This a Complete MCP Server

- ✅ Protocol implementation (filesystem-core)
- ✅ HTTP/SSE transport (supergateway)
- ✅ Configuration (package.json, scripts)
- ✅ Documentation
- ✅ Easy launcher script

This is ONE complete MCP server, not multiple servers!
