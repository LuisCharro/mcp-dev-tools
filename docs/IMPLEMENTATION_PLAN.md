# MCP Dev Tools - Implementation Plan

## Overview
This document provides a dependency-aware implementation plan for mcp-dev-tools, ensuring each phase builds properly on the previous one without rework.

## Progress Tracking Legend
- ✅ **COMPLETED** - Task is done and working
- ⏳ **NEXT** - Ready to start (dependencies met)
- ⭕ **BLOCKED** - Waiting for dependencies
- 🚧 **IN PROGRESS** - Currently being worked on

## Overall Progress
**Phase 0**: Foundation & Hygiene
- ✅ 0.1 Environment Standardization 
- ✅ 0.2 Script Portability (completed)
- ⭕ 0.3 Repository Governance (can run in parallel)
- ⏳ 0.4 Documentation Alignment (ready to start)

**Phase 1**: Operational Foundation - ⭕ BLOCKED (needs Phase 0)
**Phase 2**: Git Integration - ⭕ BLOCKED (needs Phase 1)
**Phase 3**: Enhanced Features - ⭕ BLOCKED (needs Phase 2)
**Phase 4**: Production Readiness - ⭕ BLOCKED (needs Phase 3)
**Phase 5**: Advanced Features - ⭕ BLOCKED (needs Phase 4)

## Current State Assessment
- ✅ Basic HTTP proxy (supergateway) setup
- ✅ Filesystem server (read-only) via MCP reference
- ✅ Ripgrep search server
- ✅ Basic start scripts
- ✅ Environment standardization (Phase 0.1)
- ❌ Missing: Git server, write operations, health checks

## Phase-by-Phase Implementation Plan

### Phase 0: Foundation & Hygiene (Week 1)
**Goal**: Create a stable, portable foundation that works everywhere

#### ✅ 0.1 Environment Standardization [COMPLETED]
**Dependencies**: None
**Files**: `.env.example`, `.env.local`, all start scripts
**Tasks**:
1. ✅ Add missing environment variables to `.env.example`:
   ```bash
   PORT=3333
   SEARCH_PORT=3334
   GIT_PORT=3335
   REPO_ROOT=/Users/luis/Repos/mcp-dev-tools
   SAFE_WRITE=false
   ALLOW_GLOBS=**/*
   DENY_GLOBS=**/.env*,**/*.pem,**/id_*,**/.git/**
   MCP_REF_DIR=$HOME/mcpServers/mcp-reference-servers
   MAX_FILE_SIZE=1048576
   ```
2. ✅ Update all scripts to read from standardized env vars
3. ✅ Add environment validation at startup
4. ✅ Echo REPO_ROOT and active config at startup

**Acceptance**: ✅ `./start-mcp-dev-tools.sh` runs with only `.env.local` present

#### ✅ 0.2 Script Portability [COMPLETED]
**Dependencies**: 0.1 complete ✅
**Files**: All shell scripts using `sed -i`
**Tasks**:
1. ✅ Create `scripts/build/patch-env.mjs` for cross-platform env file editing
2. ✅ Replace all `sed -i ''` usage with the Node helper
3. ✅ Test on both macOS and Linux

**Acceptance**: ✅ All scripts work on macOS and Linux without modification

#### ⭕ 0.3 Repository Governance 
**Dependencies**: None (can run in parallel with 0.1-0.2)
**Files**: `.github/` directory structure
**Tasks**:
1. ⭕ Create `.github/pull_request_template.md` with checklist
2. ⭕ Create `.github/ISSUE_TEMPLATE/` with bug_report.md and feature_request.md
3. ⭕ Add `CODEOWNERS` file
4. ⭕ Add basic `SECURITY.md`

**Acceptance**: PR template auto-loads, CODEOWNERS enforces review

#### ⭕ 0.4 Documentation Alignment
**Dependencies**: 0.1 complete ✅ (need final script paths)
**Files**: `README.md`, all docs in `docs/`
**Tasks**:
1. ⭕ Update `README.md` quick start to match current script structure
2. ⭕ Verify all paths in documentation are correct
3. ⭕ Ensure troubleshooting covers common env issues

**Acceptance**: Following README gets first-time user to "SSE streaming is alive" in 2 minutes

### Phase 1: Operational Foundation (Week 2)
**Goal**: Make the system robust and observable

#### ⭕ 1.1 Health & Smoke Checks
**Dependencies**: Phase 0 complete (0.2 ⏳, 0.3 ⭕, 0.4 ⭕)
**Files**: `scripts/health/health-check.sh`, `scripts/health/smoke-test.sh`
**Tasks**:
1. ⭕ Implement comprehensive health checks:
   - Node.js ≥18 present
   - ripgrep (`rg`) available
   - All required ports free
   - MCP reference servers available
   - SSE endpoints responding
