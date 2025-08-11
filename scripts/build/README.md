# Build Scripts

This directory contains build and development utilities for mcp-dev-tools.

## Scripts

### `patch-env.mjs`

Cross-platform environment file editor that replaces the macOS-specific `sed -i ''` command.

**Usage:**
```bash
node patch-env.mjs <env-file> <key> <value>
```

**Examples:**
```bash
# Update existing variable
node patch-env.mjs .env.local REPO_ROOT /path/to/repo

# Add new variable
node patch-env.mjs .env.local PORT 3333

# Works with relative paths
node patch-env.mjs ../../.env DEBUG true
```

**Features:**
- Cross-platform (works on macOS, Linux, Windows)
- Safely updates existing environment variables
- Adds new variables if they don't exist
- Preserves comments and formatting
- Input validation for environment variable names
- Proper error handling

**Replaces:**
- `sed -i '' "s#^KEY=.*#KEY=value#" file` (macOS)
- `sed -i "s#^KEY=.*#KEY=value#" file` (Linux)

This ensures consistent behavior across all platforms without requiring platform-specific code in shell scripts.
