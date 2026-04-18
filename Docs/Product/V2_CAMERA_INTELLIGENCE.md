# V2 Camera Intelligence
## Jacked into the Matrix

## Vision

Use the iPhone camera as the visual input system for the Even G2 experience.

The phone sees.
Local AI interprets.
The glasses display the next most useful line.

## V2 Goal

Enable a user to point their iPhone camera at the world and receive compact, contextual guidance on the glasses.

## Proposed Architecture

- iPhone camera captures frames
- local model analyzes selected frames
- app turns the result into compact HUD-safe text
- Even G2 displays the result

## Primary Model
- Gemma 4 E2B on-device

## Fallback Model
- a proven remote multimodal model when local analysis is too slow or uncertain

## Good V2 Tasks

### Electrical
- identify likely components
- match current visual state to expected step
- surface the next likely instruction

### CLI / Screen Interpretation
- use phone camera to inspect terminal or laptop screen
- summarize the current state into one next action

### Belay / Safety Rehearsal
- identify visible setup elements
- run guided checklist prompts
- flag obvious issues with caution language

### Cooking
- identify prep stage
- suggest next step
- remind ingredients or timing

## Best Interaction Modes

### Tap-to-Analyze
User requests a single analysis of the current scene.

### Step Verification
User follows a script and asks the system whether the current scene matches the expected state.

### Ask-for-Context
User asks a targeted question about what they are looking at.

## Product Guardrails

- do not overclaim certainty
- use confidence-aware language
- keep the output short
- avoid continuous open-ended narration as the default
- require extra caution in high-risk categories

## Example Output

`You are on step 4. Traveler wires appear identified.`

`Brake strand may be on the wrong side. Recheck device threading.`

`Pasta is ready to drain. Reserve some pasta water first.`
