---
name: incremental-workflow
description: Work on a long-running project incrementally. Use when feature_list.json exists and user wants to continue, make progress, implement features, or work on the project.
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/prevent-feature-edit.sh"
  Stop:
    - hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/verify-clean-state.sh"
---

# Incremental Workflow

Implement ONE feature, verify it, commit, and exit. The orchestrator will call you repeatedly for each feature.

## Input

You will be given a specific feature ID to implement. Focus ONLY on that feature.

## Workflow

### 1. Ensure Clean State

```bash
git status --short
```

If uncommitted changes exist, commit or discard them first.

### 2. Start Environment (if needed)

```bash
if [ -f init.sh ]; then ./init.sh; fi
```

### 3. Get Feature Details

```bash
FEATURE_ID="[THE_FEATURE_ID]"  # Use the ID you were given
jq -r '.features[] | select(.id == "'$FEATURE_ID'")' feature_list.json
```

### 4. Implement

Write minimal code for THIS feature only.

**Rules:**
- No scope creep
- No "while I'm here" fixes
- No premature optimization
- Focus ONLY on the assigned feature

### 5. Verify

Test against the feature's `verification` steps:
1. Read verification steps from the feature
2. Actually perform each step
3. If any fails, fix before proceeding

### 6. Mark Complete

```bash
jq '(.features[] | select(.id == "'$FEATURE_ID'")) |= . + {"passes": true, "completed_at": "'"$(date -Iseconds)"'"}' feature_list.json > tmp.json && mv tmp.json feature_list.json
```

### 7. Commit

```bash
git add -A
git commit -m "feat($FEATURE_ID): [short description]

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 8. Log Progress

Append to `claude-progress.txt`:
```
- [TIMESTAMP] Completed $FEATURE_ID: [description] ([commit hash])
```

### 9. Exit

Return to the orchestrator with:
- **SUCCESS**: Feature ID completed
- **BLOCKED**: Feature ID blocked, reason: [explanation]

## Rules

### DO:
- ✅ Implement ONLY the assigned feature
- ✅ Test before marking complete
- ✅ Commit before exiting
- ✅ Exit after ONE feature

### DON'T:
- ❌ Implement multiple features
- ❌ Mark complete without testing
- ❌ Edit feature descriptions (hook blocks this)
- ❌ Leave uncommitted changes (hook blocks this)
- ❌ Continue to next feature (orchestrator handles that)
