# City Architect - Swift Student Challenge 2026

## Overview

Educational iOS app teaching mobile architecture through interactive city-building metaphor. Features: SwiftData persistence, mesmerizing particle simulation, real-time Swift code generation, 30+ term glossary, 7 architecture recipes, all 5 tiers fully functional, comprehensive accessibility.

**Platform**: iPad, Swift Playgrounds 4.6+, Dark mode only, Offline, < 25 MB  
**Deadline**: February 28, 2026  
**Timeline**: 12 days

---

## Core Technology Stack

**Data Persistence**: SwiftData with proper relationships (CityProgress → Tiers → Architectures → Nodes → Connections)

**Visual System**: 2.5D card-based layout with depth shadows, programmatic SwiftUI graphics, SF Symbols only

**Animation System**: Spring animations, multi-layered particle physics with trails and glows, Canvas rendering for 60fps

**Asset Strategy**: Zero custom assets (SF Symbols, system fonts, programmatic graphics)

---

## 5 Tier Structure (All Fully Implemented)

> Each tier is named after a real city. The city name appears on the tier card and sets the visual identity and metaphor for that level of architecture.

### Tier 1: Tokyo - Local Data Village
**City Identity**: Tokyo - clean, organized, hyper-local. Everything works perfectly within the city limits.
**Concepts**: UI Layer, ViewModel, Local Persistence, State Management
**Components**: UI Node, ViewModel Node, Database Node
**Challenge**: Build UI → ViewModel → Database architecture
**Simulation**: Read/write operations with blue/teal particles
**Tutorial**: Full guided experience
**Learning Outcome**: Separation of concerns, MVVM basics

**Problem Statements** (pick any to build in the canvas):
1. **Notes App** - Design the architecture for a personal notes app (like Apple Notes). Users can create, edit, and delete notes. Data is stored entirely on-device. *Focus: UI → ViewModel → LocalDB layering.*
2. **Habit Tracker** - Architect a daily habit tracker that logs streaks and saves progress offline. Habits are checked off daily and totals persist between app launches. *Focus: state management, SwiftData-style local persistence.*
3. **To-Do List** - Build the architecture for a task manager with categories and priority flags. No internet required - all state lives locally. *Focus: MVVM basics, clean separation of view and data layers.*

---

### Tier 2: London - Connected Town
**City Identity**: London - a global hub of bridges and connections. Data flows across the channel to the outside world.
**Concepts**: API Layer, Repository Pattern, Async Operations, Error Handling
**Components**: API Client, Repository, Network Cache
**Challenge**: Build UI → ViewModel → Repository → API architecture
**Simulation Controls**: Network latency slider (0-3s), failure mode toggle, cache toggle
**Learning Outcome**: Decoupling, dependency injection, network abstraction

**Problem Statements** (pick any to build in the canvas):
1. **Weather App** - Design the architecture for a weather app that fetches current conditions and a 7-day forecast from a remote API. Handle loading, success, and error states. *Focus: API Client + Repository pattern, async/await flow.*
2. **News Reader** - Architect a news feed app that pulls headlines from an RSS/REST API and caches articles for offline reading. *Focus: Repository as the single source of truth, network cache layer.*
3. **GitHub Profile Viewer** - Build the system design for an app where users search a GitHub username and see their public repos and stats. *Focus: ViewModel orchestrating async API calls, error propagation to UI.*

---

### Tier 3: Singapore - Performance Peak
**City Identity**: Singapore - one of the world's most efficient, optimized cities. Every millisecond counts.
**Concepts**: Caching Strategies, Background Processing, Lazy Loading
**Components**: Memory Cache, Background Worker, Image Cache, Lazy Loader
**Challenge**: Optimize a slow architecture by adding caching and background processing
**Simulation Controls**: Load level slider, cache hit rate display, processing time viz
**Learning Outcome**: Performance optimization patterns, caching strategies

**Problem Statements** (pick any to build in the canvas):
1. **Photo Feed** - Design an Instagram-style scrollable photo feed. Images must load smoothly without blocking the main thread. Add image caching so scrolling back is instant. *Focus: Image Cache node, lazy loading, background fetch.*
2. **Restaurant Finder** - Architect an app that shows nearby restaurants. Location lookup and data fetch happen in the background; results appear without freezing the UI. *Focus: Background Worker, in-memory cache for repeat queries.*
3. **Podcast Player** - Build the architecture for a podcast app that streams audio and pre-fetches the next episode in the background while the current one plays. *Focus: Background processing, cache-first data strategy.*

