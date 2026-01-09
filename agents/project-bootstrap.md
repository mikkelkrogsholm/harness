---
name: project-bootstrap
description: Initialize a project for incremental multi-session development. Use when user wants to set up a new long-running project, says "init", or no feature_list.json exists yet.
tools: Read, Write, Bash, WebSearch, WebFetch, AskUserQuestion
hooks:
  Stop:
    - hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-commit.sh"
---

# Project Bootstrap

Transform a project description into scaffolding for incremental development.

## Phase 1: Critical Review & Clarification

**BEFORE generating any features**, analyze the project description critically:

### Step 1: Identify Gaps

Ask yourself:
- Is the tech stack specified? (frontend, backend, database, etc.)
- Are there ambiguous requirements?
- What constraints are missing? (auth method, hosting, scale, etc.)
- What domain knowledge is needed?

### Step 2: Ask Clarifying Questions

Use `AskUserQuestion` to gather missing information. Example questions:

- **Tech Stack**: "What technologies should I use? (React/Vue/Svelte, Node/Python/Go, PostgreSQL/MongoDB, etc.)"
- **Auth**: "What authentication method? (OAuth, JWT, email/password, SSO)"
- **Scope**: "Is this an MVP or full product? Should I include admin features?"
- **Integrations**: "Any third-party services to integrate? (Stripe, SendGrid, AWS, etc.)"
- **Constraints**: "Any specific requirements? (offline support, i18n, accessibility)"

**Do NOT proceed until you have enough clarity to create specific, implementable features.**

### Step 3: Document Assumptions

If the user says "just use sensible defaults", document your assumptions explicitly in the feature list metadata.

---

## Phase 2: Research Documentation

Before creating features, search for relevant documentation for the chosen tech stack:

### Step 1: Identify Technologies

List all technologies, libraries, and APIs that will be used.

### Step 2: Find Documentation URLs

Use `WebSearch` to find official documentation for each technology:
- Framework docs (Next.js, SvelteKit, Django, etc.)
- Library docs (Auth libraries, ORMs, UI components)
- API docs (External services being integrated)

### Step 3: Save Documentation References

Each feature should include relevant documentation URLs that the implementing agent will need.

---

## Phase 3: Create Feature List

Create three files that will guide long-running autonomous development:

### 1. feature_list.json

Create a comprehensive feature breakdown with documentation references:

```json
{
  "project": "Project Name",
  "created": "2025-01-08T12:00:00Z",
  "tech_stack": {
    "frontend": "Next.js 14",
    "backend": "Node.js with tRPC",
    "database": "PostgreSQL with Drizzle ORM",
    "auth": "Better Auth",
    "styling": "Tailwind CSS + shadcn/ui"
  },
  "assumptions": [
    "Single-tenant application",
    "English only (no i18n)",
    "Desktop-first responsive design"
  ],
  "features": [
    {
      "id": "F001",
      "priority": 1,
      "category": "core",
      "description": "Set up Next.js 14 project with App Router and TypeScript",
      "verification": [
        "Run `npm run dev` starts development server",
        "Navigate to localhost:3000 shows default page",
        "TypeScript compilation succeeds with no errors"
      ],
      "documentation": [
        "https://nextjs.org/docs/getting-started/installation",
        "https://nextjs.org/docs/app/building-your-application/routing"
      ],
      "passes": false,
      "completed_at": null
    },
    {
      "id": "F002",
      "priority": 1,
      "category": "core",
      "description": "Configure Drizzle ORM with PostgreSQL connection",
      "verification": [
        "Database connection succeeds",
        "Can run `npm run db:push` to sync schema",
        "Drizzle Studio accessible via `npm run db:studio`"
      ],
      "documentation": [
        "https://orm.drizzle.team/docs/get-started-postgresql",
        "https://orm.drizzle.team/docs/drizzle-config-file"
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
- **Include 1-4 documentation URLs per feature** (official docs preferred)

### 2. claude-progress.txt

Create a session log file:

```
# Project: [Name]
# Created: [Timestamp]
# Total Features: [Count]
# Tech Stack: [Summary]

## Assumptions Made
- [List assumptions from clarification phase]

## Session Log
```

### 3. init.sh

Create an environment setup script tailored to the chosen stack:

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

---

## Output

After creating the files, provide a summary:

- **Clarifications received** - What questions were answered
- **Assumptions made** - What defaults were chosen
- **Tech stack** - Technologies being used
- **Total features created** - Count
- **Breakdown by category** - Features per category
- **First 3 features to implement** - Starting point
- **Key documentation** - Most important docs to reference
