# Technical Architecture
## Jacked into the Matrix

## System Overview

The system is a phone-first wearable instruction architecture.

- iPhone app manages scripts, playback state, editing, storage, and future AI processing
- Even G2 displays short text steps and accepts simple navigation input
- AI, when introduced, rewrites or interprets content on the phone first

## V1 Architecture

### Client
- SwiftUI iPhone application
- local data persistence using SwiftData or Core Data
- local script rendering and playback state management

### Wearable Integration Layer
Responsibilities:
- connect to Even G2
- send current script payload
- update steps on change
- clear or replace active script

### Script Formatting Engine
Responsibilities:
- chunk steps for G2 display limits
- enforce max length rules
- attach metadata such as progress, warnings, or tips
- maintain stable order

## V1 Data Flow

1. User opens a script on iPhone
2. App loads metadata and steps from local storage
3. Formatting engine transforms current step into G2-friendly payload
4. App sends payload to G2
5. User advances next/back
6. Playback state updates locally
7. App re-sends updated step payload as needed

## V2 AI-Assisted Architecture

### Primary Model
- Gemma 4 E2B on iPhone for local script rewriting and compact step generation

### Fallback Model
- proven remote model for tasks where local generation fails, is too slow, or returns low confidence

### AI Responsibilities
- compress long instructions
- split into atomic steps
- preserve sequence
- preserve safety-critical details
- emit structured output for the app

### Example Structured Output

```json
{
  "title": "Update OpenClaw via CLI",
  "risk_level": "medium",
  "steps": [
    {"text": "Check your current version"},
    {"text": "Stop active services"},
    {"text": "Run the update command"}
  ]
}
```

## Safety Layer

For high-risk categories:
- require risk labeling
- surface warnings before playback
- preserve source references on phone
- avoid silent auto-rewrites without user review

## Technical Risks

- unknowns in the cleanest native app to G2 delivery model
- latency and thermal behavior for local on-device inference
- variability in small-model formatting quality
- disconnect/reconnect state consistency
