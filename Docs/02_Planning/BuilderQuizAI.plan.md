# Builder Canvas + Quiz + AI Analysis — Implementation Plan

## Context

When a user taps "Enter" on the Interior screen, they currently land on an empty `BuilderView`. This plan implements the full learning flow: an instruction overlay → block-ordering canvas → per-block MCQ quiz → AI-powered analysis → history tracking. The goal is to teach iOS system design through interactive challenges with the water-level / city metaphor intact (pass = survive, fail = drown).

**Target**: iOS 26+ (Foundation Models for on-device AI analysis)
**Content**: Pre-authored blocks, ordering, and MCQ questions — AI generates personalized analysis only
**Phases**: 3 phases, each independently shippable

---

## Phase 1 — Canvas: Block Ordering + Instructions Overlay

### Files to Create

| File | Purpose |
|------|---------|
| `Data/ChallengeContent.swift` | Static data: blocks (correct order, shuffled default), per problem |
| `Views/Builder/InstructionOverlay.swift` | Glass modal with short instructions + X button, blurs background |
| `Views/Builder/BlockCanvasView.swift` | Scrollable vertical canvas with draggable blocks + connection lines |
| `Views/Builder/ArchitectureBlockView.swift` | Single block tile (icon, name, color from `NodeType`) |

### Files to Modify

| File | Change |
|------|--------|
| `Views/Builder/BuilderView.swift` | Replace placeholder with `BlockCanvasView`, show `InstructionOverlay` on appear, add title |
| `Data/InteriorContent.swift` | Add `blocks: [NodeType]` array to `InteriorProblem` (correct order) |

### Data Model — `ChallengeContent`

Each problem gets 4 or 6 `NodeType` blocks in correct top→bottom order. On canvas load, blocks are shuffled into a wrong arrangement.

```
Tier 1 problems: 4 blocks each (ui, viewModel, database + 1 more)
Tier 2 problems: 4 blocks each (ui, viewModel, repository, api)
Tier 3 problems: 6 blocks each (ui, viewModel, cache layers, worker, etc.)
Tier 4 problems: 6 blocks each (ui, viewModel, circuitBreaker, retryHandler, fallback, api)
Tier 5 problems: 6 blocks each (ui, viewModel, mlModel/websocket, eventBus, stateMachine, database)
```

### Instruction Overlay

- Glass card (`.ultraThinMaterial`) centered on screen
- Title: problem name
- 2-3 short bullet instructions: "Drag blocks to reorder the architecture from top (UI) to bottom (data)"
- X button top-right to dismiss
- Background: `.blur(radius: 10)` while overlay is shown
- `@State private var showInstructions = true` in BuilderView

### Block Canvas

- `ScrollView(.vertical)` containing a `VStack`
- Each block: rounded rectangle with `NodeType.sfSymbol`, `NodeType.displayName`, `NodeType.accentColor`
- Vertical connection lines drawn between blocks (simple `Rectangle` dividers, dashed)
- Drag to reorder: `DragGesture` on each block — when dropped on another block's zone, they swap positions
- After each swap, check if order matches correct order
- On correct order: `HapticManager.success()`, green checkmark animation, short delay → enable "Continue" button
- "Continue" advances to Phase 2 (quiz)

### BuilderView Structure

```
NavigationBar: back chevron (white) | title: problem.title (center)
─────────────────────────
[InstructionOverlay if showInstructions]  (blurs behind)
─────────────────────────
ScrollView {
  Block 1  ←─ draggable
  ───── connection line
  Block 2  ←─ draggable
  ───── connection line
  Block 3  ←─ draggable
  ───── connection line
  Block 4  ←─ draggable
}
─────────────────────────
[Continue button — appears after correct ordering]
```

---

## Phase 2 — MCQ Quiz per Block + Analysis Screen

### Files to Create

