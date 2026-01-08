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
    2. Call incremental-workflow skill (context: fork)
    3. Skill implements ONE feature, commits
    4. Return to orchestrator, continue to next
END WHILE
```

Each skill invocation gets a **fresh forked context** - no token buildup between features.

### Key Files

| File | Purpose |
|------|---------|
| `commands/init.md` | Triggers project-bootstrap skill |
| `commands/continue.md` | Orchestrates the feature loop |
| `commands/status.md` | Read-only status check |
| `skills/project-bootstrap/SKILL.md` | Creates feature_list.json, init.sh, progress log |
| `skills/incremental-workflow/SKILL.md` | Implements ONE feature per invocation |
| `scripts/prevent-feature-edit.sh` | PreToolUse hook - blocks editing feature specs |
| `scripts/verify-clean-state.sh` | Stop hook - requires clean git before stopping |
| `scripts/bootstrap-commit.sh` | Stop hook - auto-commits bootstrap files |

### Hook Scripts

All hooks receive JSON via stdin and must:
- Parse with `jq`
- Output errors to stderr (not stdout)
- Exit 0 to allow, exit 2 to block with message
- Check `stop_hook_active` to prevent infinite loops

## Development Guidelines

### When Modifying Skills

- Skills use `context: fork` for isolated execution
- The `allowed-tools` field controls what tools the skill can use
- Hooks are defined in the skill frontmatter

### When Modifying Hooks

- Always read JSON from stdin: `input=$(cat)`
- Check for `stop_hook_active` field to prevent recursion
- Use stderr for error messages: `echo "message" >&2`
- Validate dependencies (jq, git) exist before using

### Testing

To test the plugin:

1. Install it: `claude plugin install /path/to/harness`
2. Create a test project directory
3. Run `/harness:init <simple project description>`
4. Run `/harness:continue` and observe the loop

## Files Created by Plugin (in target project)

| File | Created By | Purpose |
|------|------------|---------|
| `feature_list.json` | project-bootstrap | Feature tracking |
| `claude-progress.txt` | project-bootstrap | Session log |
| `init.sh` | project-bootstrap | Dev environment setup |