---

### Tier 4: New York - Resilient Fortress
**City Identity**: New York - the city that never sleeps and never gives up. It absorbs every failure and keeps running.
**Concepts**: Circuit Breaker, Retry Logic, Fallback Strategies, Monitoring
**Components**: Circuit Breaker, Retry Handler, Fallback Provider, Health Monitor
**Challenge**: Build architecture that gracefully handles failures
**Simulation Controls**: Failure injection, recovery time display, health indicators
**Learning Outcome**: Defensive programming, graceful degradation, fault tolerance

**Problem Statements** (pick any to build in the canvas):
1. **Banking Transfer Screen** - Design the architecture for a money-transfer feature. If the payment API fails, retry up to 3 times with exponential backoff. If it still fails, show a clear error and queue the transfer for later. *Focus: Retry Handler, Circuit Breaker, Fallback Provider.*
2. **Ride-Sharing Live Tracker** - Architect a trip-tracking screen (like Uber) that shows a driver's location in real time. If the network drops, gracefully fall back to last-known location and reconnect automatically. *Focus: Health Monitor, retry logic, connection recovery.*
3. **E-commerce Checkout** - Build the system design for a checkout flow. Payment processing must survive transient failures. A fallback should save the order locally if the server is unreachable. *Focus: Circuit Breaker protecting the payment API, Fallback Provider saving to local queue.*

---

### Tier 5: San Francisco - Smart City
**City Identity**: San Francisco - Silicon Valley's heartbeat. The city where your phone learns from you and the world updates in real time.
**Concepts**: ML Integration, Real-time Updates, Advanced Patterns
**Components**: ML Model, WebSocket, Event Bus, State Machine
**Challenge**: Build modern app architecture with ML and real-time features
**Simulation**: ML inference flow, real-time event propagation, state transitions
**Learning Outcome**: Modern iOS patterns, ML integration, reactive programming

**Problem Statements** (pick any to build in the canvas):
1. **Smart Photo Organizer** - Design the architecture for a photo app that auto-categorizes images (food, travel, people) using on-device Core ML. New photos are classified in the background and the gallery updates in real time. *Focus: ML Model node feeding results into Event Bus, State Machine managing classification states.*
2. **Live Sports Score App** - Architect a sports app where scores update the moment they change via WebSocket. Multiple screens (scoreboard, team detail, alerts) all react to the same live feed. *Focus: WebSocket → Event Bus → reactive ViewModels.*
3. **Predictive Search** - Build the system design for a search feature that learns from past queries and suggests completions. An ML model ranks results; a State Machine manages the query → suggestion → selection flow. *Focus: ML Model + State Machine + Event Bus coordination.*

---

## Core Features (42 Total)

### Data & Architecture
1. SwiftData persistence with relationships
2. 18 component types covering full mobile stack
3. Graph engine with validation
4. Anti-pattern detection (5 types)
5. Path finding and cycle detection
6. Connection validation rules

### Visual Excellence (Wow Factors)
7. Multi-layered particle system (primary, secondary, ambient)
8. Physics-based particle movement with bezier curves
9. Particle trails (6-point history with fade)
10. Collision burst effects at nodes
11. Node glow effects during processing
12. 2.5D card design with depth shadows
13. Smooth spring animations (60fps)
14. Ambient particles (constant background animation)

### Educational Features
15. Dynamic Swift code generation from architecture
16. Architecture glossary (30+ terms with inline access)
17. Recipe templates (7 pre-built architectures)
18. Learn More sheets for all components
19. Real-world app examples (Instagram, Twitter, etc.)
20. Interactive tutorials for each tier
21. Contextual tooltips throughout
22. Code-to-visual synchronization

### Simulation & Analysis
23. Multiple operation types (Read, Write, Sync)
24. Network latency control
25. Failure mode simulation
26. Cache hit visualization
27. Retry logic animation
28. Live metrics panel
29. Rule-based AI evaluation
30. Detailed architectural feedback
31. Before/after comparison view

### Engagement & Progress
32. 10 concrete achievements
33. Progress tracking (scores, best times, attempts)
34. All tiers unlocked from start (free exploration)
35. Architecture history (multiple attempts saved)

