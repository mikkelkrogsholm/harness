---
description: Autonomously implement ALL remaining features until complete
allowed-tools:
  - Bash(*)
  - Read
---

# Continue Development (Autonomous)

You will work through ALL remaining features until the project is complete. Do NOT stop after one feature.

## Pre-flight

```bash
if [ ! -f feature_list.json ]; then
  echo "ERROR: No feature_list.json found. Run /harness:init first."
  exit 1
fi
```

## The Loop

Execute this loop until no incomplete features remain:

```
WHILE incomplete features exist:
    1. Get next incomplete feature (lowest priority number first)
    2. Use the incremental-workflow skill to implement it
    3. Check result
    4. CONTINUE to next feature (do NOT stop)
END WHILE
```

### Get Next Feature

```bash
jq -r '[.features[] | select(.passes == false)] | sort_by(.priority) | .[0] | "\(.id): \(.description)"' feature_list.json
```

If this returns null/empty → ALL DONE. Report completion and stop.

### Implement Feature

Use the `incremental-workflow` skill:

> Implement feature [ID]: [DESCRIPTION]

The skill runs in a forked context. It will implement, verify, commit, and return.

### After Each Feature

- Re-read `feature_list.json` to get the next incomplete feature
- If feature was blocked, log it and continue to next
- **DO NOT STOP** - immediately proceed to the next feature

## Critical Rules

1. **KEEP GOING** - Do not stop after one feature
2. **ONE AT A TIME** - Use the skill once per feature (fresh context each time)
3. **NO DIRECT IMPLEMENTATION** - Always delegate to the skill, never implement features yourself
4. **LOOP UNTIL DONE** - Only stop when ALL features pass or all remaining are blocked

## Completion

When no incomplete features remain:

```bash
TOTAL=$(jq '.features | length' feature_list.json)
DONE=$(jq '[.features[] | select(.passes)] | length' feature_list.json)
echo "COMPLETE: $DONE / $TOTAL features"
```

Report:
- Features completed this session
- Any blocked features with reasons
- Final status: COMPLETE or BLOCKED
