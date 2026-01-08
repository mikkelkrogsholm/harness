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

Autonomously implement ALL features until complete. Work through features by priority, committing after each one.

## Session Start

### 1. Orient

```bash
echo "=== Project Status ==="
TOTAL=$(jq '.features | length' feature_list.json)
DONE=$(jq '[.features[] | select(.passes == true)] | length' feature_list.json)
echo "Progress: $DONE / $TOTAL features"
echo ""
echo "Git status:"
git status --short
echo "======================"
```

### 2. Ensure Clean State

If uncommitted changes exist:
- Review with `git diff`
- Commit or discard
- **Never start on dirty state**

### 3. Start Environment

```bash
./init.sh
```

## Autonomous Loop

**Repeat until all features pass:**

### For Each Feature:

#### 1. Select Next

```bash
NEXT=$(jq -r '[.features[] | select(.passes == false)] | sort_by(.priority) | .[0] | .id' feature_list.json)
if [ "$NEXT" = "null" ] || [ -z "$NEXT" ]; then
  echo "ALL FEATURES COMPLETE"
  exit 0
fi
jq -r '.features[] | select(.id == "'$NEXT'") | "Implementing \(.id): \(.description)"' feature_list.json
```

#### 2. Implement

Write minimal code for THIS feature only.

**Rules:**
- No scope creep
- No "while I'm here" fixes
- No premature optimization

#### 3. Verify

Test against the feature's `verification` steps:
1. Read verification steps from feature_list.json
2. Actually perform each step
3. If any fails, fix before proceeding

#### 4. Mark Complete

```bash
FEATURE_ID="F00X"  # Replace with actual ID
jq '(.features[] | select(.id == "'$FEATURE_ID'")) |= . + {"passes": true, "completed_at": "'"$(date -Iseconds)"'"}' feature_list.json > tmp.json && mv tmp.json feature_list.json
```

#### 5. Commit

```bash
git add -A
git commit -m "feat($FEATURE_ID): [description]

Co-Authored-By: Claude <noreply@anthropic.com>"
```

#### 6. Log

Append to `claude-progress.txt`:
```
- [TIMESTAMP] Completed $FEATURE_ID: [description] ([commit hash])
```

#### 7. Continue to Next Feature

Do NOT stop. Immediately proceed to the next incomplete feature.

## Stopping Conditions

Only stop when:
1. **All features pass** - Project complete
2. **Unrecoverable blocker** - Document the issue and stop
3. **External dependency required** - Document what's needed

If a feature is blocked but others can proceed, skip it and continue. Log the blocker.

## Rules

### DO:
- ✅ Keep going until ALL features complete
- ✅ Test before marking complete
- ✅ Commit after each feature
- ✅ Skip blocked features, continue with others
- ✅ Log everything

### DON'T:
- ❌ Stop after one feature (keep going!)
- ❌ Mark complete without testing
- ❌ Edit feature descriptions (hook blocks this)
- ❌ Leave uncommitted changes
- ❌ Give up on first error

## Final Output

When ALL features complete (or all remaining are blocked):

- Total features completed this session
- Final progress (X / Y total)
- Any blocked features with reasons
- Project status: COMPLETE or BLOCKED
