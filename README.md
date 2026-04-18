# Jacked into the Matrix iOS

Jacked into the Matrix is a local-first iPhone app for Even Realities G2 glasses.

The app turns long-form instructions into short, wearable, step-by-step guidance that can be viewed on the glasses or followed on the phone. V1 focuses on curated starter scripts, playback modes, local storage, and a model-routing layer that uses Gemma 4 E2B first with a fallback path.

## V1 goals
- Browse scripts by category
- Save favorites and recents
- Play scripts on phone
- Send compact steps to Even G2
- Support step-by-step, continuous, and drill modes
- Reformat instructions into G2-friendly steps with AI

## Repo structure
- `App/` app entry and routing
- `Core/` shared UI and utilities
- `Models/` data models
- `Features/` SwiftUI feature modules
- `Services/` integrations and business logic
- `Resources/SeedScripts/` bundled starter scripts
- `Prompts/` model prompt contracts
- `Tests/Fixtures/` regression fixtures
- `Docs/` local project docs

## Initial build order
1. Wire data models and storage
2. Build Home, Categories, Script Detail, Playback
3. Load seed scripts
4. Build mock Even session manager
5. Integrate real Even SDK path
6. Add model router and validator
7. Add fallback routing
8. Start V2 camera spike

## Starter scripts
- Wire a three-way light switch
- Update OpenClaw via CLI
- Pass the lead belay gym test
- Garden fresh pesto pasta