| File | Purpose |
|------|---------|
| `Data/QuizContent.swift` | Static MCQ data: 3 questions per block, 3-4 options each, correct answer index |
| `Models/QuizTypes.swift` | `QuizQuestion`, `QuizOption`, `QuizAnswer`, `QuizResult` structs |
| `Views/Builder/QuizCardView.swift` | Glass card overlay: question text, 4 option buttons, left/right arrows, finish button |
| `Views/Builder/AnalysisView.swift` | Score display, per-question breakdown, reattempt + done buttons |
| `Services/AIAnalysisService.swift` | Foundation Models integration — generates personalized feedback from quiz results |

### Files to Modify

| File | Change |
|------|--------|
| `Views/Builder/BlockCanvasView.swift` | Tap on block → show `QuizCardView` for that block |
| `Views/Builder/BuilderView.swift` | Track quiz state, navigation to `AnalysisView` |
| `Package.swift` | **DO NOT MODIFY** (auto-generated). Foundation Models is a system framework, no package change needed |

### Quiz Data — `QuizContent`

Per block per problem: 3 MCQ questions, each with 3-4 options.

```swift
struct QuizQuestion: Identifiable {
    let id: String
    let blockType: NodeType
    let questionText: String
    let options: [String]        // 3-4 options
    let correctIndex: Int
    let explanation: String      // shown in analysis
}
```

Total: ~15 problems × avg 5 blocks × 3 questions = ~225 questions. These are pre-authored, teaching system design concepts per block.

Example (Tier 1, Notes App, ViewModel block):
- Q: "What is the ViewModel's primary responsibility?"
- Options: ["Render UI elements", "Manage business logic and state", "Store data on disk", "Handle network requests"]
- Correct: 1 (index)

### Quiz Card UI

- Triggered: user taps a block on the canvas after ordering is complete
- Glass card overlay (same blur-behind pattern as instructions)
- Top: block name + icon
- Question text (1 of 3)
- 4 option buttons — liquid/pill style, highlight on select
- Navigation: `←` arrow (top-left) and `→` arrow (top-right) to move between questions
- Finish button: appears ONLY when user is on question 3 AND has selected an answer
- Track answered questions per block with checkmark badges on canvas blocks
- All blocks must be completed before analysis

### Analysis View — Full Screen

- **Score section**: circular progress (reuse pattern from `InspectorView.swift`), percentage, pass/fail badge
- **Pass threshold**: 75% (≥75% = pass, <75% = drowned)
- **Per-question breakdown**: compact cards showing:
  - Question text (abbreviated)
  - User's answer vs correct answer (green ✓ / red ✗)
  - AI-generated 1-2 sentence explanation (from Foundation Models)
  - Relevant SF Symbol icon for the concept
- **Apple docs links**: at bottom, links to relevant Apple documentation per system design concept
- **Buttons**:
  - Top-right: "Done" → navigates to TierMapView (home)
  - Bottom: "Reattempt" → navigates back to InteriorView with data reset

### Drowning Effect (< 75%)

- Screen tints blue from bottom up (water rising animation)
- Subtle wave overlay using `Canvas` + sine curve animation
- "Drowned" text with water droplet icon fades in
- `HapticManager.error()` on fail
- Short delay → show analysis with reattempt option

### Success Effect (≥ 75%)

- Confetti-style particle burst or golden glow
- "You survived [Level]!" text
- `HapticManager.success()`
- Increment city pass count

### AI Analysis Service (Foundation Models)

```swift
import FoundationModels

@available(iOS 26, *)
struct AIAnalysisService {
    func generateAnalysis(
        problemTitle: String,
        tierLevel: String,
        questions: [QuizQuestion],
        userAnswers: [Int]
    ) async throws -> [String]  // One explanation per question
}
```

- Uses `LanguageModelSession` with a system prompt focused on iOS system design education
- Input: the question, user's answer, correct answer, block context
- Output: 1-2 sentence explanation of why the correct answer is right
- Fallback: if AI unavailable, use the pre-authored `explanation` field from `QuizQuestion`

---

## Phase 3 — History, Persistence, Progress Tracking

### Files to Create

| File | Purpose |
|------|---------|
| `Models/SwiftData/QuizAttempt.swift` | `@Model` — stores each attempt: tierID, problemIndex, score, answers, timestamp, passed |
| `Views/History/HistoryView.swift` | Sheet view: list of attempts grouped by city, filter chips |
| `Views/History/AttemptDetailView.swift` | Single attempt detail: score, answers, AI analysis |

