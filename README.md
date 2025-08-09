# 🤖 MCP Dev Tools - Your AI Pair Programmer

This folder contains everything needed to enable AI assistants (ChatGPT, Claude, and others) to code alongside you, with full read access and safe write capabilities to your repositories.

## 🎯 Purpose

This MCP (Model Context Protocol) server allows ChatGPT Desktop to:
- 📖 **Read** your code repositories
- 🔍 **Search** through your codebase efficiently  
- 📝 **Suggest changes** via Pull Requests (safe write mode)
- 🔧 **Understand** your project structure and dependencies

## 📁 Folder Structure

```
mcp-dev-tools/
├── repo-reader/           # Main MCP filesystem server
│   ├── mcp-ref/          # Official MCP reference implementation
│   └── run-filesystem.sh  # Script to start filesystem server
├── git-pr-mcp/           # Safe write support via PR workflow
├── start-http.sh         # Main HTTP proxy launcher (port 3333)
├── start-search.sh       # Ripgrep search server
├── start-git-http.sh     # Git operations server
├── package.json          # Node.js dependencies
└── node_modules/         # Installed npm packages
```

## 🚀 Quick Start

### 1. Start the Server
```bash
cd /Users/luis/mcpServers/mcp-dev-tools
./start-http.sh &
```

### 2. Configure ChatGPT Desktop
Add a new connector in ChatGPT Desktop settings:
- **Name**: Code Assistant
- **URL**: `http://127.0.0.1:3333/`

### 3. Test It
In ChatGPT, try: "List the files in my repository"

## 🔧 Configuration

### Change Target Repository
By default, it's configured for `/Users/luis/Repos/PDFExtractorAI`. To change:

**Option 1 - Environment Variable:**
```bash
REPO_ROOT=/path/to/your/repo ./start-http.sh &
```

**Option 2 - Edit Configuration:**
Edit `repo-reader/run-filesystem.sh` and change the `REPO_ROOT` default value.

## 💡 Available Features

### 1. **Filesystem Access** (Active)
- Read-only access to your repository
- Browse files and folders
- Read file contents
- Understand project structure

### 2. **Search Capabilities** (Optional)
```bash
./start-search-daemon.sh start  # Start ripgrep search server
```
- Fast code search using ripgrep
- Find patterns across your codebase
- Locate specific functions or variables

### 3. **Git Operations** (Optional)
```bash
./start-git-http.sh &  # Start git server
```
- View commit history
- Check file changes
- Understand project evolution

### 4. **Safe Write Mode** (Coming Soon)
The `git-pr-mcp/` folder contains a two-step confirmation system for making changes:
1. ChatGPT prepares changes and gets a confirmation hash
2. You review and confirm before any changes are applied
3. Changes are made via Pull Requests, never directly to main branch

## 📊 Server Status

Check if everything is running:
```bash
# Check main server
curl http://127.0.0.1:3333/sse

# Check processes
ps aux | grep -E "(supergateway|filesystem)"

# Check port
lsof -i :3333
```

## 🛑 Stopping the Server

```bash
# Stop the main server
pkill -f "supergateway.*3333"

# Stop all MCP servers
pkill -f supergateway
```

## 🔐 Security

- **Read-Only by Default**: The filesystem server only reads, never writes
- **Local Only**: Server runs on localhost (127.0.0.1)
- **Safe Write Mode**: All write operations require explicit confirmation
- **PR Workflow**: Changes are made via pull requests for review

## 🎨 Use Cases

1. **Code Review**: "What does the authentication module do?"
2. **Bug Finding**: "Find potential null pointer exceptions in this codebase"
3. **Documentation**: "Generate documentation for the API endpoints"
4. **Refactoring**: "Suggest improvements for the user service"
5. **Learning**: "Explain how the payment processing works"

## 🔧 Troubleshooting

### Server Won't Start
```bash
# Check if port is in use
lsof -i :3333
# Use different port
./start-http.sh --port 3334
```

### Can't Connect from ChatGPT
- Ensure server is running: `ps aux | grep supergateway`
- Check firewall settings
- Verify URL in ChatGPT: `http://127.0.0.1:3333/`

### Repository Not Found
- Check path exists: `ls -la /Users/luis/Repos/PDFExtractorAI`
- Update REPO_ROOT environment variable

## 📈 Advanced Configuration

### Multiple Repositories
Create different start scripts for different repos:
```bash
# start-project1.sh
REPO_ROOT=/path/to/project1 ./start-http.sh --port 3333

# start-project2.sh  
REPO_ROOT=/path/to/project2 ./start-http.sh --port 3334
```

### Custom File Filters
Edit `repo-reader/run-filesystem.sh` to modify allowed file patterns.

## 🤝 Working with ChatGPT

### Effective Prompts
- "Show me the main entry point of this application"
- "Find all API endpoints in this codebase"
- "Explain the database schema"
- "List recent changes to the authentication module"
- "Help me debug this error: [paste error]"

### Best Practices
1. Be specific about file paths when known
2. Ask for explanations along with code
3. Request incremental changes
4. Always review suggested modifications
5. Use version control before applying changes

## 📚 Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io)
- [MCP SDK Reference](https://github.com/modelcontextprotocol/sdk)

---

**Created for**: Enabling ChatGPT Desktop to be your AI pair programmer
**Default Repository**: `/Users/luis/Repos/PDFExtractorAI`
**Server Port**: 3333
**Protocol**: HTTP/SSE via MCP