### Accessibility & Quality
36. Full VoiceOver support
37. Dynamic Type scaling
38. Reduce Motion alternatives
39. High Contrast mode
40. Haptic feedback throughout
41. Keyboard navigation support
42. Demo mode with reset functionality

---

## SwiftData Model Architecture

**5 Core Models**:

**CityProgress** (singleton, overall progress)
- Current tier ID
- Unlocked/completed tier IDs
- Achievements list
- Relationships: has many Tiers

**Tier** (5 instances, one per tier)
- ID, name, unlocked status, completed status
- Score, best time, attempts count
- Relationships: has many Architectures

**Architecture** (multiple per tier)
- Created date, active status, tier ID
- Relationships: has many Nodes and Connections

**ArchitectureNode** (components placed on canvas)
- ID, type, position (x, y), tier ID
- Node type stored as string (enum raw value)

**NodeConnection** (lines between nodes)
- ID, source node ID, target node ID, tier ID

**Relationships**: Cascade deletion (delete Tier → deletes all Architectures → deletes all Nodes/Connections)

**Data Access**: @Query property wrapper for automatic UI updates, FetchDescriptor for complex queries, in-memory cache for performance

---

## Enhanced Particle System (Primary Wow Factor)

**Three Particle Types**:
- **Primary**: Large (12pt), main data payload, glowing with trails
- **Secondary**: Small (6pt), metadata/headers, faster movement  
- **Ambient**: Tiny (4pt), background drift, subtle atmosphere

**Physics Behaviors**:
- Bezier curve path following (smooth organic movement)
- Acceleration and friction (not linear speed)
- Slight waviness (organic feel, not robotic)
- Trail effect (6-point position history with fade)
- Collision detection (burst on node impact)

**Visual Effects**:
- Radial gradient (white center → color edge)
- Glow effect (8-16pt blur, colored shadow)
- Trail fade (opacity decreases from 100% → 0%)
- Node lighting (nodes pulse when particles pass)
- Burst animation (12 particles explode outward)
- Ripple effect emanating from nodes

**Rendering**: Canvas-based for GPU acceleration, 60fps guaranteed, max 50 concurrent particles

---

## Dynamic Code Generation System

**What It Does**: Converts visual architecture into real Swift code in real-time

**Pattern Detection**:
- Simple MVVM (UI → ViewModel → Database)
- Repository Pattern (UI → VM → Repository → API/Database)
- Clean Architecture (multiple abstraction layers)
- Event-Driven (Event Bus coordination)
- ML Pipeline (ML Model integration)

**Code Output Includes**:
- Data models (from Database nodes)
- Repository protocols (from Repository nodes)
- API client interfaces (from API nodes)
- ViewModels with proper dependencies
- SwiftUI Views with state management
- Architecture explanation comments
- Real-world app usage examples

**Features**:
- Syntax highlighting (keywords pink, types purple, wrappers orange)
- Line numbers in gutter
- Copy code button
- Export as Swift file
- Active section highlighting (tap node → code highlights)
- Real-time updates (architecture changes → code regenerates)

---

## Architecture Glossary (30+ Terms)

**Categories**:
- Architecture Patterns (7 terms): MVVM, Repository, Clean Architecture, MVC, etc.
- Components (18 terms): One for each NodeType (UI Layer, ViewModel, API Client, etc.)
- Concepts (10 terms): Separation of Concerns, Dependency Injection, Abstraction, etc.
- Anti-Patterns (5 terms): Direct DB Coupling, God Object, Circular Dependencies, etc.

**Each Term Includes**:
- Plain English definition
- Detailed explanation
- Swift code example
- Real-world apps using it (Instagram, Twitter, etc.)
- Common mistakes to avoid
- Related terms (linked for navigation)
- SF Symbol icon and category color

**Access Methods**:
- Inline: Tap any underlined technical term anywhere in app
- Popover: Quick definition appears inline
- Full view: Glossary screen with search and category filters
- Contextual: Terms automatically highlighted in tutorials and feedback

---

## Recipe Templates (7 Pre-Built Architectures)

**Templates**:
1. Simple CRUD App (Beginner, Tier 1 level)
2. Instagram Feed Clone (Intermediate, Tier 2 level)
3. Real-time Chat (Advanced, Tier 5 level)
4. Photo Editor App (Intermediate, Tier 3 level)
5. E-commerce Checkout (Advanced, Tier 4 level)
6. ML Photo Search (Advanced, Tier 5 level)
7. Weather App (Beginner, Tier 2 level)

