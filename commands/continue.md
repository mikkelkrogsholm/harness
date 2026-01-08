---
description: Autonomously implement ALL remaining features until complete
allowed-tools:
  - Bash(*)
---

# Continue Development (Autonomous)

Autonomously work through ALL remaining features until the project is complete.

## Pre-flight Check

```bash
if [ ! -f feature_list.json ]; then
  echo "ERROR: No feature_list.json found"
  echo "Run /harness:init first to set up the project"
  exit 1
fi
echo "Project found"
```

## Behavior

The `incremental-workflow` skill will:

1. **Loop through ALL incomplete features** by priority
2. For each feature: implement → verify → commit → log
3. **Skip blocked features** and continue with others
4. **Only stop when:**
   - All features pass (project complete)
   - All remaining features are blocked
   - Unrecoverable error

The skill runs in a forked context with hooks that:
- Block editing feature descriptions (preserves original specs)
- Block stopping with uncommitted changes (ensures clean state)

## Output

When finished:
- Total features completed this session
- Final progress (X / Y)
- Any blocked features with reasons
- Project status: COMPLETE or BLOCKED
