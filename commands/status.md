---
description: Show project status without making changes
allowed-tools:
  - Read
  - Bash
---

# Project Status

Show the current status of the long-running project without making any changes.

## Check Project Exists

First verify a long-running project is set up:

```bash
if [ ! -f feature_list.json ]; then
  echo "No long-running project found in this directory."
  echo "Run /harness:init to set one up."
  exit 0
fi
```

## Gather Status Information

If the project exists, gather and display:

### Overall Progress

```bash
TOTAL=$(jq '.features | length' feature_list.json)
DONE=$(jq '[.features[] | select(.passes == true)] | length' feature_list.json)
PERCENT=$((DONE * 100 / TOTAL))
echo "Progress: $DONE / $TOTAL ($PERCENT%)"
```

### Progress by Category

```bash
jq -r '
  .features | group_by(.category) | .[] |
  "\(.[0].category): \([.[] | select(.passes)] | length)/\(length)"
' feature_list.json
```

### Recent Sessions

```bash
echo "Recent sessions:"
grep -A3 "^## Session" claude-progress.txt 2>/dev/null | tail -12
```

### Git State

```bash
echo "Recent commits:"
git log --oneline -5
echo ""
echo "Working tree:"
git status --short
```

### Next Feature

```bash
jq -r '[.features[] | select(.passes == false)] | sort_by(.priority) | .[0] | "Next: \(.id) [\(.category)] - \(.description)"' feature_list.json
```

## Present the Information

Format the gathered information clearly for the user:

- **Overall progress** with percentage
- **Category breakdown** showing completion per category
- **Recent activity** from the session log
- **Git state** including recent commits and any uncommitted changes
- **Next feature** to implement

Do not make any changes to files - this is a read-only status check.
