# 🤖 MCP Dev Tools - Your AI Pair Programmer

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE) [![Node.js >=18](https://img.shields.io/badge/node-%3E%3D18-blue.svg)](package.json)

This folder contains everything needed to enable AI assistants (ChatGPT, Claude, and others) to code alongside you, with full read access and safe write capabilities roadmap for your repositories.

> Prerequisites: macOS, Node.js 18+, Git, ripgrep (rg) for search, and the HTTP proxy (supergateway) (installed via npm in this repo). You also need the MCP reference servers locally for the filesystem server (see Notes below).

## 🎯 Purpose

This MCP (Model Context Protocol) server allows ChatGPT Desktop to:
- 📖 Read your code repositories
- 🔍 Search through your codebase efficiently
- 📝 Suggest changes via PR workflow (planned safe write mode)
- 🔧 Understand your project structure and dependencies

## 📁 Folder Structure

```
mcp-dev-tools/
├── start-mcp-dev-tools.sh   # Main launcher (recommended)
├── start-http.sh            # HTTP/SSE gateway (wraps stdio server via supergateway)
├── run-filesystem.sh        # Launches filesystem MCP (stdio) using local reference servers
├── start-search.sh          # Ripgrep search server via supergateway (optional)
├── start-all.sh             # Convenience launcher for multiple servers
├── health-check.sh          # Diagnostics and environment checks
├── test-stdio.sh            # Simple stdio smoke test (for Claude Desktop)
├── .env.example             # Example env config (copy to .env)
├── package.json             # Node dependencies (supergateway, mcp-ripgrep)
├── package-lock.json
├── README.md
├── QUICK_REFERENCE.md
├── TROUBLESHOOTING.md
├── MIGRATION.md
├── CONTRIBUTING.md
└── node_modules/
```

Notes:
- The stdio filesystem server is provided by the MCP reference servers on your machine. The path is configured in `run-filesystem.sh` via `MCP_REF_DIR` (defaults to `/Users/luis/mcpServers/mcp-reference-servers`). Adjust if your path differs.
- No `repo-reader/`, `git-pr-mcp/`, or Git HTTP server exists in this repo today.

## 🚀 Quick Start

### 1) Start the main server (HTTP)
```bash
cd /Users/luis/Repos/mcp-dev-tools
./start-mcp-dev-tools.sh
```
- Default port: 3333
- Default repository: `<your-repo-path>` (set in .env)

Background/alt:
```bash
./start-http.sh --port 3333 &
```

### 2) Configure ChatGPT Desktop
Add a new connector in ChatGPT Desktop settings:
- Name: Code Assistant
- URL: http://127.0.0.1:3333/

### 3) Optional: Start Search Server
```bash
./start-search.sh &  # Ripgrep search server on port 3334
```

### 4) Test It
In ChatGPT, try: “List the files in my repository”.

## 🔧 Configuration

### Change Target Repository
By default, `REPO_ROOT` is read from `.env`. To change:

- Option A – Environment variable
```bash
REPO_ROOT=/path/to/your/repo ./start-mcp-dev-tools.sh
```

- Option B – .env file
```bash
cp .env.example .env
# then edit .env to set REPO_ROOT and ports
```

- Option C – Edit script default
Edit `run-filesystem.sh` and change the `REPO_ROOT` default value.

### Ports
- Main server: `PORT` (default 3333)
- Search server: `SEARCH_PORT` (default 3334)

## 💡 Available Features

### 1) Filesystem Access (Active)
- Read-only access to your repository
- Browse files and folders
- Read file contents
- Understand project structure

### 2) Search Capabilities (Optional)
```bash
./start-search.sh &  # Starts mcp-ripgrep via supergateway
```
- Fast code search using ripgrep
- Find patterns across your codebase
- Locate specific functions or variables

### 3) Safe Write Mode (Roadmap)
Planned: two-step confirmation system for making changes via Pull Requests.
- Edits happen on a new branch
- A unified diff is shown with a dry-run confirmation hash
- On confirm, we commit, push, and open a PR (never writing directly to main)

## 📊 Server Status

Check if everything is running:
```bash
# Check main server
# Note: /sse is a streaming endpoint — continuous output means it's alive.
curl -I http://127.0.0.1:3333/sse  # or curl http://127.0.0.1:3333/sse and expect streaming

# Check processes
ps aux | grep -E "(supergateway|filesystem)"

# Check port
lsof -i :3333
```

## 🛑 Stopping the Server

```bash
# Stop the main server on port 3333
pkill -f "supergateway.*3333"

# Stop all MCP servers (HTTP gateways)
pkill -f supergateway

# If you started processes in the background (&) and pkill doesn't catch them,
# find them with ps and kill by PID:
ps aux | grep supergateway
kill -9 <PID>
```

## 🔐 Security

- Read-Only by Default: the filesystem server only reads, never writes
- Local Only: servers run on localhost (127.0.0.1)
- Planned Safe Write Mode: all write operations require explicit confirmation and PR workflow

## 🎨 Use Cases

1) Code Review: “What does the authentication module do?”
2) Bug Finding: “Find potential null pointer exceptions in this codebase”
3) Documentation: “Generate documentation for the API endpoints”
4) Refactoring: “Suggest improvements for the user service”
5) Learning: “Explain how the payment processing works”

