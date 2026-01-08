#!/bin/bash
# Hook: Prevents editing feature descriptions or verification steps
# Triggered by: PreToolUse hook in incremental-workflow skill
#
# Only allows editing: passes, completed_at fields in feature_list.json
# Blocks editing: description, verification fields

# Check dependencies
for cmd in jq; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is required but not installed" >&2
    exit 2
  fi
done

# Read JSON input from stdin
input=$(cat)

# Extract tool name and input
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
tool_input=$(echo "$input" | jq -r '.tool_input // empty')

if [ -z "$tool_input" ]; then
  exit 0
fi

# Check if this edit targets feature_list.json (use basename for security)
file_path=$(echo "$tool_input" | jq -r '.file_path // empty')
file_basename=$(basename "$file_path" 2>/dev/null)

if [ "$file_basename" != "feature_list.json" ]; then
  exit 0
fi

# For Write tool - compare protected fields structure
if [ "$tool_name" = "Write" ]; then
  content=$(echo "$tool_input" | jq -r '.content // empty')

  # If feature_list.json doesn't exist yet, allow the write
  if [ ! -f feature_list.json ]; then
    exit 0
  fi

  # Validate JSON structure
  if ! echo "$content" | jq empty 2>/dev/null; then
    echo "Error: Invalid JSON in new content" >&2
    exit 2
  fi

  # Extract and compare protected fields (description + verification)
  existing_protected=$(jq -c '[.features[] | {d: .description, v: .verification}]' feature_list.json 2>/dev/null || echo "[]")
  new_protected=$(echo "$content" | jq -c '[.features[] | {d: .description, v: .verification}]' 2>/dev/null || echo "null")

  if [ "$new_protected" = "null" ]; then
    echo "Error: Invalid feature structure in new content" >&2
    exit 2
  fi

  if [ "$existing_protected" != "$new_protected" ]; then
    echo "Cannot modify feature descriptions or verification steps. Only 'passes' and 'completed_at' fields can be changed." >&2
    exit 2
  fi
fi

# For Edit tool - check old_string for protected field patterns
if [ "$tool_name" = "Edit" ]; then
  old_string=$(echo "$tool_input" | jq -r '.old_string // empty')

  # Pattern to detect description or verification field modifications
  protected_pattern='"(description|verification)"[[:space:]]*:'

  if echo "$old_string" | grep -qE "$protected_pattern"; then
    echo "Cannot edit feature descriptions or verification steps. Only 'passes' and 'completed_at' fields can be modified." >&2
    exit 2
  fi
fi

exit 0
