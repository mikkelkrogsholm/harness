---
description: Continue incremental development on a long-running project
allowed-tools:
  - Bash(*)
---

# Continue Development

Continue incremental development on the current long-running project.

## Pre-flight Check

First, verify the project is initialized:

```bash
if [ ! -f feature_list.json ]; then
  echo "ERROR: No feature_list.json found"
  echo "Run /harness:init first to set up the project"
  exit 1
fi
echo "Project found"
```

If `feature_list.json` doesn't exist, tell the user to run `/harness:init` first.

## Instructions

Use the `incremental-workflow` skill to:

1. **Orient** - Check project status, last session, git state
2. **Select** - Pick the next feature by priority
3. **Implement** - Write code for ONE feature
4. **Verify** - Test against the feature's verification steps
5. **Commit** - Create an atomic commit
6. **Log** - Update progress file

The skill runs in a forked context with hooks that:
- Block editing feature descriptions (preserves original specs)
- Block stopping with uncommitted changes (ensures clean state)

## After Work

Return a summary of:
- Features completed this session
- Current progress (completed / total)
- Suggested next feature
- Any issues or blockers