2. ⭕ Add actionable error messages and hints
3. ⭕ Create smoke test that verifies end-to-end functionality

**Acceptance**: Both scripts give green checks on fresh machine with only Node + ripgrep

#### ⭕ 1.2 Start-All Convenience & Process Management
**Dependencies**: 1.1 complete ⭕ (needs health checks)
**Files**: `scripts/server/start-all.sh`
**Tasks**:
1. ⭕ Make start-all idempotent (check if ports in use)
2. ⭕ Track PIDs properly
3. ⭕ Add stop-all functionality
4. ⭕ Implement log rotation or proper appending
5. ⭕ Display running services status

**Acceptance**: Repeated invocations don't spawn duplicates; clean shutdown possible

#### ⭕ 1.3 Configurable Allow/Deny Globs
**Dependencies**: Phase 0 complete (0.1 ✅, needs env standardization)
**Files**: `scripts/server/run-filesystem.sh`, documentation
**Tasks**:
1. ⭕ Parse ALLOW_GLOBS and DENY_GLOBS from environment
2. ⭕ Pass filters to filesystem server
3. ⭕ Echo effective filters at startup
4. ⭕ Document glob patterns and security implications

**Acceptance**: Changing globs in `.env.local` visibly affects what AI can access

### Phase 2: Git Integration (Week 3)
**Goal**: Add comprehensive Git operations (read-only first, then guarded writes)

#### 2.1 Git Server Implementation (Read-Only)
**Dependencies**: Phase 1 complete
**Files**: New `servers/git/` directory, `scripts/server/start-git-http.sh`
**Tasks**:
1. Create minimal stdio MCP server for Git operations:
   ```
   servers/git/
   ├── package.json
   ├── src/
   │   ├── index.ts
   │   ├── git-tools.ts
   │   └── security.ts
   └── tsconfig.json
   ```
2. Implement read-only tools:
   - `git/status` (porcelain format)
   - `git/branch_list`
   - `git/log` (with optional path filter)
   - `git/diff` (working vs HEAD, or between refs)
   - `git/show` (commit/blob by hash)
   - `git/ls_files`
3. Add strict argument sanitization
4. Enforce working directory = REPO_ROOT
5. Create start script that wraps via supergateway on GIT_PORT

**Acceptance**: `start-git-http.sh` exposes git tools; MCP Inspector shows `git/*` tools

#### 2.2 Git Write Operations (Behind SAFE_WRITE Flag)
**Dependencies**: 2.1 complete
**Files**: Same git server
**Tasks**:
1. Add write operations (disabled by default):
   - `git/add`
   - `git/reset`
   - `git/commit` (with conventional commit validation)
   - `git/branch_create`
   - `git/checkout -b`
2. Implement safety checks:
   - Refuse force operations
   - Block on dirty working tree unless explicit
   - Cap diff sizes
   - Validate commit messages
3. Comprehensive logging of all write operations

**Acceptance**: With SAFE_WRITE=false, writes return clear errors; with true, operations work and are logged

#### 2.3 PR Workflow Implementation
**Dependencies**: 2.2 complete
**Files**: Same git server, new PR tools
**Tasks**:
1. Implement `git/pr_dry_run`:
   - Analyze staged changes
   - Generate branch name proposal
   - Create commit preview
   - Return checklist for PR creation
2. Implement `git/pr_apply`:
   - Create branch from changes
   - Commit with proper message
   - Push to remote (if available)
   - Open PR via `gh` CLI (if available)
   - Return actionable next steps

**Acceptance**: Dry-run returns proper analysis; apply creates PR or gives manual steps

### Phase 3: Enhanced Search & File Operations (Week 4)
**Goal**: Improve search capabilities and add safe file editing

#### 3.1 Search Server Enhancement
**Dependencies**: Phase 1 complete
**Files**: Search server configuration, documentation
**Tasks**:
1. Expose more ripgrep options:
   - File type filters (`--type`)
   - Hidden file inclusion (`--hidden`)
   - Fixed string vs regex (`--fixed-strings`)
   - Context lines (`--before-context`, `--after-context`)
   - Result limits (`--max-count`)
   - Glob patterns (`--glob`)
2. Add result pagination
3. Implement search result summarization
4. Add search performance metrics

**Acceptance**: Rich search options available; large result sets handled gracefully

