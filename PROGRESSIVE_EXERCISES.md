# Progressive Breathing Exercises

Progressive breathing exercises allow users to gradually increase the difficulty of their breathing practice by moving through different stages with varying patterns and durations.

## Structure

A progressive breathing exercise consists of multiple stages, each with:
- `title`: A descriptive name for the stage
- `pattern`: The breathing pattern (e.g., "4-4-4-4")
- `duration`: The duration of the stage in seconds

## JSON Format

To create a progressive breathing exercise, use the following JSON structure:

```json
{
  "title": "Progressive Breathing Exercise",
  "stages": [
    {
      "title": "Beginner Stage",
      "pattern": "4-4-4-4",
      "duration": 120
    },
    {
      "title": "Intermediate Stage",
      "pattern": "5-5-5-5",
      "duration": 180
    },
    {
      "title": "Advanced Stage",
      "pattern": "4-5-6-7",
      "duration": 300
    }
  ],
  "intro": "A progressive breathing exercise that gradually increases in difficulty."
}
```

## Properties

### Exercise Properties
- `title`: The name of the exercise (required)
- `stages`: An array of stage objects (required for progressive exercises)
- `intro`: A brief description of the exercise (required)

### Stage Properties
- `title`: The name of the stage (required)
- `pattern`: The breathing pattern in the format "inhale-hold-exhale-hold" (required)
- `duration`: The duration of the stage in seconds (required)

## Example

Here's a complete example of a progressive breathing exercise:

```json
{
  "title": "Progressive Relaxation",
  "stages": [
    {
      "title": "Easy Start",
      "pattern": "4-4-4-4",
      "duration": 120
    },
    {
      "title": "Deeper Breathing",
      "pattern": "5-5-5-5",
      "duration": 180
    },
    {
      "title": "Advanced Relaxation",
      "pattern": "6-6-6-6",
      "duration": 240
    }
  ],
  "intro": "Start with simple breathing and gradually increase the depth and duration."
}
```

This exercise will:
1. Begin with 2 minutes of 4-4-4-4 breathing
2. Progress to 3 minutes of 5-5-5-5 breathing
3. Finish with 4 minutes of 6-6-6-6 breathing

## Pattern Format

The pattern format follows the structure: `inhale-hold-exhale-hold`

Examples:
- `4-4-4-4`: Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds
- `4-7-8`: Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds (no final hold)
- `5-5`: Inhale for 5 seconds, exhale for 5 seconds (no holds)

## Duration

The duration is specified in seconds. Here are some common conversions:
- 1 minute = 60 seconds
- 2 minutes = 120 seconds
- 3 minutes = 180 seconds
- 5 minutes = 300 seconds
- 10 minutes = 600 seconds

## Best Practices

1. **Gradual Progression**: Start with simpler patterns and shorter durations, then gradually increase complexity
2. **Consistent Timing**: Keep the total exercise time reasonable (typically 5-15 minutes total)
3. **Clear Titles**: Use descriptive titles that indicate the difficulty level or purpose of each stage
4. **Logical Flow**: Ensure each stage builds naturally on the previous one