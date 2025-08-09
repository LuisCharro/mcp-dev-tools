# Feature Backlog – mcp-dev-tools

This document is the product roadmap for **mcp-dev-tools** — a local-first toolkit that lets AI assistants (ChatGPT, Claude, Cursor, Kiro, Windsurf, etc.) *read*, *search*, and (safely) *propose/apply* changes to your repositories through the Model Context Protocol (MCP). It consolidates best practices from the official MCP reference servers and mature community servers, and turns them into a concrete, testable implementation plan.

> Status: living document. Target audience: maintainers & contributors. Scope: design principles, tool surfaces (schemas), milestone plan, acceptance tests, and security posture.

---

## 1) Vision & Non‑Goals

**Vision.** Make an AI assistant an *effective pair programmer* on any local repo with three pillars:
- High‑fidelity **read/search** context (filesystem + text + symbols + semantics).
- Guardrailed **write/edit** via dry-runs and PR workflows (never destructive by default).
- **Client‑agnostic** UX (MCP standard; works with multiple IDEs/agents).

**Non‑Goals (for v1).**
- Not a general shell executor. No “run arbitrary commands” surface by default.
- Not a replacement for your CI or SCA stack; we only *surface* their results initially.
- No network egress by default (except optional PR creation via `gh`).

---

## 2) Architectural Overview

**Transports**
- **stdio** servers wrapped by an **HTTP/SSE proxy** (supergateway) for remote‑capable clients.
- Local‑only by default; optional remote hosting later (with auth).

**Servers included**
- **Filesystem** (read‑only baseline; guarded write path).
- **Search** (ripgrep wrapper with rich filters).
- **Git** (read‑only tools first; guarded writes; PR flow).

**Indexing (later milestones)**
- **Symbolic index** (ctags/tree‑sitter/LSP) → definitions, references, x‑file call graph.
- **Semantic index** (embeddings + vector DB) → hybrid retrieval with path/language filters.

**Security posture**
- Roots‑scoped access; allowlist globs; symlink denial; secret denylist and diff‑time scanning.
- Human‑in‑the‑loop confirmations for any writes; rollback/undo facilities.

---

## 3) Current Capabilities (baseline, Aug 2025)

- HTTP/SSE proxy launcher (`start-http.sh`) wrapping stdio servers.
- Filesystem server **read-only** with path allowlist; symlink denial.
- Ripgrep search server (`start-search*.sh`) — basic text/code search.
- Git server placeholder (`start-git-http.sh`).

---

## 4) Comparable Projects (for feature parity targets)

- **Reference servers**: Filesystem, Git, Fetch, Everything (tools/patterns), Inspector (debugging).
- **GitHub MCP Server**: hosted/remote patterns; repo browse/search; Issues/PRs; CI/Logs surfaces.
- **Agents-as-MCP**: multi‑agent orchestration (web/file/computer action) for complex flows.
- **Docs MCP Servers**: version‑aware documentation indexing and local privacy modes.
- **Code indexing** ecosystems: embeddings + hybrid search; AST‑aware chunking; incremental update.

> We track parity/functionality in the *Gap Analysis* and *Milestones* sections below.

---

## 5) Guiding Principles

1. **Safety first**: read‑only by default; explicit user confirmation for any writes; clear diffs.
2. **Small, reversible deltas**: dry‑run previews; atomic apply; PRs, not direct pushes.
3. **Context precision over token dumps**: search → symbols → snippets; avoid over‑reading.
4. **Client‑agnostic, self‑describing tools**: strict JSON schemas, examples, and rich metadata.
5. **Observability & operability**: health endpoints, structured logs, doctor script, quotas.
6. **Performance on real repos**: pagination, preview windows, streaming, concurrency limits.

---

## 6) Tool Surface (v1: Filesystem, Search, Git)

The MCP contract should be **stable and typed**. Below are proposed tool names, inputs, and outputs. Keep schemas **backwards‑compatible**; add fields with defaults rather than breaking changes.

### 6.1 Filesystem (read path)
- `fs/list_dir`  
  **Input**: `{ "path": "relative-or-abs", "max_entries": 500, "page": 0 }`  
  **Output**: `{ "entries": [{ "name": "string", "type": "file|dir|symlink", "size": 123, "mtime": "ISO8601" }], "next_page": 1|null }`