#### 3.2 File Editing Server (Dry-Run + Apply Pattern)
**Dependencies**: Phase 0 complete (needs env setup)
**Files**: New `servers/fs-edits/` directory
**Tasks**:
1. Create dedicated file editing server:
   ```
   servers/fs-edits/
   ├── package.json
   ├── src/
   │   ├── index.ts
   │   ├── edit-tools.ts
   │   ├── backup.ts
   │   └── security.ts
   └── tsconfig.json
   ```
2. Implement `fs/edit_file_dry_run`:
   - Accept LSP-style range edits
   - Generate unified diff
   - Create deterministic apply token (hash)
   - Never write to disk
3. Implement `fs/apply_edits`:
   - Verify apply token matches current file
   - Create backup in `.mcp/backups/`
   - Apply changes atomically
   - Return post-edit hash
4. Add comprehensive safety:
   - Path denylist (secrets, .git, etc.)
   - File size limits
   - UTF-8 validation
   - Line ending preservation

**Acceptance**: Dry-run never writes; apply requires matching token; backups created

### Phase 4: Observability & Production Readiness (Week 5)
**Goal**: Make the system production-ready with proper monitoring

#### 4.1 Health Endpoints & Monitoring
**Dependencies**: Phase 1 complete
**Files**: New monitoring infrastructure
**Tasks**:
1. Create health/ready endpoints:
   - HTTP endpoints on PORT+1
   - JSON responses with service status
   - Version information
   - Process health checks
2. Implement structured logging:
   - JSON format with correlation IDs
   - Request timing
   - Error categorization
   - Configurable log levels
3. Add metrics collection

**Acceptance**: `curl localhost:3334/health` returns service status; logs are structured

#### 4.2 Integration Testing & CI
**Dependencies**: All previous phases complete
**Files**: `tests/` directory, CI configuration
**Tasks**:
1. Create comprehensive test suite:
   - Black-box API tests
   - Integration tests with real repos
   - Performance benchmarks
   - Security validation tests
2. Set up CI pipeline:
   - Automated testing on PR
   - Cross-platform testing
   - Security scanning
3. Create developer tools:
   - Test data fixtures
   - Load testing scripts
   - Performance profiling

**Acceptance**: Full test suite passes; CI prevents regressions

### Phase 5: Advanced Features (Weeks 6-8)
**Goal**: Add code intelligence and advanced capabilities

#### 5.1 Symbol Indexing
**Dependencies**: Phase 4 complete
**Files**: New `servers/symbols/` directory
**Tasks**:
1. Implement symbol server using universal-ctags or tree-sitter
2. Add tools:
   - `symbols/list` (by file or project)
   - `symbols/find_references`
   - `symbols/definitions`
   - `symbols/workspace_symbols`
3. Support multiple languages
4. Implement incremental indexing

**Acceptance**: Symbol navigation works across files; updates on file changes

#### 5.2 Semantic Search (Optional)
**Dependencies**: 5.1 complete
**Files**: New `servers/semantic/` directory
**Tasks**:
1. Implement embedding-based search
2. Add hybrid retrieval (text + semantic)
3. Support local vector databases
4. Implement AST-aware chunking

**Acceptance**: Semantic search outperforms text search on code queries

## Execution Strategy

### Development Workflow
1. **Branch Strategy**: Feature branches per task (`phase0/env-standardization`)
2. **PR Size**: Keep PRs small (100-200 lines max)
3. **Testing**: Each PR must include tests and updated documentation
4. **Review**: All changes require review before merge

### Quality Gates
- [ ] All scripts work on macOS and Linux
- [ ] Health checks pass on clean installation
- [ ] Security review for any write operations
- [ ] Performance testing for search operations
- [ ] Documentation updated for all new features

### Risk Mitigation
1. **Backward Compatibility**: Never break existing tool schemas
2. **Safe Defaults**: All write operations opt-in only
3. **Rollback Strategy**: Maintain ability to revert to previous version
4. **Security First**: Regular security reviews and automated scanning

## Success Metrics
- **Phase 0**: Clean installation works in < 2 minutes
- **Phase 1**: Zero false positives in health checks
- **Phase 2**: Git operations work with major Git workflows
- **Phase 3**: Search performs well on repos with 100k+ files
- **Phase 4**: 99%+ uptime in local development scenarios
- **Phase 5**: Symbol navigation comparable to IDE experience

## Next Steps
1. Create GitHub Project with milestones matching phases
2. Break down each phase into individual GitHub issues
3. Set up development environment following Phase 0
4. Begin implementation with Phase 0.1 (Environment Standardization)
