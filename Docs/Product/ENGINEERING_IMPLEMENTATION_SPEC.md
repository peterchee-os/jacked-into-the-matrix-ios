# Jacked into the Matrix
## Engineering Implementation Spec

Version: 1.0  
Status: Draft  
Primary platform: iPhone + Even Realities G2  
Primary local model: Gemma 4 E2B  
Fallback model path: proven local or cloud model via model router

---

## 1. Purpose

This document translates the product requirements for Jacked into the Matrix into an engineering implementation plan.

The goal is to build an iPhone application that:
- stores and organizes wearable instruction scripts
- converts long-form instructions into short, G2-friendly steps
- sends those steps to Even Realities G2 glasses
- supports step-by-step, continuous, and drill playback modes
- prepares the system for a V2 camera-intelligence mode using on-device AI

This spec is written to help engineering define repo structure, app architecture, data model, prompt contracts, device integration, model routing, testing, and rollout.

---

## 2. Implementation Goals

### V1 engineering goal
Ship a reliable curated script player with local storage, script editing, AI-assisted step formatting, and Even G2 playback.

### V1.5 engineering goal
Add production-safe model routing so the app can use Gemma 4 E2B first and fall back to a proven alternative when unavailable, too slow, or low-confidence.

### V2 engineering goal
Use the iPhone camera as the visual input source, run multimodal analysis locally when possible, and send compact contextual information to the glasses.

---

## 3. Repositories and Modules

Recommended structure:

### Option A: Single app repo
- `jacked-into-the-matrix-ios/`
  - `App/`
  - `Features/`
  - `Core/`
  - `Services/`
  - `Models/`
  - `Resources/`
  - `Tests/`

### Option B: Split repos
- `jacked-into-the-matrix-ios`
- `jacked-into-the-matrix-prompts`
- `jacked-into-the-matrix-backend` (future)
- `jacked-into-the-matrix-docs`

### Recommendation
Start with **Option A** for speed. Keep prompts and schema definitions as versioned files inside the app repo.

---

## 4. High-Level Architecture

### Runtime components
1. **iOS App**
   - SwiftUI UI shell
   - local storage
   - Even integration coordinator
   - model coordinator
   - playback engine

2. **Local Model Layer**
   - primary: Gemma 4 E2B
   - fallback: local proven model or remote multimodal/text model
   - structured generation for step compression and formatting

3. **Even G2 Integration Layer**
   - connection/session state
   - page payload formatting
   - navigation events
   - step sync

4. **Content Engine**
   - script model
   - step model
   - formatters
   - risk labels
   - validation rules

5. **Future Camera Intelligence Layer**
   - AVFoundation frame capture
   - frame sampler
   - prompt builder
   - scene interpretation formatter

---

## 5. iOS App Architecture

Recommended pattern:
- **SwiftUI** for UI
- **MVVM + feature modules**
- **SwiftData** for local persistence in V1
- protocol-driven services for model and Even integrations

### Suggested folders
- `App/`
  - app entry
  - routing
  - global environment
- `Core/`
  - design system
  - utilities
  - shared types
- `Models/`
  - Script
  - Step
  - PlaybackState
  - WarningCard
  - SourceReference
- `Features/Home/`
- `Features/Categories/`
- `Features/ScriptDetail/`
- `Features/Playback/`
- `Features/DrillMode/`
- `Features/Favorites/`
- `Features/Recents/`
- `Features/Glasses/`
- `Features/Settings/`
- `Services/Modeling/`
- `Services/Even/`
- `Services/Storage/`
- `Services/Telemetry/`
- `Tests/`

### Recommended global dependencies
- `AppRouter`
- `ScriptRepository`
- `PlaybackEngine`
- `ModelRouter`
- `EvenSessionManager`
- `AnalyticsService`

---

## 6. Core Feature Breakdown

### 6.1 Home
Responsibilities:
- show recent scripts
- show favorites
- show categories
- resume active playback

Engineering notes:
- load from local repository
- cache lightweight preview cards
- support one-tap resume

### 6.2 Categories
Responsibilities:
- render top-level categories
- show scripts filtered by category
- optionally support basic search

Engineering notes:
- category definitions may ship as static config for V1
- scripts must be queryable by category and risk level

### 6.3 Script Detail
Responsibilities:
- display title, summary, warnings, materials, steps
- allow favorite toggle
- allow basic edit
- allow AI reformat
- send to glasses

Engineering notes:
- this screen is the main preflight review point
- high-risk scripts should show a warning confirmation step