## 🔧 Troubleshooting

Common fixes:
- Run `./health-check.sh` for diagnostics
- Verify `REPO_ROOT` exists and is readable
- Make sure ports 3333/3334 are free

If the server won’t start:
```bash
# Check if port is in use
lsof -i :3333
# Use different port
PORT=3334 ./start-mcp-dev-tools.sh
```

Can’t connect from ChatGPT:
- Ensure server is running: `ps aux | grep supergateway`
- Check firewall settings
- Verify URL in ChatGPT: `http://127.0.0.1:3333/`

Repository not found:
- Check path exists: `ls -la /path/to/your/repo`
- Update `REPO_ROOT` env var or .env

## 📈 Advanced Configuration

### Multiple Repositories
Create different start scripts or use env vars per project:
```bash
# Project 1
REPO_ROOT=/path/to/project1 PORT=3333 ./start-mcp-dev-tools.sh

# Project 2
REPO_ROOT=/path/to/project2 PORT=3334 ./start-mcp-dev-tools.sh
```

### Custom File Filters
Default allow-list in `run-filesystem.sh`:
- `**/*.cs`, `**/*.ts`, `**/*.tsx`, `**/*.js`, `**/*.jsx`, `**/*.json`, `**/*.md`, `**/*.yml`, `**/*.yaml`, `**/*.sql`

Tweak `ALLOW_GLOBS` in `run-filesystem.sh` as needed.

## 🤝 Working with ChatGPT

Effective prompts:
- “Show me the main entry point of this application”
- “Find all API endpoints in this codebase”
- “Explain the database schema”
- “List recent changes to the authentication module”
- “Help me debug this error: [paste error]”

Best practices:
1) Be specific about file paths when known
2) Ask for explanations along with code
3) Request incremental changes
4) Always review suggested modifications
5) Use version control before applying changes

## 📚 Additional Resources

- Model Context Protocol Documentation: https://modelcontextprotocol.io
- MCP SDK / Reference Servers: https://github.com/modelcontextprotocol/sdk (see reference servers)

---

Created for: Enabling ChatGPT Desktop to be your AI pair programmer
Default Repository: `<your-repo-path>`
Server Port: 3333
Protocol: HTTP/SSE via supergateway (HTTP) or stdio (for Claude)

## 🧩 Using with Claude Desktop (macOS)

Claude Desktop reads an MCP config at `~/claude_desktop_config.json`.

HTTP transport (recommended):
```json
{
  "mcpServers": {
    "repo-reader": {
      "transport": "http",
      "url": "http://127.0.0.1:3333/"
    },
    "repo-search": {
      "transport": "http",
      "url": "http://127.0.0.1:3334/"
    }
  }
}
```

If HTTP transport isn’t available in your Claude build, use stdio with the filesystem server directly:
```json
{
  "mcpServers": {
    "repo-reader": {
      "command": "/Users/luis/Repos/mcp-dev-tools/run-filesystem.sh",
      "args": []
    }
  }
}
```

Then quit and reopen Claude Desktop. In a chat, ask:
- “What MCP tools are available?”
- “List files in /src.”

## 📎 Reference Servers Note

This repo calls into the local MCP reference servers for the filesystem MCP:
- Default path: `/Users/luis/mcpServers/mcp-reference-servers`
- Expected binary: `src/filesystem/dist/index.js`

If your path differs, edit `MCP_REF_DIR` in `run-filesystem.sh`. Ensure the reference servers are built so that the `dist` file exists.
