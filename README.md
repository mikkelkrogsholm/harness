# Harness

A Claude Code plugin for autonomous multi-session development. Based on [Anthropic's research on effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

## Philosophy

Large projects can't be completed in a single session. This plugin provides a framework for:

- **Breaking work into discrete features** - 50-200 testable features per project
- **Implementing one feature at a time** - Focus prevents scope creep
- **Maintaining clean state between sessions** - Git commits after each feature
- **Preserving original specifications** - Hooks prevent editing feature descriptions
- **Tracking progress visibly** - Session logs and git history tell the story

## Installation

### From Local Directory

```bash
claude plugin install /path/to/harness
```

Or in Claude Code interactive mode:
```
/plugin install /path/to/harness
```

### From GitHub

```bash
claude plugin install https://github.com/mikkelkrogsholm/harness
```

## Usage

### 1. Initialize a Project

```
/harness:init Build a task management app with auth, projects, and real-time sync
```

This creates:
- `feature_list.json` - All features with status tracking
- `claude-progress.txt` - Session log
- `init.sh` - Development environment setup

### 2. Continue Development

```
/harness:continue
```

This runs the incremental workflow:
1. Checks project status and git state
2. Selects next feature by priority
3. Implements ONE feature
4. Verifies against test criteria
5. Commits changes
6. Logs progress

### 3. Check Status

```
/harness:status
```

Shows progress without making changes:
- Overall completion percentage
- Progress by category
- Recent session activity
- Git state
- Next feature to implement

## How It Works

### Two Skills, Both Forked

| Skill | Purpose | Hooks |
|-------|---------|-------|
| `project-bootstrap` | Creates feature list, progress log, init script | Stop: Auto-commits bootstrap files |
| `incremental-workflow` | Implements features one at a time | PreToolUse: Blocks editing feature specs<br>Stop: Requires clean git state |

### Hook Enforcement

The plugin uses hooks to enforce discipline:

**PreToolUse Hook** (incremental-workflow):
- Blocks any attempt to edit `description` or `verification` fields in `feature_list.json`
- Only `passes` and `completed_at` can be modified
- Ensures original specifications are preserved

**Stop Hook** (incremental-workflow):
- Checks for uncommitted changes
- Blocks stopping if working tree is dirty
- Forces clean handoffs between sessions

**Stop Hook** (project-bootstrap):
- Auto-commits bootstrap files after initialization
- Creates clean starting point for development

### Files Created

| File | Purpose |
|------|---------|
| `feature_list.json` | Feature tracking with status, priority, verification steps |
| `claude-progress.txt` | Session-by-session log of what was accomplished |
| `init.sh` | Script to set up development environment |

### Feature Structure

```json
{
  "id": "F001",
  "priority": 1,
  "category": "core",
  "description": "Clear, testable description",
  "verification": [
    "Step to verify it works",
    "Another verification step"
  ],
  "passes": false,
  "completed_at": null
}
```

Categories: `core`, `functional`, `ui`, `integration`, `polish`

Priority: 1 (critical) → 5 (nice-to-have)

## Directory Structure

```
harness/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/
│   ├── project-bootstrap/
│   │   └── SKILL.md         # Bootstrap skill
│   └── incremental-workflow/
│       └── SKILL.md         # Workflow skill
├── commands/
│   ├── init.md              # /harness:init
│   ├── continue.md          # /harness:continue
│   └── status.md            # /harness:status
├── scripts/
│   ├── bootstrap-commit.sh  # Stop hook for bootstrap
│   ├── prevent-feature-edit.sh  # PreToolUse hook
│   └── verify-clean-state.sh    # Stop hook for workflow
└── README.md
```

## Requirements

- Claude Code 2.1.0+ (for skill hooks and `context: fork`)
- Git (for commit hooks)
- jq (for JSON processing in status commands)

## Tips

### Starting Fresh
If you want to restart a project, delete the generated files:
```bash
rm feature_list.json claude-progress.txt init.sh
```

### Resuming After a Break
Always run `/harness:status` first to understand where you left off.

### When Features Need Changes
The hooks prevent editing feature descriptions to preserve original intent. If you truly need to change a feature's definition:
1. Complete or skip the current feature
2. Manually edit `feature_list.json` outside of Claude Code
3. Continue with `/harness:continue`

### Viewing Progress
```bash
# Quick progress check
jq '[.features[] | select(.passes)] | length' feature_list.json

# See all completed features
jq '.features[] | select(.passes) | .id + ": " + .description' feature_list.json
```

## License

MIT