**Each Recipe Shows**:
- Architecture diagram preview
- Difficulty level (Beginner/Intermediate/Advanced)
- Pattern type (MVVM, Repository, etc.)
- Real apps using this pattern
- Component count
- Load functionality (populates canvas instantly)
- Customization tracking

**Purpose**: Learning from examples, rescue for stuck users, demonstrates pattern variety

---

## UI Structure (14 Screens)

1. **OnboardingView** - Welcome, animated intro, purpose explanation
2. **TierMapView** - All 5 city tiers in vertical scroll (Tokyo → London → Singapore → New York → San Francisco, all unlocked from start). Each displayed as a named city card.
3. **TierDetailView** - City detail view with tier concepts, challenges, and 3 selectable problem statements
4. **BuilderView** - Main interactive canvas (primary screen, 90% of time)
5. **SimulationOverlayView** - Particle animation during simulation
6. **InspectorView** - Evaluation results with scores and feedback
7. **LearnMoreView** - Deep dive on any component
8. **GlossaryView** - Full searchable glossary (30+ terms)
9. **CodeView** - Live Swift code generation (split-screen)
10. **RecipeBookView** - Template library (7 recipes)
11. **ComparisonView** - Side-by-side architecture comparison
12. **AchievementsView** - Achievement gallery (10 achievements)
13. **TutorialOverlayView** - Guided tutorial with spotlight
14. **SettingsView** - Settings, accessibility, credits

---

## BuilderView (Main Canvas) Layout

**Header Bar** (80pt):
- Back to tier map
- Tier title and description
- Recipe book button
- Glossary button
- Settings menu
- Achievement progress indicator

**Achievement Row** (40pt):
- Small badges showing unlocked achievements

**Main Canvas** (700pt - THE STAR):
- Pure black background with 8pt grid dots
- Node cards (100x100pt, 2.5D design with shadows)
- Bezier curve connections between nodes
- Animated glowing particles flowing
- Empty state with helpful guidance
- Drag-drop zone with visual feedback
- Zoom and pan capabilities

**Component Toolbar** (100pt):
- Horizontal scrollable row
- 18 component types (80x80pt cards)
- Grouped by tier
- Drag to canvas or tap to add

**Action Bar** (80pt):
- Run Simulation button (green when valid)
- Evaluate button (triggers AI analysis)
- Reset button (clear canvas)
- Code View toggle (split-screen)
- Compare button (before/after)
- Hint button (contextual suggestions)
- Operation picker (Read/Write/Sync)
- Latency slider (if API present)
- Failure toggle (if resilience nodes present)

---

## Interaction Model

**Canvas**:
- Drag from toolbar → Drop on canvas → Node appears with spring animation
- Tap node → Select (highlights allowed connection targets)
- Long press node → Context menu (Learn More, Duplicate, Delete)
- Drag node → Move position (snaps to 8pt grid with haptic)
- Drag from node to node → Creates connection (validates first)
- Double tap canvas → Quick add menu

**During Simulation**:
- Tap anywhere → Pause/resume
- Swipe up → Show metrics panel
- Tap node → Highlight processing
- Particles flow with physics

**Glossary Access**:
- Tap underlined term → Inline definition
- Glossary button → Full searchable view

**Code View**:
- Toggle Visual/Code/Split modes
- Tap node → Highlights corresponding code
- Tap code → Highlights corresponding node
- Drag divider → Resize split ratio

---

## Advanced Particle Physics

**Movement**:
- Follow bezier curves (not straight lines)
- Acceleration at start, deceleration at end
- Slight waviness (sin wave offset for organic feel)
- Multiple speeds based on particle type

**Visual Effects**:
- 6-point trail with fading opacity
- Radial gradient (white center, color edge)
- Glow (colored shadow blur)
- Collision burst (12 particles explode outward)
- Node pulse (glow when particle arrives)
- Ripple effect emanating from nodes

**Types**:
- Read operations: Blue particles
- Write operations: Teal particles
- Cache hit: Green flash
- Failure: Red particles with shake
- Retry: Orange particles reversing

**Performance**: Canvas rendering, GPU-accelerated, max 50 particles, 60fps maintained

---

## Rule-Based AI Evaluation

