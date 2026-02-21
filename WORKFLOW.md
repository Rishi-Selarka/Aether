# Development Workflow

This project uses a **documentation-first workflow** with Cursor. Rules, skills, and MCP servers are configured locally in `.cursor/` (not pushed to GitHub).

## Quick Start

1. **Primary spec**: `plan.md` — read this first for architecture, tiers, and features.
2. **Start a feature**: Use `/develop [feature description]` for the full 10-step workflow.
3. **Commit**: Use `/commit` or `/commit all push` when ready.

## The 10-Step Workflow

| Phase | Steps | Purpose |
|-------|-------|---------|
| **Planning** | 1–5 | Brainstorm → Plan → Audit → Resolve → Checklist |
| **Implementation** | 6–7 | Implement → Fix (build clean) |
| **Documentation** | 8–10 | Log → Patterns → Document |

**Checkpoints**: Brief pause after each phase (planning, implementation, docs). Say "yes" to continue.

## Directory Structure

```
Docs/
├── 01_Transcripts/     # Code documentation (created as needed)
├── 02_Planning/
│   ├── Brainstorming/   # Step 1 outputs
│   └── Specs/           # Step 2 outputs
├── 03_Progress/        # Checklists, CURRENT.md, session logs
├── 04_Decisions/       # ADRs, resolution logs
├── 05_Audits/Code/     # Audit reports
├── 06_Maintenance/Patterns/
└── 99_Archives/        # Completed feature archives
```

## MCP Servers Used

| Server | Purpose |
|--------|---------|
| **XcodeBuildMCP** | Build, run on iPad simulator, test |
| **user-Figma** | Design context from Figma (when designs exist) |
| **user-context7** | Swift/SwiftUI documentation lookup |

## Skills (`.cursor/skills/`)

- `commit` — Smart git staging and conventional commits
- `development-workflow` — 10-step orchestration
- `swift-patterns` — Swift/SwiftUI/DI patterns
- `coding-standards` — Style and conventions
- `security-review` — Pre-commit security checks
- `tdd-workflow`, `ios-testing`, `test-fix` — Optional (testing de-emphasized for student challenge)

## Rules (`.cursor/rules/`)

- `plan.md` is the primary source of truth
- Documentation-first: think before coding
- Protocol-based DI for Swift
- Build must be clean (`swift build`)

## Testing

**Optional** for this Swift Student Challenge. Focus on shipping. Add tests when time permits.

## Git

- `.cursor/` is in `.gitignore` — local workflow only, not pushed
- Use `/commit` for conventional commits
- Co-Authored-By line required for AI-assisted commits
