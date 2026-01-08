---
name: project-bootstrap
description: Initialize a project for incremental multi-session development. Use when user wants to set up a new long-running project, says "init", or no feature_list.json exists yet.
context: fork
allowed-tools:
  - Read
  - Write
  - Bash
hooks:
  Stop:
    - hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-commit.sh"
---

# Project Bootstrap

Transform a project description into scaffolding for incremental development.

## Your Task

Create three files that will guide long-running autonomous development:

### 1. feature_list.json

Create a comprehensive feature breakdown:

```json
{
  "project": "Project Name",
  "created": "2025-01-08T12:00:00Z",
  "features": [
    {
      "id": "F001",
      "priority": 1,
      "category": "core",
      "description": "Clear, testable description of the feature",
      "verification": [
        "Specific step to verify it works",
        "Another verification step"
      ],
      "passes": false,
      "completed_at": null
    }
  ]
}
```

**Feature Rules:**

- Create **50-200 features** depending on project scope
- Order by dependency (foundational features first)
- Use categories: `core`, `functional`, `ui`, `integration`, `polish`
- Set priority: 1 (critical) to 5 (nice-to-have)
- Each feature must be independently testable
- All features start with `"passes": false`
- Write clear, actionable descriptions
- Include 2-4 specific verification steps per feature

### 2. claude-progress.txt

Create a session log file:

```
# Project: [Name]
# Created: [Timestamp]
# Total Features: [Count]

## Session Log
```

### 3. init.sh

Create an environment setup script:

```bash
#!/bin/bash
set -e

# Install dependencies (customize for your stack)
npm install 2>/dev/null || pip install -r requirements.txt 2>/dev/null || true

# Add any project-specific setup here
# Examples:
# - Start development server in background
# - Set up database
# - Configure environment variables

echo "Dev environment ready"
```

Make it executable with: `chmod +x init.sh`

## Guidelines

1. **Analyze the project description** thoroughly before creating features
2. **Think about dependencies** - what needs to exist before other things can be built?
3. **Be specific** in descriptions - vague features are hard to implement and verify
4. **Consider the user's tech stack** when writing init.sh
5. **Start with core infrastructure** before UI or polish features

## Output

After creating the files, provide a summary:

- Total features created
- Breakdown by category
- First 3 features to implement
- Any assumptions made about the project
