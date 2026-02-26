# City Architect - Claude Code Rules

**Project**: City Architect (Swift Student Challenge 2026)
**Platform**: iPad, Swift Playgrounds 4.6+ | iOS 17.0+
**Stack**: Swift, SwiftUI, SwiftData
**Spec**: `plan.md` (authoritative - tiers, features, architecture, file structure)
**Deadline**: February 28, 2026

## Research Priority Order

**ALL research MUST follow this priority - read docs before source code:**

1. **Primary**: `plan.md` (authoritative spec: tiers, 14 screens, graph engine, particle system)
2. **Secondary**: `Docs/01_Transcripts/`, `Docs/02_Planning/`, `Docs/04_Decisions/`, `Docs/06_Maintenance/Patterns/`
3. **Last Resort**: Source code (Models/, Engine/, Views/, etc.)

**Access source code directly only when**:
- During implementation or debugging
- Transcripts are missing or outdated
- Implementation-level details absolutely required

## Project Structure

```
Models/           Data models (NodeType, SwiftData, achievement/eval/recipe/simulation types)
Engine/           Core logic (ArchitectureGraph, CodeGenerator, EvaluationEngine, SimulationEngine)
Persistence/      SwiftData persistence (SwiftDataManager, ProgressTracker)
Views/            SwiftUI views (Builder, Code, Education, Evaluation, Onboarding, Settings, Simulation, TierMap, Tutorial)
ViewModels/       MVVM view models (BuilderViewModel)
Utilities/        Design system (Color, Typography, Shadow) + Managers
Data/             Static data (GlossaryDatabase, RecipeDatabase)
Docs/             Workflow documentation (Transcripts, Planning, Progress, Decisions, Audits, Maintenance, Archives)
```

## Coding Standards (CRITICAL)

### Immutability
- ALWAYS create new objects, NEVER mutate
- Prefer structs (value types) over classes
- Use `let` over `var` wherever possible

### File & Function Size
- Files: 200-400 lines typical, 800 max
- Functions: under 50 lines, ideally 10-30
- Max nesting depth: 4 levels - use `guard`/early returns to flatten

### Dependency Injection (CRITICAL)
- ALWAYS decouple through protocols - never use concrete types as dependencies
- Constructor injection for ViewModels and Services
- `@EnvironmentObject` for SwiftUI view-layer DI
- Composition root wires dependencies at app entry point
- **No `.shared` inside class bodies** - inject through protocols
- Protocol naming: `[TypeName]Protocol` (e.g., `ArchitectureGraphProtocol`)
- Default parameter allowed in `init()` for convenience, but protocol type required

```swift
// WRONG
class BuilderViewModel: ObservableObject {
    private let graph = ArchitectureGraph.shared  // Tight coupling!
}

// CORRECT
class BuilderViewModel: ObservableObject {
    private let graph: ArchitectureGraphProtocol
    init(graph: ArchitectureGraphProtocol) {
        self.graph = graph
    }
}
```

### Where DI Does NOT Apply
- Pure value types (structs, enums) with no external dependencies
- Simple utilities (static functions, extensions)
- SwiftUI `@State` (view-local state)

### Naming Conventions
| Type | Convention | Example |
|------|-----------|---------|
| Variables | camelCase | `userName`, `orderTotal` |
| Functions | camelCase, verb-based | `fetchUser`, `calculateTotal` |
| Types/Classes | PascalCase | `ArchitectureGraph`, `BuilderViewModel` |
| Constants | camelCase | `maxRetryCount`, `apiBaseURL` |
| Files | PascalCase | `UserProfile.swift`, `BuilderViewModel.swift` |
| Protocols | PascalCase + `Protocol` suffix (DI) or `-able`/`-ing` (capabilities) | `SimulationEngineProtocol`, `Loadable` |

### Error Handling
- Use `do/try/catch` with proper propagation and user-friendly messages
- Custom errors with `LocalizedError` conformance
- ALWAYS validate user input at system boundaries

