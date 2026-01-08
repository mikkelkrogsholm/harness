---
description: Autonomously implement ALL remaining features until complete
allowed-tools:
  - Bash(*)
  - Read
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

## Orchestration Loop

You are the orchestrator. Your job is to loop through features and delegate each one to the `incremental-workflow` skill.

### Step 1: Read the feature list

Read `feature_list.json` and identify all incomplete features (where `passes` is `false`), sorted by priority.

### Step 2: For EACH incomplete feature

Call the `incremental-workflow` skill, passing the feature ID:

```
Use the incremental-workflow skill to implement feature [FEATURE_ID]: [DESCRIPTION]
```

The skill runs in a **forked context** - it will:
- Implement that ONE feature
- Verify it passes
- Commit the changes
- Exit back to you

### Step 3: Check result and continue

After each skill invocation:
- If successful: proceed to next feature
- If blocked: log the blocker, skip to next feature
- If all features done: report completion

### Step 4: Repeat until done

Keep calling the skill for each feature until:
- All features pass → Project COMPLETE
- All remaining features are blocked → Report blockers

## Important

- Call the skill ONCE per feature (each call gets fresh context)
- Pass the specific feature ID to the skill
- Do NOT try to implement multiple features in one skill call
- The skill handles: implementation, verification, commit, logging

## Final Output

When finished:
- Total features completed this session
- Final progress (X / Y)
- Any blocked features with reasons
- Project status: COMPLETE or BLOCKED
