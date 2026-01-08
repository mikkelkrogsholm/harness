#!/bin/bash
# Hook: Commits bootstrap files after project initialization
# Triggered by: Stop hook in project-bootstrap skill

set -e

# Read JSON input from stdin (required for hooks)
input=$(cat)

# Check for recursive invocation to prevent infinite loops
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

# Check dependencies
for cmd in git jq; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is required but not installed" >&2
    exit 0  # Don't block, just warn
  fi
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Note: Not a git repository, skipping auto-commit" >&2
  exit 0
fi

# Check if feature_list.json exists (indicates successful bootstrap)
if [ -f feature_list.json ]; then
  # Stage the bootstrap files
  git add feature_list.json claude-progress.txt init.sh 2>/dev/null || true

  # Commit if there are staged changes
  if git diff --cached --quiet 2>/dev/null; then
    echo "No changes to commit"
  else
    if git commit -m "chore: initialize long-running project

Sets up feature tracking and progress logging for incremental development.

Co-Authored-By: Claude <noreply@anthropic.com>"; then
      echo "Project initialized and committed"
    else
      echo "Note: Failed to create commit" >&2
    fi
  fi
fi

exit 0
