---
description: Initialize a new long-running project for incremental development
argument-hint: <project description>
---

# Initialize Long-Running Project

Set up a new project for incremental multi-session development.

## Project Description

The user wants to build: **$ARGUMENTS**

## Instructions

Use the `project-bootstrap` skill to create the project scaffolding:

1. **feature_list.json** - Comprehensive feature breakdown (50-200 features)
2. **claude-progress.txt** - Session log for tracking progress
3. **init.sh** - Development environment setup script

The skill runs in a forked context and will automatically commit the files when complete.

## After Initialization

Return a summary including:
- Total features created
- Breakdown by category
- First 3 features to implement
- How to continue development with `/harness:continue`
