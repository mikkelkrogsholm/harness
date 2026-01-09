# CLAUDE.md

This is a Claude Code plugin called **harness** for autonomous multi-session development.

## What This Plugin Does

When installed, it provides three slash commands:

- `/harness:init <description>` - Creates a feature list (50-200 features) from a project description
- `/harness:continue` - Autonomously implements ALL features until complete
- `/harness:status` - Shows progress without making changes

## Architecture

### Orchestrator Pattern

The `/harness:continue` command is an **orchestrator** that loops through features:

```
WHILE incomplete features exist:
    1. Get next feature by priority
    2. Call incremental-workflow agent (isolated context)
    3. Agent implements ONE feature, commits
    4. Return to orchestrator, continue to next
END WHILE
```

Each agent invocation gets a **fresh isolated context** - no token buildup between features.

### Two Agents

| Agent | Purpose | Key Features |
|-------|---------|--------------|
| `project-bootstrap` | Creates feature list, progress log, init script | Asks clarifying questions, researches documentation, creates features with doc URLs |
| `incremental-workflow` | Implements ONE feature per invocation | Consults documentation before implementing, verifies, commits |

### Key Files

| File | Purpose |
|------|---------|
| `commands/init.md` | Triggers project-bootstrap agent |
| `commands/continue.md` | Orchestrates the feature loop |
| `commands/status.md` | Read-only status check |
| `agents/project-bootstrap.md` | Creates feature_list.json, init.sh, progress log |
| `agents/incremental-workflow.md` | Implements ONE feature per invocation |
| `scripts/prevent-feature-edit.sh` | PreToolUse hook - blocks editing feature specs |
| `scripts/verify-clean-state.sh` | Stop hook - requires clean git before stopping |
| `scripts/bootstrap-commit.sh` | Stop hook - auto-commits bootstrap files |

### Bootstrap Process (project-bootstrap agent)

The bootstrap agent follows three phases:

1. **Phase 1: Critical Review & Clarification**
   - Analyzes project description for gaps
   - Asks clarifying questions (tech stack, auth, scope, integrations)
   - Documents assumptions explicitly

2. **Phase 2: Research Documentation**
   - Identifies all technologies to be used
   - Searches for official documentation URLs
   - Collects references for each feature

3. **Phase 3: Create Feature List**
   - Generates 50-200 features with documentation URLs
   - Creates progress log and init script
   - Auto-commits via Stop hook

### Feature Implementation (incremental-workflow agent)

Each feature implementation follows this workflow:

1. Ensure clean git state
2. Get feature details from feature_list.json
3. **Consult documentation URLs** before implementing
4. Implement following official patterns
5. Verify against verification steps
6. Mark complete and commit
7. Log progress and exit

### Feature Schema

```json
{
  "project": "Project Name",
  "tech_stack": {
    "frontend": "Next.js 14",
    "backend": "Node.js",
    "database": "PostgreSQL"
  },
  "assumptions": [
    "Single-tenant application",
    "English only"
  ],
  "features": [
    {
      "id": "F001",
      "priority": 1,
      "category": "core",
      "description": "Set up Next.js project",
      "verification": ["npm run dev works", "TypeScript compiles"],
      "documentation": [
        "https://nextjs.org/docs/getting-started",
        "https://nextjs.org/docs/app/building-your-application"
      ],
      "passes": false,
      "completed_at": null
    }
  ]
}
```

### Hook Scripts

All hooks receive JSON via stdin and must:
- Parse with `jq`
- Output errors to stderr (not stdout)
- Exit 0 to allow, exit 2 to block with message
- Check `stop_hook_active` to prevent infinite loops

## Development Guidelines

### When Modifying Agents

- Agents run in their own isolated context automatically
- The `tools` field controls what tools the agent can use
- Hooks are defined in the agent frontmatter
- `project-bootstrap` uses: Read, Write, Bash, WebSearch, WebFetch, AskUserQuestion
- `incremental-workflow` uses: Read, Write, Edit, Bash, Grep, Glob, WebFetch

### When Modifying Hooks

- Always read JSON from stdin: `input=$(cat)`
- Check for `stop_hook_active` field to prevent recursion
- Use stderr for error messages: `echo "message" >&2`
- Validate dependencies (jq, git) exist before using

### Testing

To test the plugin:

1. Load it: `claude --plugin-dir /path/to/harness`
2. Create a test project directory
3. Run `/harness:init <simple project description>`
4. Answer clarifying questions when prompted
5. Run `/harness:continue` and observe the loop

## Files Created by Plugin (in target project)

| File | Created By | Purpose |
|------|------------|---------|
| `feature_list.json` | project-bootstrap | Feature tracking with documentation URLs |
| `claude-progress.txt` | project-bootstrap | Session log with assumptions |
| `init.sh` | project-bootstrap | Dev environment setup |