### 6.4 Playback
Responsibilities:
- show current step
- navigate next/previous
- switch playback mode
- keep phone and glasses in sync
- persist progress

Engineering notes:
- step transitions should be low latency
- progress persistence should happen on every step change

### 6.5 Drill Mode
Responsibilities:
- hide future step content
- reveal next prompt or answer
- support restart/reset

Engineering notes:
- drill state can be derived from playback state plus mode enum

### 6.6 Glasses Status
Responsibilities:
- show connection state
- show loaded script
- re-send current script
- clear current session

Engineering notes:
- build this around an explicit Even session state machine

---

## 7. Data Model

### 7.1 Script
```swift
struct Script: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var category: ScriptCategory
    var summary: String
    var riskLevel: RiskLevel
    var sourceType: SourceType
    var sourceReferences: [SourceReference]
    var prerequisites: [String]
    var toolsNeeded: [String]
    var materialsNeeded: [String]
    var warnings: [WarningCard]
    var verificationChecklist: [String]
    var steps: [InstructionStep]
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

### 7.2 Step
```swift
struct InstructionStep: Identifiable, Codable, Hashable {
    let id: UUID
    var orderIndex: Int
    var title: String?
    var text: String
    var tip: String?
    var warning: String?
    var estimatedDurationSeconds: Int?
}
```

### 7.3 Playback state
```swift
struct PlaybackState: Codable, Hashable {
    var scriptID: UUID
    var currentStepIndex: Int
    var mode: PlaybackMode
    var completedStepIndices: Set<Int>
    var lastSyncedToGlassesAt: Date?
    var startedAt: Date?
    var updatedAt: Date
}
```

### 7.4 Enums
```swift
enum ScriptCategory: String, Codable, CaseIterable {
    case homeDIY
    case softwareCLI
    case climbingOutdoor
    case cooking
    case fitnessMovement
    case emergencyChecklists
}

enum RiskLevel: String, Codable {
    case low
    case medium
    case high
}

enum PlaybackMode: String, Codable {
    case stepByStep
    case continuous
    case drill
}

enum SourceType: String, Codable {
    case curated
    case userAuthored
    case aiGenerated
    case hybrid
}
```

---

## 8. Local Persistence

### Recommended store
Use **SwiftData** in V1 unless a specific reason requires Core Data.

Persist:
- scripts
- playback state
- favorites
- recent activity
- model generation history (optional)
- current glasses session metadata

### Repository protocol
```swift
protocol ScriptRepository {
    func fetchAllScripts() async throws -> [Script]
    func fetchFavorites() async throws -> [Script]
    func fetchRecentScripts() async throws -> [Script]
    func fetchScript(id: UUID) async throws -> Script?
    func saveScript(_ script: Script) async throws
    func deleteScript(id: UUID) async throws
}
```

---

## 9. Even G2 Integration Design

### 9.1 Core assumption
The phone owns the application logic. The glasses render compact text and capture simple navigation input.

### 9.2 Required capabilities
- connect/disconnect
- load a script payload
- render current step
- update current step
- handle next/back/scroll actions
- recover from disconnects gracefully

### 9.3 Session manager
```swift
protocol EvenSessionManaging {
    var state: EvenSessionState { get }
    func connect() async
    func disconnect() async
    func send(payload: G2DisplayPayload) async throws
    func clearDisplay() async throws
}
```

### 9.4 Session state
```swift
enum EvenSessionState: Equatable {
    case disconnected
    case connecting
    case connected(deviceName: String?)
    case failed(reason: String)
}
```

### 9.5 Display payload model
The app should never send raw long-form script content directly to the G2 layer. It should send already-constrained display payloads.

```swift
struct G2DisplayPayload: Codable, Hashable {
    var scriptTitle: String
    var stepIndex: Int
    var totalSteps: Int
    var primaryText: String
    var secondaryText: String?
    var mode: PlaybackMode
}
```

### 9.6 Payload rules
- primary text must fit a glanceable screen unit
- secondary text is optional tip or warning
- no paragraph blocks
- title may be abbreviated
- progress indicator should always be present when feasible

### 9.7 Input mapping
Suggested mapping:
- single press: next
- double press: previous
- swipe up: scroll or reveal
- swipe down: back or collapse

Exact mapping must be finalized after device testing.

---

## 10. Model Routing Architecture

### 10.1 Requirements
The app must:
- use **Gemma 4 E2B** as primary for local text transformation
- fall back to a proven model path when Gemma is unavailable or unreliable
- expose generation reason and model used for debugging
- support strict structured outputs

### 10.2 Router responsibilities
- choose model
- build prompt
- validate structured output
- retry with fallback if needed
- record telemetry

### 10.3 Protocol
```swift
protocol ModelRouting {
    func generateWearableSteps(
        from source: ScriptGenerationInput,
        constraints: StepGenerationConstraints
    ) async throws -> StepGenerationResult
}
```

### 10.4 Generation input
```swift
struct ScriptGenerationInput: Codable, Hashable {
    var title: String
    var rawInstructionText: String
    var category: ScriptCategory
    var riskLevel: RiskLevel
}
```

### 10.5 Constraints
```swift
struct StepGenerationConstraints: Codable, Hashable {
    var maxPrimaryTextCharacters: Int
    var maxSecondaryTextCharacters: Int
    var maxSteps: Int
    var preserveWarnings: Bool
    var requireVerbFirst: Bool
}
```

### 10.6 Result
```swift
struct StepGenerationResult: Codable, Hashable {
    var modelID: String
    var fallbackUsed: Bool
    var confidence: Double?
    var generatedScript: Script
    var warnings: [String]
}
```

### 10.7 Routing policy
Recommended order:
1. Gemma 4 E2B local
2. fallback local proven model if installed
3. fallback remote text model if enabled by user
4. return recoverable error if no route is available

### 10.8 Retry triggers
Retry or fail over when:
- output is malformed JSON
- output exceeds hard display constraints
- latency exceeds threshold
- model times out
- model confidence or validator score falls below threshold

---

## 11. Prompt Contract for Step Conversion

### Purpose
Convert raw instructions into compact steps that fit Even G2 display constraints.

### Prompt template
```text
You are converting instructions into wearable smart-glasses guidance.

