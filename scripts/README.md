# Scripts Directory

This directory contains all executable scripts for the MCP Dev Tools project, organized by purpose:

## Structure

```
scripts/
├── server/          # Server startup and management
│   ├── start-mcp-dev-tools.sh  # Main server launcher
│   ├── start-http.sh           # HTTP/SSE gateway
│   ├── start-search.sh         # Search server
│   ├── start-all.sh            # Start all servers
│   └── run-filesystem.sh       # Filesystem MCP server
├── health/          # Health checks and diagnostics
│   ├── health-check.sh         # System health check
│   └── smoke-test.sh           # HTTP/SSE smoke test
├── dev/             # Development and testing utilities
│   └── test-stdio.sh           # STDIO interface test
└── build/           # Future: build and deployment scripts
```

## Usage

### Server Scripts
- `./scripts/server/start-mcp-dev-tools.sh` - Start the main MCP server
- `./scripts/server/start-all.sh` - Start all servers (filesystem + search)
- `./scripts/server/start-http.sh --port 3333` - Start just the HTTP gateway
- `./scripts/server/start-search.sh` - Start just the search server

### Health Scripts
- `./scripts/health/health-check.sh` - Check system status and dependencies
- `./scripts/health/smoke-test.sh` - Test HTTP/SSE functionality

### Development Scripts
- `./scripts/dev/test-stdio.sh` - Test STDIO interface directly

## Convenience

For backward compatibility, a main launcher is available at the root:
- `./start-mcp-dev-tools.sh` - Delegates to `./scripts/server/start-mcp-dev-tools.sh`

## Future Additions

Based on the feature roadmap, these subfolders will contain:
- `health/doctor.sh` - Comprehensive diagnostic tool (Milestone 3)
- `build/` - Scripts for npm packaging and Docker distribution
- `dev/` - Additional testing and development utilities
