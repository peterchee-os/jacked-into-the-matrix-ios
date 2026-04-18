# Wearable Step Prompt Contract

Convert instructions into short Even G2-friendly steps.

## Rules
- one action per step
- prefer verbs first
- remove filler
- preserve safety-critical details
- output valid JSON only

## JSON schema
```json
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