**Analyzes**:
- Layer separation (UI shouldn't talk to Database directly)
- Missing abstraction layers (need Repository between UI and API)
- Circular dependencies (cycle detection)
- Too many connections (coupling issues)
- Missing error handling (no resilience components)

**Scores Four Categories** (0-100):
- Modularity: Separation of concerns, proper layering
- Performance: Caching, background processing, optimization
- Scalability: Can handle growth, proper patterns
- Resilience: Error handling, retry logic, fault tolerance

**Generates Feedback**:
- Positive: What's done well (green checkmarks)
- Warnings: Suboptimal but not critical (orange)
- Errors: Anti-patterns detected (red, critical)
- Suggestions: Actionable improvements with explanations

**Shows**:
- Circular score ring (animated fill)
- Category progress bars (animated sequentially)
- Feedback list with icons
- Affected nodes highlighted
- Code examples showing the issue
- Real-world consequences explained

---

## Educational Features

### 1. Interactive Tutorial System
- Spotlight highlights target element
- Instruction card with step-by-step guidance
- Animated arrow pointing to target
- Progress dots (current step indicator)
- Skip tutorial option (for re-demos)
- Contextual based on tier

### 2. Learn More Sheets
Every component has detailed information:
- What it does (plain English)
- Why it matters (real-world use case)
- Code example (actual Swift)
- Common mistakes (warnings)
- Related components (linked navigation)

### 3. Code View (Split-Screen)
- Visual architecture on left
- Generated Swift code on right
- Synchronized highlighting
- Real-time updates as architecture changes
- Syntax highlighting
- Copy and export functionality

### 4. Glossary System
- 30+ technical terms defined
- Inline access (tap underlined terms)
- Full searchable view
- Category filters (Patterns, Components, Concepts, Anti-Patterns)
- Related terms linked
- Code examples for each

### 5. Recipe Templates
- 7 pre-built architecture patterns
- Difficulty levels (Beginner, Intermediate, Advanced)
- Real app examples (Instagram Feed, Real-time Chat, etc.)
- One-tap load to canvas
- Customization tracking

### 6. Comparison View
- Side-by-side before/after
- Metrics comparison
- Improvement highlighting
- Apply suggestion functionality
- Shows trade-offs and benefits

### 7. Achievement System
10 concrete achievements:
- First Blueprint (built first architecture)
- Clean Connections (no anti-patterns)
- Speed Demon (optimized in Tier 3)
- Bulletproof (handled failures in Tier 4)
- Architect Master (completed all 5 tiers)
- Perfectionist (perfect score in all tiers)
- Pattern Detective (found and fixed 5 anti-patterns)
- Quick Learner (completed without tutorial)
- Precision Builder (built in under 2 minutes)
- Flow State (ran 10 simulations)

---

## Accessibility Features (Critical for Apple)

**VoiceOver Support**:
- All interactive elements have labels and hints
- State change announcements
- Navigation rotor support
- Magic Tap gesture for primary action

**Dynamic Type**:
- All text uses system text styles (scales automatically)
- Layouts adapt to text size
- @ScaledMetric for dynamic sizing

**Reduce Motion**:
- Alternative animations (fade instead of slide)
- Disable particle trails if needed
- Simpler transitions maintained

**High Contrast Mode**:
- Increased contrast colors
- Stronger borders
- Enhanced visibility

**Additional**:
- 44x44pt minimum touch targets
- Color + icon + text (never color alone)
- Keyboard navigation support
- Haptic feedback for all interactions

---

## Simulation Engine

**Process**:
1. Find path through architecture (BFS algorithm)
2. Generate events for each node in path
3. Emit particles from source to target
4. Animate particles along bezier curves
5. Calculate timing with latency/failures
6. Update metrics in real-time
7. Show results with visual feedback

**Controls**:
- Operation type: Read, Write, or Sync
- Network latency: 0-3s slider (if API present)
- Failure mode: Toggle random failures (if resilience nodes)
- Cache toggle: Enable/disable caching
- Playback speed: 0.5x, 1x, 2x

**Metrics Tracked**:
- Operations count
- Total latency
- Cache hits
- Failures
- Retries
- Success/failure status

---

## Graph Engine

**Responsibilities**:
- Add/remove nodes
- Create/delete connections
- Validate connections (based on allowed connections per node type)
- Detect anti-patterns (5 types)
- Find paths (BFS)
- Detect cycles (DFS)
- Calculate graph metrics

**Anti-Patterns Detected**:
1. Direct UI-Database coupling
2. Missing abstraction layer
3. Circular dependencies
4. Too many connections (high coupling)
5. No error handling

**Validation Rules**:
Each NodeType has allowedConnections list. For example:
- UI can only connect to ViewModel
- ViewModel can connect to Database, Repository, or API
- Repository can connect to API, Database, Cache
- API can connect to Database, Cache

**In-Memory Cache**: Fast lookups by ID for performance during drag-drop

---

## Visual Design System

**Colors** (iOS system colors):
- Background: True black (#000000)
- Surface: iOS dark card (#1C1C1E)
- Primary: iOS blue (#007AFF)
- Success: Green (#34C759)
- Warning: Orange (#FF9500)
- Error: Red (#FF3B30)
- Node colors: Blue, Purple, Green, Cyan, etc.

**Typography**:
- Display: SF Pro Rounded Bold (48/36/28pt)
- Headings: SF Pro Rounded Semibold (24/20/18pt)
- Body: SF Pro Text Regular (17/15/13pt)
- Code: SF Mono Regular (14pt)

**Spacing**: 8pt grid (all spacing: 8, 16, 24, 32, 40, 48, 64, 80pt)

**Corner Radius**: 12, 16, or 20pt only

**Shadows**: Three elevation levels for depth (y: 2/4/8pt, blur: 4/8/16pt)

**Node Design**: 100x100pt cards, SF Symbol icon (32pt), label below, 2.5D depth with shadow

---

## 3-Minute Demo Flow (Optimized for Judges)

### 0:00-0:20 (20s) - Instant Hook
- App opens with beautiful fade-in
- Welcome screen with animated particles
- Tap "Start Learning" → Smooth transition
**Goal**: Hook with visual quality immediately

### 0:20-0:50 (30s) - Particle Simulation Wow Factor
- Tier Map appears (all 5 visible)
- Tap Recipe Book → Select "Instagram Feed Clone"
- Load Recipe → Architecture assembles
- Tap "Run Simulation" immediately
- MESMERIZING particle display with trails, glows, node lighting
- Cache node flashes green (cache hit)
- Metrics panel shows live stats
**Goal**: Show the extraordinary particle system - most memorable moment

### 0:50-1:20 (30s) - Technical Excellence (Code Generation)
- Tap "Code View" button
- Split screen: Visual left, Live Swift code right
- Point out: "Generated in real-time from architecture"
- Tap node → Code highlights and scrolls
- Drag node → Code updates
**Goal**: Demonstrate technical depth and innovation

### 1:20-1:50 (30s) - Educational Value
- Long press "Repository" node
- Learn More sheet appears with definition, why it matters, code example
- Tap underlined term for inline glossary
- Show 30+ terms available throughout
**Goal**: Show comprehensive educational scaffolding

### 1:50-2:15 (25s) - AI Evaluation Intelligence
- Tap "Evaluate" button
- Inspector slides up with animated circular score (92/100)
- Category bars animate in (Modularity 95%, Performance 88%, etc.)
- Feedback list shows checkmarks and warnings
- Tap warning → Highlights missing component
**Goal**: Show intelligent analysis and guidance

### 2:15-2:40 (25s) - Comparison & Iteration
- Tap "Compare" button
- Side-by-side: Current (92) vs With Circuit Breaker (98)
- Shows +6% resilience improvement
- Tap "Apply Suggestion" → Circuit Breaker appears
- Run simulation with failure mode → Shows retry behavior
- Achievement unlocks: "Bulletproof"
**Goal**: Show iterative improvement loop

### 2:40-3:00 (20s) - Scope & Accessibility
- Back to Tier Map
- Quickly show all 5 city tiers: Tokyo → London → Singapore → New York → San Francisco
- Show 3/10 achievements unlocked
- Enable VoiceOver for 3 seconds (prove it works)
- Disable VoiceOver
- Final screen: "Keep Building Better Architectures"
**Goal**: Show completeness and accessibility commitment

**Backup Flows Prepared**: If something fails, have 3 alternative demo paths ready

---

## Development Timeline (12 Days)

### Days 1-2: Foundation & SwiftData
- Project structure setup
- 5 SwiftData @Model classes with relationships
- SwiftDataManager (queries, initialization, seeding)
- Graph Engine with validation and anti-pattern detection
- 18 NodeTypes with metadata
- Design system (colors, typography, spacing)
- Test SwiftData persistence thoroughly

### Days 3-4: Core UI & Particle System
- BuilderView container (header, canvas, toolbar, actions)
- CanvasView with 8pt grid and zoom/pan
- NodeView component (2.5D draggable cards)
- Drag-drop system (toolbar → canvas, node → node)
- Connection drawing with bezier curves
- Advanced particle system (multi-layered, physics, trails, glows)
- ParticleCanvasView with Canvas rendering
- Collision effects and node lighting
- TierMapView (all 5 tiers visible)

### Days 5-6: Tiers 1-3
- Tier 1 (Tokyo): Full tutorial, simulation, evaluation
- Tier 2 (London): Network simulation with latency/failure controls
- Tier 3 (Singapore): Performance simulation with metrics
- Simulation engine with particle emission
- Evaluation engine with scoring and feedback
- Tutorial system with spotlight overlays

### Days 7-8: Tiers 4-5 & Code Generation
- Tier 4 (New York): Resilience simulation
- Tier 5 (San Francisco): Modern patterns simulation
- CodeGenerator class with pattern detection
- Dynamic Swift code generation for all patterns
- Syntax highlighting with AttributedString
- CodeView split-screen UI
- Code-visual synchronization
- InspectorView with animated scores

### Days 9-10: Educational Features
- 30+ glossary term definitions (GlossaryDatabase)
- GlossaryView with search and categories
- Inline glossary popovers
- 7 architecture recipe templates (RecipeDatabase)
- RecipeBookView UI
- Recipe loading functionality
- ComparisonView (side-by-side)
- LearnMoreView for all components
- Achievement system (10 achievements)
- AchievementsView gallery

### Day 11: Polish & Accessibility
- HapticManager (success, error, selection, impact)
- Haptic feedback throughout app
- VoiceOver labels for all elements
- VoiceOver announcements
- Dynamic Type with @ScaledMetric
- Reduce Motion alternatives
- High Contrast mode support
- Minimum 44x44 touch targets
- OnboardingView
- SettingsView with credits
- Demo mode (reset, skip tutorials)

### Day 12: Testing & Submission
- Test all 5 tiers end-to-end
- Test on actual iPad (Swift Playgrounds app)
- Test offline mode (airplane mode)
- Test all accessibility features
- VoiceOver navigation test
- Performance testing (60fps verification)
- Rehearse 3-minute demo 10+ times
- Check file size < 25 MB
- Verify all content in English
- Create ZIP file
- Submit via developer.apple.com

---

## Project File Structure

**App/**
- CityArchitectApp.swift (main with SwiftData container)
- ContentView.swift (root navigation)

**Models/**
- SwiftData/: 5 @Model classes (CityProgress, Tier, Architecture, ArchitectureNode, NodeConnection)
- NodeType.swift (enum with 18 types + metadata)
- EvaluationTypes.swift (Result, Feedback, AntiPattern)
- SimulationTypes.swift (Event, Config, Metrics, Particle)
- GlossaryTypes.swift (30+ term definitions)
- RecipeTypes.swift (7 templates)

**Engine/**
- ArchitectureGraph.swift (graph logic + SwiftData)
- SimulationEngine.swift (particle physics + animation)
- EvaluationEngine.swift (scoring + feedback)
- CodeGenerator.swift (dynamic Swift code)
- ParticlePhysics.swift (bezier, collision, trails)

**Persistence/**
- SwiftDataManager.swift (queries, CRUD operations)
- DataSeeder.swift (first launch setup)
- ProgressTracker.swift (achievements, metrics)

**Views/** (14 main screens + 30+ components)
- Organized in folders: Onboarding, TierMap, Builder, Simulation, Evaluation, Education, Achievements, Tutorial, Settings, Components

**ViewModels/**
- AppViewModel, TierViewModel, BuilderViewModel, SimulationViewModel, EvaluationViewModel, AchievementViewModel, GlossaryViewModel, RecipeViewModel

**Utilities/**
- Managers/: HapticManager, AnimationManager, AccessibilityManager
- Design/: ColorSystem, TypographySystem, LayoutConstants, ShadowStyles
- Helpers/: GeometryHelpers, DragHelpers, SnappingHelpers, ValidationHelpers
- Extensions/: Color, View, Animation, String, CGPoint

**Data/**
- GlossaryDatabase.swift (30+ definitions)
- RecipeDatabase.swift (7 templates)
- TierContent.swift (tier metadata: city name, tagline, problem statements per tier)
- RealWorldExamples.swift (app examples)

---

## Testing Strategy

**Functional Testing**:
- All 5 tiers completable without bugs
- All connections validate correctly
- Anti-patterns detect accurately
- Simulation runs smoothly
- SwiftData saves and loads correctly
- All tutorials skipable

**Accessibility Testing**:
- Navigate with VoiceOver completely
- Test with largest Dynamic Type
- Enable Reduce Motion (still works)
- Test High Contrast mode
- Keyboard navigation works

**Performance Testing**:
- 60fps during particle animations
- No lag during drag-drop
- Zoom/pan smooth
- Memory usage < 200 MB
- No memory leaks

**Demo Testing**:
- Rehearse 3-minute flow 10+ times
- Test reset button (returns to demo state)
- Test on actual iPad hardware
- Test offline (airplane mode)

---

## Submission Checklist (Essential Items)

**Code Quality**:
- Remove all TODO comments
- Remove all debug prints
- No compiler warnings
- Consistent naming conventions

**Content**:
- All text in English
- Spell-check completed
- No placeholder text

**Functionality**:
- All 5 tiers completable
- No crashes in any flow
- SwiftData persistence works
- Particle simulation smooth
- All features functional

**Accessibility**:
- VoiceOver works on every screen
- Dynamic Type at largest size works
- Reduce Motion tested
- High Contrast tested

**Platform Testing**:
- Test on actual iPad Pro
- Test in Swift Playgrounds app (not just Xcode)
- Test completely offline
- Performance verified (60fps)

**File Requirements**:
- All resources included locally
- No network calls
- File size < 25 MB
- Credits page complete
- Format: .swiftpm in ZIP

**Submission**:
- Submit via developer.apple.com/swift-student-challenge/apply
- Before February 28, 2026, 11:59 PM PST

---

## Why This Submission Wins

**Visual Impact** (Hook in 5 seconds):
- Mesmerizing particle simulation
- Professional dark mode design
- Smooth animations

**Technical Excellence** (Impress by minute 1):
- SwiftData with complex relationships
- Advanced particle physics
- Graph algorithms
- Production-level architecture

**Innovation** (Unique by minute 2):
- Real-time Swift code generation
- Visual-to-code bridge
- 30+ term contextual glossary
- No other submission will have this

**Educational Value** (Win by minute 3):
- All 5 tiers teach progressive concepts
- Multiple learning modalities
- Real-world connections
- Immediate feedback

**Completeness** (Seal the deal):
- All features functional
- Full accessibility
- Proper testing
- Professional polish

---

## Success Probability

**Must-Have** (Days 1-6): Tiers 1-3, basic simulation, SwiftData, particles → **Solid submission**

**Should-Have** (Days 7-8): Tiers 4-5, code generation, glossary → **Top 20% of submissions**

**Nice-to-Have** (Days 9-10): Comparison view, full accessibility, all polish → **Top 5%, winner potential**

**Expected Score**: 95/100 (Top 1-2%)

---

## Competitive Advantage

**Most submissions**:
- Simple games or utilities
- Basic features
- Poor accessibility
- Incomplete features

**Your submission**:
- Educational with deep technical implementation
- 42 complete features
- Full accessibility
- Production-quality code
- Unique innovations

**Judges will remember**: Particle simulation (5 sec), code generation (2 min), educational value (3 min)

---

## Quick Start Steps

1. **Foundation** (Days 1-2): SwiftData models, Graph Engine, NodeTypes
2. **Core UI** (Days 3-4): BuilderView, drag-drop, particles
3. **Tiers** (Days 5-8): Implement all 5 tiers with simulations
4. **Features** (Days 9-10): Code generation, glossary, recipes
5. **Polish** (Day 11): Accessibility, haptics, achievements
6. **Submit** (Day 12): Test, rehearse demo, submit

---

## Plan Status: Complete & Ready

Your plan includes:
- All 5 tiers fully specified
- SwiftData architecture defined
- Advanced particle system detailed
- Dynamic code generation approach
- 42 features listed
- 12-day realistic timeline
- Complete testing and submission strategy
- Demo script optimized for judges

**When ready to start building, switch to Agent mode and begin execution.**