- `fs/read_file`  
  **Input**: `{ "path": "string", "range": { "start": 1, "end": 4000 }|null, "encoding": "utf-8|base64" }`  
  **Output**: `{ "content": "string|base64", "truncated": true|false, "lineStart": 1, "lineEnd": 4000 }`

- `fs/stat`  
  **Input**: `{ "path": "string" }`  
  **Output**: `{ "exists": true|false, "type": "file|dir|symlink|unknown", "size": 0, "mtime": "ISO8601", "sha256": "hex"|null }`

- `fs/glob`  
  **Input**: `{ "patterns": ["**/*.ts","!**/node_modules/**"], "limit": 2000 }`  
  **Output**: `{ "matches": ["path", ...] }`

> All inputs are validated against **repo root** + allowlist; symlinks resolved with denial on traversal outside roots.

### 6.2 Filesystem (guarded write path)

- `fs/edit_file_dry_run`  
  Previews multi‑edit patches without touching disk.  
  **Input**:  
  ```json
  {
    "path": "src/index.ts",
    "edits": [
      { "range": {"start": {"line": 10, "col": 1}, "end": {"line": 12, "col": 1}}, "text": "replacement" }
    ],
    "format": {"preserve_indentation": true, "newline": "lf|crlf|null"}
  }
  ```
  **Output**:  
  ```json
  {
    "diff": "unified-diff",
    "apply_token": "sha256-hex-of-inputs-and-current-file",
    "warnings": ["string"]
  }
  ```

- `fs/apply_edit_with_token`  
  Applies the exact diff previewed above.  
  **Input**: `{ "path": "src/index.ts", "apply_token": "sha256-hex" }`  
  **Output**: `{ "applied": true, "backup_path": ".mcp-dev-tools/backups/....", "post_sha256": "hex" }`

- `fs/create_file`, `fs/move`, `fs/delete` (all **opt‑in**, behind a `SAFE_WRITE=1` gate) with the *same* dry‑run → apply pattern.

### 6.3 Search (ripgrep)

- `search/grep`  
  **Input**:  
  ```json
  {
    "query": "regex-or-literal",
    "flags": {"fixed_strings": false, "ignore_case": false, "hidden": false, "types": ["ts","tsx"], "glob": ["!**/dist/**"]},
    "preview": {"before": 2, "after": 2, "max_matches": 200}
  }
  ```
  **Output**:  
  ```json
  {
    "matches": [{
      "path": "src/a.ts",
      "line": 42,
      "preview": ["const x = 1;","doThing()","// end"],
      "abs": false
    }],
    "count": 27
  }
  ```

### 6.4 Git

**Read-only set (default):**
- `git/status`, `git/diff` (modes: working, staged, against target), `git/log`, `git/show`, `git/branch_list`, `git/blame` (optional).

**Guarded write set (opt‑in):**
- `git/add`, `git/reset`, `git/commit` (conventional commits), `git/branch_create`, `git/checkout`, `git/init`.

**PR flow (opt‑in):**
- `git/pr_dry_run` → returns branch name proposal + diff + checklist.
- `git/pr_apply` → creates branch, applies diff, commits, pushes, opens PR (via `gh`), returns URL.
- `git/pr_rollback` → deletes branch or reverts commit if user cancels.

---

## 7) Gap Analysis (repo vs targets)

- **Filesystem**: read path good; **missing** guarded write (multi‑edit, diff token), metadata enrich, dynamic **Roots** tests.
- **Search**: basic OK; **missing** richer rg flags, pagination, summarized result helper.
- **Git**: **missing** full read set; write & PR flow; safety rails (size caps, protected paths).
- **Ops**: **missing** `/health` & `/ready`, unified structured logs, doctor script, first‑run checks.
- **Context**: **missing** symbol index + semantic index; hybrid retrieval tools.

---

## 8) Roadmap (dependency‑aware milestones)

### M1 — Foundations (week‑sized units)
1. **Git server wrapper**
   - Add `start-git-http.sh` to run reference **git** server via supergateway (port 3335).
   - Acceptance: tools list returns `git/*`; `git/log`, `git/diff`, `git/status` return correct output.
2. **Filesystem guarded writes (behind SAFE_WRITE)**
   - Implement **dry‑run** multi‑edit with unified diff + `apply_token`; exact‑match apply.
   - Acceptance: dry‑run never touches disk; apply requires matching token; backup created.
