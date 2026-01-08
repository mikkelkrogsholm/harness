#!/bin/bash
# Hook: Commits bootstrap files after project initialization
# Triggered by: Stop hook in project-bootstrap skill

set -e

# Check if feature_list.json exists (indicates successful bootstrap)
if [ -f feature_list.json ]; then
  # Stage the bootstrap files
  git add feature_list.json claude-progress.txt init.sh 2>/dev/null || true

  # Commit if there are staged changes
  if git diff --cached --quiet 2>/dev/null; then
    echo "No changes to commit"
  else
    git commit -m "chore: initialize long-running project

Sets up feature tracking and progress logging for incremental development.

Co-Authored-By: Claude <noreply@anthropic.com>" 2>/dev/null || true
    echo "Project initialized and committed"
  fi
fi

exit 0