### Files to Modify

| File | Change |
|------|--------|
| `Views/TierMap/TierMapView.swift` | Add history button (top-left, mirror settings pattern), update StatsCardView to show pass count |
| `Views/TierMap/StatsCardView.swift` | Change "Cities Unlocked" → show pass counts (e.g., "3/5 Cities") |
| `Persistence/SwiftDataManager.swift` | Add `saveQuizAttempt()`, `fetchAttempts(tierID:)`, `fetchAllAttempts()` |
| `Models/SwiftData/Tier.swift` | Add `passCount: Int` field (number of successful passes) |
| `Models/SwiftData/CityProgress.swift` | No change needed — tiers relationship already covers it |
| `MyApp.swift` | Add `QuizAttempt.self` to `.modelContainer(for:)` |

### QuizAttempt Model

```swift
@Model
final class QuizAttempt {
    var tierID: Int
    var problemIndex: Int
    var problemTitle: String
    var score: Double           // 0-100
    var passed: Bool            // score >= 75
    var totalQuestions: Int
    var correctAnswers: Int
    var timestamp: Date
    var analysisJSON: String    // Serialized AI analysis for replay
}
```

### History View

- Triggered: history button (top-left of TierMapView, `clock.arrow.circlepath` icon)
- `.sheet()` presentation (same pattern as SettingsView)
- **Filter chips** at top: All, Tokyo, London, Singapore, New York, San Francisco
- **Per-city summary card**: attempts count, best score, avg score, pass rate
- **Attempt list**: sorted by date, each row shows: problem title, score %, pass/fail badge, date
- Tap attempt → `AttemptDetailView` with full breakdown + cached AI analysis

### TierMap Integration

- `StatsCardView`: show "Cities Passed: X/5" based on `tier.passCount > 0`
- On quiz pass: increment `tier.passCount`, mark `tier.completed = true` if first pass
- On quiz fail: increment `tier.attemptsCount` only, no completion

### AI-Generated History Summary

- In `HistoryView`, a "Summary" button per city
- Uses Foundation Models to generate a 2-3 sentence learning progress summary
- E.g., "You've attempted Tokyo 3 times. Your understanding of MVVM is strong but ViewModel state management needs review."

---

## Implementation Order

```
Phase 1:  ChallengeContent → InteriorProblem update → InstructionOverlay
          → ArchitectureBlockView → BlockCanvasView → BuilderView rewire
          → Build & test block ordering

Phase 2:  QuizTypes → QuizContent (all 225 questions) → QuizCardView
          → AIAnalysisService → AnalysisView → Drowning/success effects
          → Wire quiz flow end-to-end → Build & test

Phase 3:  QuizAttempt model → SwiftDataManager updates → HistoryView
          → AttemptDetailView → TierMapView history button
          → StatsCardView update → Build & test full loop
```

## Verification

After each phase:
1. Build with Xcode (Swift Playgrounds project — `swift build` won't work)
2. Test flow: TierMap → tap city → Interior → Enter → Builder canvas
3. Phase 1: verify block drag-swap works, correct order triggers success
4. Phase 2: verify quiz card appears per block, finish → analysis screen, reattempt/done navigation
5. Phase 3: verify history persists across sessions, filter works, stats update on TierMap

## Key Existing Code to Reuse

- `NodeType` (`Models/NodeType.swift`) — block icons, colors, names
- `HapticManager` (`Utilities/Managers/HapticManager.swift`) — all feedback
- `InspectorView` score circle pattern (`Views/Evaluation/InspectorView.swift`)
- `TutorialOverlayView` overlay pattern (`Views/Tutorial/TutorialOverlayView.swift`)
- `InteriorGlassCard` glass material pattern (`Views/Interior/InteriorGlassCard.swift`)
- `SwiftDataManager` persistence pattern (`Persistence/SwiftDataManager.swift`)
- `SettingsView` sheet + button pattern for history button