3. **Dynamic Roots support & tests**
   - Honor client **roots**; write conformance tests (switch projects without restart).
   - Acceptance: changing roots in client restricts operations immediately; tests pass.
4. **Ripgrep options passthrough**
   - Expose common flags (`--type`, `--hidden`, `--fixed-strings`, `--count`, `--glob`).
   - Acceptance: tool validates inputs and forwards to `rg`; snapshot tests for results.

### M2 — Safe Write via PR
5. **PR workflow (GitHub first)**
   - Two‑step: `pr_dry_run` (diff + checklist + branch proposal) → `pr_apply` (branch → commit → push → PR via `gh`).
   - Fallback: if no remote, write `.patch` to `.mcp-dev-tools/patches`.  
   - Acceptance: PR URL returned; main is untouched; rollback succeeds on failure.
6. **Read‑only guardrails**
   - Repo root scoping; per‑op size caps; binary detection skip; denylist (secrets, `.env`, keys).
   - Acceptance: attempts to touch denied paths are refused with clear errors.

### M3 — Observability & UX
7. **Health & diagnostics**
   - `/health` & `/ready` for proxy; `doctor.sh` (checks: `rg` present, ports free, env sane).
   - Acceptance: endpoints return JSON with versions; doctor prints actionable items.
8. **Unified logging**
   - JSON logs with correlation IDs; per‑request timing; error categories; log levels.
   - Acceptance: sample load shows structured logs; can filter by request ID.

### M4 — Code Intelligence (read fidelity)
9. **Symbolic index**
   - ctags/tree‑sitter (or LSP) → tools: `symbols/list`, `symbols/find_references`, `symbols/definitions`.
   - Acceptance: on sample repos, find‑refs and defs return stable spans.
10. **Semantic index (hybrid retrieval)**
   - Incremental indexer; AST‑aware chunking; embeddings to local vector DB (e.g., Qdrant/pgvector).
   - Tools: `semantic/search`, `semantic/retrieve_context` (tight snippets + citations).  
   - Acceptance: precision@k improves on internal evals; updates on file change.

### M5 — Refactors, Tests, Security (stretch)
11. **Refactoring & codemods**
   - Language‑specific transforms (ts‑morph/jscodeshift/comby); `refactor/rename_symbol`, `codemod/run` (dry‑run + diff).
   - Acceptance: rename updates imports; project compiles on sample.
12. **Test & build surfaces**
   - `run_tests`, `run_lint`, `run_build`, `format_files` (safe & parameterized; no network).
   - Acceptance: executes subset by touched files; returns structured results.
13. **Security & policy**
   - Diff‑time secret scanning; SCA surfacing (`npm audit`/`pip‑audit`); optional OPA policy gate.
   - Acceptance: risky changes blocked pending confirmation; report attached to PR dry‑run.

---

## 9) Operational Model

- **Packaging**: publish as npm (`npx mcp-dev-tools`), plus Docker image. Cross‑platform scripts for macOS/Linux/Windows.
- **Config**: `.env` (PORT, SEARCH_PORT, GIT_PORT, REPO_ROOT, SAFE_WRITE, MAX_BYTES, DENY_GLOBS). CLI flags override env.
- **Auth (later)**: none by default; optional bearer header for SSE; OAuth only for PR creation via `gh` login.
- **Quotas/limits**: file size caps, match caps, rate limits per tool; graceful truncation with clear indicators.

---

## 10) Security Posture (baseline)

- **Local‑only default**; no outbound network except optional `gh`.
- **Roots‑scoped** access; deny symlinks escaping roots.
- **Allowlist/denylist**: configurable globs; hard‑deny secrets (`*.pem`, `id_*`, `.env*`, etc.).
- **Dry‑run by default** for any writes; hash‑locked apply; backups & undo.
- **Diff‑time scanning** for secrets; block high‑risk changes pending user review.
- **Proxy hardening**: bind to `127.0.0.1`; if remote, require auth and TLS termination in front.
- **Inspector caution**: never expose inspector/proxy on untrusted networks.

---

## 11) Acceptance Tests (per milestone)

Create a `tests/` folder with **black‑box** scripts using the MCP Inspector or CLI (e.g., `mcp tools/call`).

**M1**  
- `git/log` returns latest N commits on sample repo.  
- `fs/edit_file_dry_run` returns deterministic diff token; `apply` succeeds only with matching token.  
- Changing **Roots** in client immediately restricts path resolution.