Goal:
Rewrite the source material into short, clear, step-by-step actions for Even G2 smart glasses.

Rules:
- one action per step
- prefer verbs first
- remove filler
- preserve safety-critical details
- keep steps short and concrete
- keep ordering logical
- include warnings only when essential
- output valid JSON only

Output JSON schema:
{
  "title": "string",
  "summary": "string",
  "risk_level": "low|medium|high",
  "steps": [
    {
      "title": "optional short label",
      "text": "required primary step text",
      "tip": "optional short tip",
      "warning": "optional short warning"
    }
  ]
}
```

### Suggested constraints for V1
- primary step text target: 45 to 80 chars
- secondary tip target: 20 to 50 chars
- max steps by default: 12
- hard truncate should happen only after validation failure, not before generation

### Validation rules
Reject outputs that:
- omit steps
- generate paragraphs
- exceed max length repeatedly
- lose critical warnings for high-risk content
- reorder required sequence incorrectly

---

## 12. Script Formatting Pipeline

### Pipeline
1. source script loaded
2. normalize whitespace and lists
3. build generation prompt
4. call model router
5. validate structured result
6. convert to internal `Script`
7. present review screen
8. save approved script
9. transform current step to G2 payload
10. send to glasses

### Rule
For **high-risk content**, user review on phone must occur before sending generated steps to glasses.

---

## 13. Starter Scripts for V1

Ship these as static bundled JSON or seed data:
- Wire a three-way light switch
- Update OpenClaw via CLI
- Pass the lead belay gym test
- Garden fresh pesto pasta

### Recommendation
Each starter script should include:
- gold-standard authored long form
- authored wearable step version
- AI-reformatted test version for comparison
- regression fixtures for QA

---

## 14. UI Implementation Notes

### 14.1 Home screen
Data sources:
- recent scripts query
- favorites query
- active playback lookup

### 14.2 Script detail screen
Actions:
- edit
- favorite
- regenerate wearable steps
- send to glasses
- start on phone

### 14.3 Playback screen
Must show:
- title
- step index / total
- primary text
- secondary tip or warning
- next/back controls
- mode toggle

### 14.4 Editing experience
V1 editing can be lightweight:
- edit title
- edit step text
- edit tips/warnings
- reorder steps later if needed, not mandatory for first release

---

## 15. V2 Camera Intelligence Architecture

### Objective
Use the iPhone camera as the visual input source and produce compact contextual guidance for the G2 display.

### V2 modes
1. tap-to-analyze
2. step verification
3. ask-for-context
4. screen interpretation for laptop/terminal use
5. cooking state recognition

### Capture pipeline
1. user enters camera mode
2. AVFoundation captures preview
3. frame sampler selects still frame or low-rate sample
4. prompt builder combines frame + task context
5. Gemma 4 E2B multimodal path runs locally when available
6. result is validated and compressed
7. short response sent to glasses

### V2 caution
Do not start with continuous always-on interpretation.
Start with user-triggered frame analysis.

---

## 16. Telemetry and Logging

### Track locally in V1
- scripts opened
- scripts favorited
- scripts sent to glasses
- playback completion
- average steps completed
- model selected
- fallback used
- generation latency
- validation failure count
- disconnect count

### Log categories
- UI navigation
- playback events
- model generation
- Even session state
- validation warnings

### Privacy principle
Do not upload camera frames or script contents by default unless the user explicitly enables remote fallback or cloud sync.

---

## 17. Error Handling

### Model layer
Handle:
- unavailable model
- malformed output
- timeout
- overheating / memory pressure signal
- unsupported multimodal call

### Even layer
Handle:
- no paired device
- connection lost
- send failure
- unsupported payload state

### UX principle
Show recoverable language:
- “Gemma unavailable, using fallback model”
- “Glasses disconnected, continue on phone?”
- “Generated steps need review before playback”

---

## 18. Performance Targets

V1 targets:
- app cold launch under 2.5s on target hardware
- script detail open under 300ms from local store
- step-to-step phone playback under 100ms perceived latency
- glasses update under 500ms perceived latency target
- local generation for medium script under 3 to 8s target depending on device/model

These are directional targets for prototype and should be measured.

---

## 19. Security and Privacy

- local-first storage for V1
- no hidden cloud dependency for core playback
- remote fallback opt-in only
- model routing and source disclosure visible in debug view
- high-risk generated content must surface source and review context on phone

---

## 20. Testing Strategy

### 20.1 Unit tests
Cover:
- script repository
- playback engine
- prompt builder
- validator
- model router logic
- G2 payload formatter

### 20.2 Snapshot/UI tests
Cover:
- home
- category
- script detail
- playback
- drill mode
- glasses status

### 20.3 Fixture tests
Use starter scripts as locked fixtures:
- long-form authored input
- expected wearable output
- validator pass/fail cases

### 20.4 Integration tests
Test:
- generate wearable steps then save
- open playback and sync to mocked G2 session
- disconnect/reconnect behavior
- fallback model routing after primary failure

### 20.5 Human device tests
Must validate on real hardware:
- readability on Even G2
- navigation gesture usability
- connection stability
- latency
- text density comfort

---

## 21. Debug / Internal Screens

Recommended hidden debug menu:
- current model
- generation latency
- raw prompt preview
- raw JSON output preview
- validator results
- fallback reason
- Even session status
- last payload sent

This will save a lot of time.

---

## 22. Rollout Plan

### Milestone 1
Curated scripts only
- local storage
- playback on phone
- no AI generation
- mocked glasses layer acceptable

### Milestone 2
Real Even integration
- send step payloads
- next/back sync
- state recovery

### Milestone 3
Gemma 4 E2B local generation
- prompt + validator
- structured outputs
- review flow

### Milestone 4
Fallback routing
- reliable failover
- telemetry and debug states

### Milestone 5
V2 camera prototype
- tap-to-analyze
- one or two use cases only

---

## 23. Open Engineering Questions

1. What is the exact safe text density per G2 screen for comfort?
2. What local model packaging path is most stable on iPhone for Gemma 4 E2B?
3. Which fallback should be considered the “proven model” for first release?
4. How much Even-side UI flexibility is available once real device testing begins?
5. What is the best validator for preserving safety-critical instructions?
6. Should generated scripts be versioned so users can compare edits vs AI output?

---

## 24. Recommended Immediate Build Order

1. Build data models and local repository
2. Build Home, Categories, Script Detail, Playback
3. Seed four starter scripts
4. Build mock Even session manager and payload formatter
5. Test playback UX on phone
6. Wire real Even integration
7. Add Gemma 4 E2B model router abstraction
8. Add structured generation and validator
9. Add fallback path
10. Begin V2 camera spike

---

## 25. Definition of Done for V1

V1 is done when:
- user can browse starter scripts
- user can favorite and resume scripts
- user can play a script on phone
- user can send steps to Even G2
- current step and progress are readable on the glasses
- AI can convert raw instructions into valid G2-friendly steps
- fallback path works when Gemma is unavailable
- high-risk content requires phone review before playback

---

## 26. Final Recommendation

Build this as a **local-first wearable instruction system**.

Do not overcomplicate V1 with fully autonomous sourcing.
The engineering priority is:
- stable script model
- excellent playback UX
- reliable Even sync
- strict model output validation
- thoughtful fallback routing

That will create the foundation for the more magical V2 camera-aware experience.
