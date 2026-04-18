# Product Requirements Document
## Jacked into the Matrix

## 1. Overview

Jacked into the Matrix is an iPhone app connected to Even Realities G2 glasses that lets a user select, save, and run instructional scripts as wearable step-by-step guidance.

The product is designed to convert complex instructions into short, glanceable steps that can be followed hands-free during real-world tasks.

## 2. Product Goal

Enable a user to:
- choose a topic or saved script in the iPhone app
- review the script on the phone
- send it to the Even G2 glasses
- follow the instructions one step at a time, in continuous mode, or in drill mode
- save and re-open scripts later

## 3. V1 Goal

Prove that wearable step-by-step instruction is useful across multiple categories and that the Even G2 display is sufficient for real execution support.

## 4. Target User

Early adopters who already own Even Realities G2 glasses and want hands-free guidance for DIY tasks, technical workflows, skill rehearsal, and recipes.

## 5. Problem Statement

How-to information is usually trapped in videos, articles, note apps, and long transcripts. Users often need help at the exact moment of execution, when their hands are busy and screen switching is disruptive.

## 6. Product Thesis

The app should not try to show full tutorials on the glasses.
It should show only the next most useful instruction.

## 7. Primary Use Cases

### 7.1 Electrical
**Topic:** Wire a three-way light switch

Why it matters:
- validates hands-free task execution
- tests warnings, prerequisites, and verification flow
- proves value in a real-world physical environment

### 7.2 Software / CLI
**Topic:** Update OpenClaw via CLI

Why it matters:
- validates technical workflows
- ideal for step-by-step guidance
- easy to verify against expected system outcomes

### 7.3 Climbing / Safety
**Topic:** Pass the lead belay gym test

Why it matters:
- validates drill mode and study mode
- supports rehearsable safety checklists
- highlights the need for risk-aware content

### 7.4 Cooking
**Topic:** Garden fresh pesto pasta

Why it matters:
- validates casual repeat use
- ideal for continuous mode and favorites
- friendly low-risk use case

## 8. Product Principles

1. **Glanceable, not dense**
   The glasses should show short steps, not paragraphs.

2. **Phone does the heavy lifting**
   The phone handles review, editing, saving, generation, and source inspection.

3. **Glasses are for execution**
   The wearable experience should keep the user moving forward.

4. **High-risk content needs safeguards**
   Topics like electrical and belay require stronger warnings and review gates.

5. **Reusable scripts are a core asset**
   Long-term value comes from a trusted personal instruction library.

## 9. Functional Requirements

### 9.1 Script Library
The app must allow users to:
- browse scripts by category
- favorite scripts
- view recents
- reopen saved scripts

### 9.2 Script Review
The app must allow users to:
- view title, summary, risk level, tools, warnings, prerequisites, steps, and verification checklist
- edit scripts before playback
- save updated versions locally

### 9.3 Playback Modes
The system must support:
- step-by-step mode
- continuous mode
- drill mode

### 9.4 Glasses Playback
The system must allow users to:
- send a script to the Even G2
- move next/back through steps
- resume where they left off
- replace the active script

### 9.5 Local Persistence
The app must store:
- scripts
- favorites
- recents
- playback progress
- mode selection

## 10. Non-Functional Requirements

- app launches quickly
- local scripts load instantly
- switching steps on the glasses feels low latency
- disconnects are handled gracefully
- playback state persists reliably

## 11. Out of Scope for V1

- autonomous YouTube ingestion
- full voice control
- always-on scene understanding
- cloud dependency for core playback
- community script marketplace
- rich media on the glasses

## 12. Success Criteria

V1 succeeds if a user can:
1. find a script quickly
2. review it on the phone
3. send it to the glasses
4. follow the steps without confusion
5. save favorites and return later
6. feel that the glasses reduce friction during execution

## 13. Key Risks

- text density on G2 may still be too high if steps are not compact enough
- high-risk content may create trust issues if poorly summarized
- native integration path between iPhone app logic and G2 delivery may need iteration
- local model latency may affect future AI-assisted authoring

## 14. Recommendation

Launch V1 as a curated script player first.
Do not begin with autonomous AI generation.
Nail the wearable execution experience first, then layer in AI generation and camera-assisted context in V2.
