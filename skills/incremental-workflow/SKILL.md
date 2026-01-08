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

Implement ONE feature at a time with proper testing and documentation.

## Session Start Sequence

### 1. Orient Yourself

Run this to understand current state:

```bash
echo "=== Project Status ==="
TOTAL=$(jq '.features | length' feature_list.json)
DONE=$(jq '[.features[] | select(.passes == true)] | length' feature_list.json)
echo "Progress: $DONE / $TOTAL features"
echo ""
echo "Last session:"
tail -20 claude-progress.txt | grep -A5 "^## Session" | tail -6
echo ""
echo "Git status:"
git status --short
echo "======================"
```

### 2. Check State

If uncommitted changes exist, resolve them first:

- Review what changed with `git diff`
- Commit, stash, or discard as appropriate
- **Never start new work on a dirty state**

### 3. Start Environment

```bash
./init.sh
```

### 4. Smoke Test

Verify basic functionality still works before making changes.

## Select Next Feature

Find the highest priority incomplete feature:

```bash
jq -r '[.features[] | select(.passes == false)] | sort_by(.priority) | .[0] | "Next: \(.id) [\(.category)] - \(.description)"' feature_list.json
```

## Implementation Cycle

### Step 1: Announce

State clearly what you're working on:

> "Implementing **F00X**: [description]"

### Step 2: Implement

Write minimal code for THIS feature only.

**Rules:**
- No scope creep
- No "while I'm here" fixes
- No premature optimization
- Log unrelated issues for later

### Step 3: Verify

Test against the feature's `verification` steps:

1. Read the verification steps from feature_list.json
2. Actually perform each step
3. Confirm expected behavior
4. If any step fails, fix before proceeding

### Step 4: Mark Complete

Update the feature status:

```bash
jq '(.features[] | select(.id == "F00X")) |= . + {"passes": true, "completed_at": "'"$(date -Iseconds)"'"}' feature_list.json > tmp.json && mv tmp.json feature_list.json
```

### Step 5: Commit

```bash
git add -A
git commit -m "feat(F00X): [description]

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 6: Log Progress

Append to `claude-progress.txt`:

```
## Session: [YYYY-MM-DD HH:MM]
- Implemented: F00X - [description]
- Commit: [short hash from git log -1 --format=%h]
- Next: F00Y - [description]
- Notes: [any context for future sessions]
```

## Rules

### DO:
- ✅ ONE feature at a time
- ✅ Test before marking complete
- ✅ Commit after each feature
- ✅ Update progress log
- ✅ Keep commits atomic and focused

### DON'T:
- ❌ Start second feature before first is done
- ❌ Mark complete without testing
- ❌ Edit feature descriptions (hook blocks this)
- ❌ Leave uncommitted changes (hook blocks this)
- ❌ Skip verification steps

## Output

After completing work, return a summary:

- Features completed this session
- Current progress (X / Y total)
- Suggested next feature
- Any blockers or issues encountered