**M2**  
- `git/pr_dry_run` on a staged change returns a checklist; `pr_apply` opens a PR and returns URL; main remains untouched.

**M3**  
- `/health` returns `{"status":"ok","version":...}`; `doctor.sh` flags missing `rg` and wrong ports.  
- Logs show correlation IDs and durations.

**M4**  
- `symbols/definitions` and `symbols/find_references` agree with LSP on test cases.  
- `semantic/search` beats BM25 baseline on prepared queries.

**M5**  
- `refactor/rename_symbol` preserves imports; `run_tests` executes only impacted tests; security gate blocks secrets in diffs.

---

## 12) Developer Experience

- **Start scripts**  
  - `start-http.sh` (main proxy, port 3333), `start-search.sh` (rg server), `start-git-http.sh` (git server).  
  - `start-all.sh` orchestrates all; prints ports and health URLs.

- **Doctor**  
  - `./scripts/doctor.sh` → checks binaries (`rg`, `gh`, `ctags`), ports, env, repo root validity.

- **Examples**  
  - `examples/clients/*.json` snippets for Claude, ChatGPT Desktop, VS Code MCP, Zed, Cursor.

- **Documentation**  
  - Per tool: purpose, inputs, outputs, limits, examples, failure modes.

---

## 13) Implementation Notes & Choices

- **Proxy**: prefer supergateway for stdio↔SSE/WS bridging; keep local by default.
- **Search**: cap previews; return relative paths; never return binary content; respect `.gitignore` by default.
- **Edits**: multi‑edit application must verify base hash; if file changed, require re‑dry‑run.
- **PR**: prefer conventional commits; generate PR template with summary, risks, and test plan.
- **Symbols**: start with **universal‑ctags**; tree‑sitter for richer spans where available.
- **Semantic**: start with local‑only options (e.g., Qdrant/pgvector) and user‑supplied embedding API key; opt‑in only.
- **Refactors**: expose only language‑safe ops; never run arbitrary shell by default.

---

## 14) Backlog (future extensions)

- **Client UX**: one‑click configs; MCP Inspector snippets; examples gallery.
- **Observability**: JSON logs → OpenTelemetry exporter; sampling; redaction of PII/secrets.
- **Performance**: concurrency controls; streaming previews; in‑memory cache of hot files.
- **Distribution**: Homebrew formula or winget; VS Code task to start servers.
- **Integrations**: GitLab/Bitbucket PRs; “fetch/docs” server; project memory resources.
- **Test & build**: detect frameworks; selective test execution; expose coverage summaries.
- **Policy**: optional OPA policies; signed commits; PR guard rules.
- **Advanced assistants**: planner/reviewer loops; migration assistants; hotspot detection by `git blame` heuristics.

---

## 15) Definition of Done (per item)

- Tool schema documented (inputs, outputs, errors, limits) with **examples**.
- Unit tests + black‑box tests via Inspector/CLI.
- Structured logs include correlation IDs, durations, and error categories.
- Security checklist run (roots, allow/deny, size caps, binary detection).
- Docs updated; examples updated; `doctor.sh` updated if prereqs changed.

---

## 16) Quick Setup Snippets

**Local repo target (override)**  
```bash
REPO_ROOT=/path/to/repo SAFE_WRITE=0 ./start-http.sh --port 3333
REPO_ROOT=/path/to/repo ./start-search.sh --port 3334
REPO_ROOT=/path/to/repo ./start-git-http.sh --port 3335
```

**Enable guarded writes**  
```bash
SAFE_WRITE=1 MAX_BYTES=500000 DENY_GLOBS="**/*.pem,**/.env*,**/id_*" ./start-http.sh
```

**Inspector (debug)**  
```bash
npx @modelcontextprotocol/inspector
# Connect to SSE: http://127.0.0.1:3333/sse
```

---

## 17) Contribution Guide (short)

- Use conventional commits; keep PRs small and focused.
- Add tests and docs for any new tool or argument.
- Avoid breaking changes to tool schemas; deprecate with warnings first.
- Run `./scripts/doctor.sh` before submitting PRs.
- Security reviews required for anything that writes to disk or touches Git state.

---

**Default Repository**: `<your-repo-path>`  
**Server Port**: 3333 (proxy), 3334 (search), 3335 (git)  
**Protocol**: stdio servers bridged to HTTP/SSE