### Anti-Patterns to Avoid
1. God objects - classes that do too much
2. Magic numbers - use named constants
3. Deep nesting (>4 levels) - flatten with early returns
4. Mutation - always create new objects
5. Commented code - delete it, git has history
6. Debug `print()` - remove before commit
7. `Any` types - use proper types
8. Force unwrapping - handle optionals properly
9. Direct singleton access (`.shared`) - inject via protocol
10. Concrete dependencies - depend on protocols, not concrete types

### Code Quality Checklist
Before marking work complete:
- [ ] Readable and well-named code
- [ ] Functions <50 lines, Files <800 lines
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No debug `print()` statements
- [ ] No hardcoded values
- [ ] Immutable patterns used
- [ ] Dependencies injected via protocols
- [ ] New services/managers have corresponding protocols

## Swift/iOS Patterns

### SwiftUI View Structure
```swift
struct ContentView: View {
    @State private var isLoading = false        // 1. State
    @StateObject private var viewModel = VM()   // 2. StateObject
    @Environment(\.dismiss) private var dismiss  // 3. Environment

    var body: some View {                       // 4. Body
        content
            .onAppear { viewModel.onAppear() }
    }

    private var content: some View { ... }      // 5. Extracted views
}
```

### State Management
- `@State` - view-owned simple values
- `@StateObject` - view-owned objects (create once)
- `@ObservedObject` - passed-in objects (don't own)
- `@EnvironmentObject` - dependency injection
- `@Binding` - two-way connection

### Memory Management
- Use `[weak self]` in closures to prevent retain cycles
- Use `[unowned self]` only when certain object outlives closure
- Use `@MainActor` for UI updates

### Project-Specific Patterns
- **SwiftData**: `@Model` with cascade relationships; CityProgress -> Tiers -> Architectures -> Nodes/Connections
- **Canvas + particles**: 60fps rendering, bezier paths, trail effects (max 50 concurrent particles)
- **Graph/Validation**: `NodeType.allowedConnections`, anti-pattern detection, BFS/DFS
- **Accessibility**: VoiceOver, Dynamic Type, Reduce Motion, 44x44pt touch targets

## Git Workflow

### Commit Format
```
<prefix>: <description>

<optional body>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

### Commit Prefixes

**Workflow Prefixes** (Docs/ changes):
- `plan:` - Planning docs, specs (Step 1-2)
- `audit:` - Audit reports (Step 3)
- `resolve:` - Decisions/ADRs (Step 4)
- `track:` - Checklists, progress (Step 5)
- `log:` - Session logs (Step 8)
- `pattern:` - Design patterns (Step 9)
- `docs:` - Transcripts, READMEs (Step 10)

**Code Prefixes** (Source code changes):
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `perf:` - Performance improvement
- `test:` - Tests only
- `style:` - Formatting/whitespace

**Maintenance Prefixes**:
- `chore:` - Dependencies, build scripts
- `ci:` - CI/CD configuration

### Prefix Auto-Detection
- `Docs/02_Planning/` -> `plan:`
- `Docs/05_Audits/` -> `audit:`
- `Docs/04_Decisions/` -> `resolve:`
- `Docs/03_Progress/*/checklist.md` -> `track:`
- `Docs/03_Progress/*/session-log.md` -> `log:`
- `Docs/06_Maintenance/Patterns/` -> `pattern:`
- `Docs/01_Transcripts/` -> `docs:`
- New feature code -> `feat:`
- Bug fixes -> `fix:`
- `Package.swift` -> `chore:`

### Commit Splitting
Split into separate commits when changes represent distinct logical units (different workflow phases, different prefixes, independent features). Keep as single commit when changes are cohesive for one purpose.

### Git Safety
- NEVER update git config
- NEVER run destructive commands (push --force, reset --hard) without explicit permission
- NEVER skip hooks (--no-verify)
- NEVER force push to main/master
- ALWAYS create NEW commits (no --amend) unless explicitly requested
- Prefer staging specific files over `git add -A`

### Branch Naming
- `feature/short-description`
- `fix/short-description`
- `hotfix/short-description`
- `refactor/short-description`

### GitHub
- **Repo**: https://github.com/Rishi-Selarka/archsys
- Push to `main` only when feature complete & verified
- Do NOT push `.cursor/`, `.claude/`, WIP/broken code

## Security

**City Architect is offline** - no network, no API keys. Focus on:
- Input validation (connection rules, node positions)
- Data integrity (SwiftData validation)
- No hardcoded secrets
- No sensitive data in UserDefaults
- Validate graph structure (no invalid connections, cycles)

## Testing (Optional)

Testing is optional for this student challenge - prioritize shipping over coverage.

**When testing is useful**: Graph validation, connection rules, particle physics edge cases.

- XCTest for unit tests, XCUITest for UI tests
- AAA pattern (Arrange, Act, Assert)
- Protocol-based mocking (DI makes this easy)
- Test behavior, not implementation
- 80%+ coverage goal (if adding tests)

## Development Workflow (10-Step)

```
1. BRAINSTORM -> 2. PLAN -> 3. AUDIT -> 4. RESOLVE -> 5. CHECKLIST
                                                        |
10. DOCUMENT <- 9. PATTERNS <- 8. LOG <- 7. FIX <- 6. IMPLEMENT
```

### Phases & Checkpoints
- **Phase 1 - Planning (Steps 1-5)**: Think before coding
- **Phase 2 - Implementation (Steps 6-7)**: Write and validate code
- **Phase 3 - Documentation (Steps 8-10)**: Capture knowledge

### Step Summary
| Step | Purpose | Output Location |
|------|---------|----------------|
| 1. Brainstorm | Explore approaches | `Docs/02_Planning/Brainstorming/YYMMDD-[topic].md` |
| 2. Plan | Detail implementation | `Docs/02_Planning/Specs/YYMMDD-[feature].md` |
| 3. Audit | Find issues | `Docs/05_Audits/Code/YYMMDD-[feature]-audit.md` |
| 4. Resolve | User decisions | `Docs/04_Decisions/YYMMDD-[feature]-resolution.md` |
| 5. Checklist | Actionable tasks | `Docs/03_Progress/[feature-name]/checklist.md` |
| 6. Implement | Write code | Source files |
| 7. Fix | Resolve errors | Clean build |
| 8. Log | Record session | `Docs/03_Progress/[feature-name]/session-log.md` |
| 9. Patterns | Identify learnings | `Docs/06_Maintenance/Patterns/YYMMDD-[topic]-patterns.md` |
| 10. Document | Update transcripts | `Docs/01_Transcripts/` |

### When to Use
- **Full (1-10)**: New features, major refactoring, architectural changes
- **Partial (2-10)**: Bug fixes with clear solution, small enhancements
- **Minimal (6-10)**: Hotfixes, trivial changes (still document and log!)

### Workflow Control
- **Default**: Auto-run with 3 phase checkpoints (after Steps 5, 7, 10)
- "Auto-approve everything" -> No checkpoints
- "Ask before each step" -> Approve every step individually
- "Pause" / "Continue" / "Skip to step [N]" / "Status" - available anytime

### Build Verification
- Run `swift build` after implementation changes
- Fix errors before proceeding to documentation phase

## Self-Evolution

When encountering significant patterns:
1. Verify pattern exists in 2+ places or is broadly applicable
2. Ask user before documenting
3. Generalize and update appropriate documentation
4. Coding patterns -> this file or `Docs/06_Maintenance/Patterns/`

## Performance Notes

### iOS/Swift
- Particle system: max 50 concurrent particles, Canvas rendering, 60fps
- SwiftData: in-memory cache for drag-drop lookups; avoid N+1 queries
- Use `lazy` for expensive computations
- Prefer value types (structs) over reference types (classes)
- Profile with Instruments
- Avoid retain cycles (weak/unowned)