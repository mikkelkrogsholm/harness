#!/bin/bash
# Hook: Prevents editing feature descriptions or verification steps
# Triggered by: PreToolUse hook in incremental-workflow skill
#
# Only allows editing: passes, completed_at fields in feature_list.json
# Blocks editing: description, verification fields

# Read JSON input from stdin
input=$(cat)

# Extract tool input
tool_input=$(echo "$input" | jq -r '.tool_input // empty')

if [ -z "$tool_input" ]; then
  exit 0
fi

# Check if this edit targets feature_list.json
file_path=$(echo "$tool_input" | jq -r '.file_path // empty')

if [[ "$file_path" != *"feature_list.json"* ]]; then
  exit 0
fi

# Check for old_string or content that modifies protected fields
old_string=$(echo "$tool_input" | jq -r '.old_string // empty')
new_string=$(echo "$tool_input" | jq -r '.new_string // empty')
content=$(echo "$tool_input" | jq -r '.content // empty')

# Pattern to detect description or verification field modifications
# This catches attempts to change the actual content of these fields
protected_pattern='"(description|verification)"[[:space:]]*:'

if echo "$old_string" | grep -qE "$protected_pattern"; then
  echo "Cannot edit feature descriptions or verification steps. Only 'passes' and 'completed_at' fields can be modified." >&2
  exit 2
fi

if echo "$content" | grep -qE "$protected_pattern"; then
  # For Write tool, we need to verify the content matches existing structure
  # This is a simplified check - in production you'd compare JSON structures
  if [ -f feature_list.json ]; then
    existing_features=$(jq -r '.features[].description' feature_list.json 2>/dev/null | sort)
    new_features=$(echo "$content" | jq -r '.features[].description' 2>/dev/null | sort)

    if [ "$existing_features" != "$new_features" ]; then
      echo "Cannot modify feature descriptions. Only 'passes' and 'completed_at' fields can be changed." >&2
      exit 2
    fi
  fi
fi

exit 0
