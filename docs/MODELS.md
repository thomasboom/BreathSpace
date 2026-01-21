# Data Models

This document describes the data models used in the BreathSpace application.

## Table of Contents

- [Overview](#overview)
- [ExerciseVersion Enum](#exerciseversion-enum)
- [PhaseInstruction Model](#phaseinstruction-model)
- [ExerciseVersionData Model](#exerciseversiondata-model)
- [BreathingStage Model](#breathingstage-model)
- [BreathingExercise Model](#breathingexercise-model)
- [Exercise Types](#exercise-types)
- [Localization](#localization)

## Overview

BreathSpace uses a hierarchical model system to support different exercise types including simple breathing patterns, progressive exercises with multiple stages, and stretching exercises. The data is loaded from `assets/exercises.json`.

## ExerciseVersion Enum

Defines the different duration variants available for exercises.

```dart
enum ExerciseVersion { short, normal, long }
```

### Properties

- `short`: Short version of the exercise (typically 1-2 minutes)
- `normal`: Normal version (typically 3-5 minutes)
- `long`: Long version (typically 5-10 minutes)

## PhaseInstruction Model

Instructions displayed during specific phases of breathing, with optional time windows.

### Structure

```dart
class PhaseInstruction {
  final String instructionKey;
  final int? startOffset;
  final int? endOffset;
}
```

### Properties

- `instructionKey`: Localization key for the instruction text
- `startOffset`: Optional start time in seconds (defaults to 0)
- `endOffset`: Optional end time in seconds (defaults to large number)

### Example JSON

```json
{
  "instruction_key": "inhaleNose",
  "start_offset": 0,
  "end_offset": 2
}
```

## ExerciseVersionData Model

Contains version-specific exercise data.

### Structure

```dart
class ExerciseVersionData {
  final String? duration;
  final String? pattern;
  final List<BreathingStage>? stages;
  final List<int>? stageDurations;
}
```

### Properties

- `duration`: Duration string (e.g., "2 min")
- `pattern`: Breathing pattern (e.g., "4-4-4-4")
- `stages`: Custom stages for this version
- `stageDurations`: Durations for base stages (overrides base stage durations)

### Example JSON

```json
{
  "duration": "2 min",
  "pattern": "4-4-4-4",
  "stage_durations": [60, 60, 60, 60]
}
```

## BreathingStage Model

Represents a single stage in a multi-stage exercise.

### Structure

```dart
class BreathingStage {
  final String title;
  final String? titleKey;
  final String pattern;
  final int duration;
  final String? inhaleMethod;
  final String? exhaleMethod;
  final Map<String, List<PhaseInstruction>>? phaseInstructions;
}
```

### Properties

- `title`: Title text or key
- `titleKey`: Optional localization key for title
- `pattern`: Breathing pattern in format "inhale-hold-exhale-hold"
- `duration`: Duration of the stage in seconds
- `inhaleMethod`: Optional breathing method for inhale
- `exhaleMethod`: Optional breathing method for exhale
- `phaseInstructions`: Optional instructions for each phase

### Example JSON

```json
{
  "title": "Stage 1",
  "title_key": "stage1_title",
  "pattern": "4-4-4-4",
  "duration": 120,
  "inhale_method": "Nose",
  "exhale_method": "Mouth",
  "phase_instructions": {
    "inhale": [
      {
        "instruction_key": "inhaleDeeply",
        "start_offset": 0,
        "end_offset": 2
      }
    ],
    "hold": [
      {
        "instruction_key": "holdBreath",
        "start_offset": 0,
        "end_offset": 4
      }
    ]
  }
}
```

## BreathingExercise Model

The main exercise model representing a complete breathing exercise.

### Structure

```dart
class BreathingExercise {
  final String id;
  final String title;
  final String? titleKey;
  final String pattern;
  final String duration;
  final String intro;
  final String? introKey;
  final String? type;
  final List<BreathingStage>? stages;
  final String? inhaleMethod;
  final String? exhaleMethod;
  final Map<ExerciseVersion, ExerciseVersionData>? versions;
}
```

### Properties

- `id`: Unique identifier for the exercise
- `title`: Title text or key
- `titleKey`: Optional localization key for title
- `pattern`: Default breathing pattern
- `duration`: Default duration string
- `intro`: Introduction text or key
- `introKey`: Optional localization key for intro
- `type`: Exercise type ("normal", "progressive", "stretching")
- `stages`: List of stages for progressive exercises
- `inhaleMethod`: Optional breathing method for inhale
- `exhaleMethod`: Optional breathing method for exhale
- `versions`: Map of version data for short/normal/long variants

### Getters

- `hasStages`: Returns `true` if stages are present
- `hasVersions`: Returns `true` if versions are present
- `isStretchingExercise`: Returns `true` for stretching exercises
- `isProgressiveExercise`: Returns `true` for progressive exercises
- `exerciseType`: Returns the exercise type as a string

### Methods

- `getVersionData(ExerciseVersion)`: Returns version data for a specific version
- `getPatternForVersion(ExerciseVersion)`: Returns pattern for a specific version
- `getDurationForVersion(ExerciseVersion)`: Returns duration for a specific version
- `getStagesForVersion(ExerciseVersion)`: Returns stages for a specific version
- `getLocalizedTitle(AppLocalizations)`: Returns localized title
- `getLocalizedIntro(AppLocalizations)`: Returns localized intro

### Example JSON

#### Simple Exercise

```json
{
  "id": "box-breathing",
  "title": {
    "en": "Box Breathing",
    "es": "Respiración en Caja"
  },
  "pattern": "4-4-4-4",
  "duration": "4 min",
  "intro": {
    "en": "A simple technique to calm your mind and body.",
    "es": "Una técnica simple para calmar tu mente y cuerpo."
  },
  "versions": {
    "short": {
      "duration": "2 min",
      "pattern": "4-4-4-4"
    },
    "normal": {
      "duration": "4 min",
      "pattern": "4-4-4-4"
    },
    "long": {
      "duration": "8 min",
      "pattern": "4-4-4-4"
    }
  }
}
```

#### Progressive Exercise

```json
{
  "id": "progressive-relaxation",
  "title": "Progressive Relaxation",
  "intro": "Start with simple breathing and gradually increase depth.",
  "type": "progressive",
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
  ]
}
```

#### Exercise with Localization Keys

```json
{
  "id": "relaxing-breath",
  "title_key": "exerciseTitle_relaxingBreath",
  "intro_key": "exerciseIntro_relaxingBreath",
  "pattern": "4-7-8",
  "duration": "3 min",
  "versions": {
    "short": {
      "duration": "1 min",
      "stage_durations": [30, 30]
    },
    "normal": {
      "duration": "3 min",
      "stage_durations": [90, 90]
    },
    "long": {
      "duration": "5 min",
      "stage_durations": [150, 150]
    }
  }
}
```

## Exercise Types

### Normal Exercises

Standard breathing exercises with a single pattern. Can have multiple versions.

**Characteristics:**
- Simple pattern (e.g., "4-4-4-4", "4-7-8")
- Optional versions (short/normal/long)
- Title and intro can be localized strings or keys

### Progressive Exercises

Multi-stage exercises that increase in difficulty or change patterns.

**Characteristics:**
- Multiple stages with different patterns/durations
- `type` field is "progressive" or implied by presence of stages
- Each stage can have its own pattern and duration

### Stretching Exercises

Exercises focused on stretching with breathing.

**Characteristics:**
- `type` field is "stretching"
- May include specific inhale/exhale methods
- Can have multiple stages

## Localization

Exercise data supports two localization approaches:

### 1. Inline Translations

Title and intro are provided as maps of language codes to translated strings:

```json
{
  "title": {
    "en": "Box Breathing",
    "es": "Respiración en Caja"
  }
}
```

### 2. Localization Keys

Title and intro reference keys in the ARB files:

```json
{
  "title_key": "exerciseTitle_relaxingBreath",
  "intro_key": "exerciseIntro_relaxingBreath"
}
```

### Phase Instructions

Phase instructions use localization keys that map to ARB file entries. The `getPhaseInstructionKey()` method determines which instruction to display based on elapsed time within a phase.

```dart
String? getPhaseInstructionKey(String phase, int elapsedSecondsInPhase)
```

## JSON Format

The complete exercise data is stored in `assets/exercises.json` as an array of exercise objects. The file is loaded at startup and parsed using the `fromJson()` factory constructors.

For exercises with localization keys, the app uses `AppLocalizations` from the `gen-l10n` system to resolve the translated text.

## Exercise Loading

Exercises are loaded using the `loadBreathingExercises()` function which:
1. Reads `assets/exercises.json`
2. Parses JSON data
3. Creates `BreathingExercise` objects using `fromJson()`
4. Returns a list of exercises
