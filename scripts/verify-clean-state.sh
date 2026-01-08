#!/bin/bash
# Hook: Verifies clean git state before allowing workflow to stop
# Triggered by: Stop hook in incremental-workflow skill
#
# Blocks stopping if:
# - There are uncommitted changes
# - No progress was logged today (warning only)

# Check if we're in a long-running project
if [ ! -f feature_list.json ]; then
  exit 0
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "Uncommitted changes detected. Please commit your work before stopping." >&2
  echo "" >&2
  echo "Uncommitted files:" >&2
  git status --porcelain >&2
  exit 2
fi

# Check if progress was logged today (warning, not blocking)
TODAY=$(date +%Y-%m-%d)
if [ -f claude-progress.txt ]; then
  if ! grep -q "$TODAY" claude-progress.txt 2>/dev/null; then
    echo "Note: No progress logged today. Consider adding a session entry to claude-progress.txt" >&2
  fi
fi

echo "Clean state verified"
exit 0
