# Implementation Notes

## Primary principles
- Keep V1 local-first
- Phone owns logic, glasses render compact steps
- High-risk scripts require review before playback
- Gemma 4 E2B is the default local model route
- Fallback must be explicit and observable in debug state

## Immediate tasks
- Stand up models and repositories
- Get the seed scripts loading
- Build a mock playback loop on phone
- Define and test G2 display payload sizing
- Add validator before model integration
