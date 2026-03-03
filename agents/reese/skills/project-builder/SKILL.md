---
name: project-builder
description: Gate-driven build workflow for software projects. Scaffolds, plans, and builds in milestone-based stages with operator approval gates.
trigger: When asked to build, scaffold, code, fix, deploy, or manage a software project
---

# Project Builder Skill

You follow a strict gate-driven workflow for all non-trivial software projects. **Never skip a gate.**

## Workflow Overview

```
GATE 0: Receive → Understand → Confirm
GATE 1: Scaffold → Plan → Present plan → Approve
GATE 2: Branch → Build M1 → Test → Report → Approve → Merge
GATE 3: Branch → Build M2 → Test → Report → Approve → Merge
... (repeat per milestone)
```

## Gate 0: Receive & Understand

When you receive a project task:

1. Read and parse the requirements
2. Identify: language, framework, scope, complexity
3. Respond with a brief summary of your understanding
4. Ask: "Understood. Ready to scaffold?" or clarify if something is ambiguous
5. **WAIT for 👍 before proceeding**

## Gate 1: Scaffold & Plan

After operator approves Gate 0:

1. **Scaffold**: `build-handler scaffold <project-name>`
2. **Seed** (if operator provided a product description): `build-handler seed <project> <description>`
3. **Plan**: `build-handler plan <project>` — this uses Claude Code to generate an implementation plan
4. Review the generated `IMPLEMENTATION_PLAN.md`
5. Report plan summary to operator:
   - Number of milestones
   - What each milestone covers
   - Estimated complexity
6. **WAIT for 👍 before building**

## Gate 2+: Build Milestones

For each milestone:

1. **Branch**: `build-handler branch <project> milestone-N`
2. **Build**: `build-handler build-milestone <project>` — uses Claude Code to implement
3. **Test**: `build-handler test <project>`
4. **Report results** to operator:
   - What was built
   - Test results (pass/fail counts)
   - Any issues or decisions made
5. **WAIT for operator response**:
   - 👍 → `build-handler merge <project>` and proceed to next milestone
   - 🔧 → Fix the issues, re-test, re-report
   - 👀 → `build-handler diff <project>` to show changes

## Quick Fix Workflow (No Gates)

For tasks that are clearly small (< 15 min):
- Bug fixes, config changes, small refactors
- Just do the work, test it, report the result
- No gates needed

## Commands Reference

| Command | What it does |
|---|---|
| `build-handler scaffold <name>` | Create new project with create-01x-project |
| `build-handler clone <url>` | Clone existing repo |
| `build-handler clone-01x <url>` | Clone + overlay 01x system |
| `build-handler seed <project> <text>` | Write product seed |
| `build-handler seed-file <project> <file>` | Write seed from file |
| `build-handler plan <project>` | Generate implementation plan |
| `build-handler branch <project> <name>` | Create feature branch |
| `build-handler build-milestone <project>` | Build current milestone |
| `build-handler merge <project>` | Merge branch to main |
| `build-handler test <project>` | Run tests |
| `build-handler diff <project>` | Show current diff |
| `build-handler resume <project>` | Resume interrupted build |
| `build-handler list` | List all projects |
| `build-handler status <project>` | Show project status |

## Status Reporting Format

After each milestone:

```
🔫 Reese — Milestone Report

📦 Project: [name]
🌿 Branch: milestone-[N]
📋 Scope: [what this milestone covers]

✅ Completed:
- [feature 1]
- [feature 2]

🧪 Tests: [X passed, Y failed, Z skipped]

⚠️ Issues:
- [any issues or decisions]

🚪 GATE: Awaiting approval. 👍 merge | 🔧 fix | 👀 diff
```

## Critical Rules

1. **NEVER skip a gate** — always wait for operator
2. **NEVER merge without 👍** — explicit approval required
3. **Always test** before reporting a milestone complete
4. **One milestone at a time** — finish and merge before starting next
5. **All work in /workspace/projects/** — never touch system files
