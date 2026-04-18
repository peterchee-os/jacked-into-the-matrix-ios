# Data Model and Content Schema
## Jacked into the Matrix

## Core Entity: Script

A script is the core reusable unit of product value.

### Script Fields
- `script_id`
- `title`
- `category`
- `summary`
- `risk_level`
- `source_type`
- `is_favorite`
- `created_at`
- `updated_at`
- `last_opened_at`

## Script Metadata
- `prerequisites[]`
- `tools_needed[]`
- `materials_needed[]`
- `warnings[]`
- `verification_checklist[]`

## Step Entity

### Step Fields
- `step_id`
- `script_id`
- `order_index`
- `instruction_text`
- `tip_text`
- `warning_text`
- `estimated_duration_seconds`

## Playback State
- `script_id`
- `current_step_index`
- `mode`
- `completed_steps[]`
- `last_synced_to_glasses_at`

## Risk Levels
- `low`
- `medium`
- `high`

### Suggested Classification
- Garden fresh pesto pasta → low
- Update OpenClaw via CLI → medium
- Pass the lead belay gym test → high
- Wire a three-way light switch → high

## G2 Display Payload

```json
{
  "title": "PESTO PASTA",
  "progress": "4/8",
  "step": "Blend basil, garlic, nuts, parmesan, oil",
  "tip": "Reserve pasta water before draining"
}
```

## Content Authoring Rules

1. one action per step
2. use strong verbs
3. remove filler
4. preserve safety-critical details
5. keep tip text optional
6. keep warnings sparse but visible

## Categories
- Home DIY
- Software / CLI
- Climbing / Outdoor
- Cooking
- Fitness / Movement
- Emergency / Checklists
