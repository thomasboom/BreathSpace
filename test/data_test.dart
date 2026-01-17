import 'package:flutter_test/flutter_test.dart';
import 'package:BreathSpace/data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PhaseInstruction', () {
    test('fromJson creates correct PhaseInstruction', () {
      final json = {
        'instruction_key': 'test_instruction',
        'start_offset': 2,
        'end_offset': 5,
      };
      final instruction = PhaseInstruction.fromJson(json);
      expect(instruction.instructionKey, 'test_instruction');
      expect(instruction.startOffset, 2);
      expect(instruction.endOffset, 5);
    });

    test('fromJson handles null offsets', () {
      final json = {'instruction_key': 'test_instruction'};
      final instruction = PhaseInstruction.fromJson(json);
      expect(instruction.startOffset, null);
      expect(instruction.endOffset, null);
    });

    test('isActive returns true when within range', () {
      final instruction = PhaseInstruction(
        instructionKey: 'test',
        startOffset: 2,
        endOffset: 5,
      );
      expect(instruction.isActive(3), true);
      expect(instruction.isActive(2), true);
      expect(instruction.isActive(4), true);
    });

    test('isActive returns false when outside range', () {
      final instruction = PhaseInstruction(
        instructionKey: 'test',
        startOffset: 2,
        endOffset: 5,
      );
      expect(instruction.isActive(1), false);
      expect(instruction.isActive(5), false);
      expect(instruction.isActive(100), false);
    });

    test('isActive uses defaults when offsets are null', () {
      final instruction = PhaseInstruction(instructionKey: 'test');
      expect(instruction.isActive(0), true);
      expect(instruction.isActive(999998), true);
    });

    test('toJson produces correct JSON', () {
      final instruction = PhaseInstruction(
        instructionKey: 'test',
        startOffset: 1,
        endOffset: 3,
      );
      final json = instruction.toJson();
      expect(json['instruction_key'], 'test');
      expect(json['start_offset'], 1);
      expect(json['end_offset'], 3);
    });
  });

  group('ExerciseVersionData', () {
    test('fromJson creates correct ExerciseVersionData', () {
      final json = {
        'duration': '5 min',
        'pattern': 'in-out',
        'stage_durations': [10, 20, 30],
      };
      final baseStages = [
        BreathingStage(title: 'Stage 1', pattern: 'in', duration: 10),
        BreathingStage(title: 'Stage 2', pattern: 'out', duration: 20),
        BreathingStage(title: 'Stage 3', pattern: 'hold', duration: 30),
      ];
      final versionData = ExerciseVersionData.fromJson(json, baseStages);
      expect(versionData.duration, '5 min');
      expect(versionData.pattern, 'in-out');
      expect(versionData.stageDurations, [10, 20, 30]);
      expect(versionData.stages, isNotNull);
      expect(versionData.stages!.length, 3);
    });

    test('fromJson handles null stage_durations', () {
      final json = {'duration': '5 min', 'pattern': 'in-out'};
      final versionData = ExerciseVersionData.fromJson(json, null);
      expect(versionData.duration, '5 min');
      expect(versionData.pattern, 'in-out');
      expect(versionData.stageDurations, null);
    });

    test('fromJson handles embedded stages', () {
      final json = {
        'duration': '5 min',
        'stages': [
          {'title': 'Custom Stage', 'pattern': 'in', 'duration': 15},
        ],
      };
      final versionData = ExerciseVersionData.fromJson(json, null);
      expect(versionData.stages, isNotNull);
      expect(versionData.stages!.length, 1);
      expect(versionData.stages![0].title, 'Custom Stage');
    });
  });

  group('BreathingStage', () {
    test('fromJson creates correct BreathingStage with title string', () {
      final json = {'title': 'Test Stage', 'pattern': 'in-out', 'duration': 10};
      final stage = BreathingStage.fromJson(json, 'en');
      expect(stage.title, 'Test Stage');
      expect(stage.titleKey, null);
      expect(stage.pattern, 'in-out');
      expect(stage.duration, 10);
    });

    test('fromJson creates correct BreathingStage with title_key', () {
      final json = {
        'title_key': 'stageTitle_nervousSystemBalance',
        'pattern': 'in-out',
        'duration': 10,
      };
      final stage = BreathingStage.fromJson(json, 'en');
      expect(stage.title, 'stageTitle_nervousSystemBalance');
      expect(stage.titleKey, 'stageTitle_nervousSystemBalance');
    });

    test('fromJson handles multilingual title', () {
      final json = {
        'title': {'en': 'English Title', 'es': 'Titulo Español'},
        'pattern': 'in-out',
        'duration': 10,
      };
      final stageEn = BreathingStage.fromJson(json, 'en');
      expect(stageEn.title, 'English Title');

      final stageEs = BreathingStage.fromJson(json, 'es');
      expect(stageEs.title, 'Titulo Español');
    });

    test('fromJson falls back to English when language not found', () {
      final json = {
        'title': {'en': 'English Title'},
        'pattern': 'in-out',
        'duration': 10,
      };
      final stage = BreathingStage.fromJson(json, 'fr');
      expect(stage.title, 'English Title');
    });

    test('fromJson uses Untitled when no title provided', () {
      final json = {'pattern': 'in-out', 'duration': 10};
      final stage = BreathingStage.fromJson(json, 'en');
      expect(stage.title, 'Untitled');
    });

    test('fromJson handles phaseInstructions', () {
      final json = {
        'title': 'Test Stage',
        'pattern': 'in-out',
        'duration': 10,
        'phase_instructions': {
          'in': [
            {
              'instruction_key': 'phase_instruct_shouldersUp',
              'start_offset': 0,
              'end_offset': 2,
            },
          ],
        },
      };
      final stage = BreathingStage.fromJson(json, 'en');
      expect(stage.phaseInstructions, isNotNull);
      expect(stage.phaseInstructions!['in'], isNotNull);
      expect(stage.phaseInstructions!['in']!.length, 1);
      expect(
        stage.phaseInstructions!['in']![0].instructionKey,
        'phase_instruct_shouldersUp',
      );
    });

    test('copyWith creates modified copy', () {
      final original = BreathingStage(
        title: 'Original',
        pattern: 'in',
        duration: 10,
      );
      final copy = original.copyWith(duration: 20, pattern: 'out');
      expect(copy.title, 'Original');
      expect(copy.duration, 20);
      expect(copy.pattern, 'out');
    });

    test('getPhaseInstructionKey returns correct instruction', () {
      final stage = BreathingStage(
        title: 'Test',
        pattern: 'in-out',
        duration: 10,
        phaseInstructions: {
          'in': [
            PhaseInstruction(
              instructionKey: 'first_half',
              startOffset: 0,
              endOffset: 2,
            ),
            PhaseInstruction(
              instructionKey: 'second_half',
              startOffset: 2,
              endOffset: 5,
            ),
          ],
        },
      );
      expect(stage.getPhaseInstructionKey('in', 1), 'first_half');
      expect(stage.getPhaseInstructionKey('in', 3), 'second_half');
      expect(stage.getPhaseInstructionKey('out', 0), null);
    });

    test('toJson produces correct JSON', () {
      final stage = BreathingStage(
        title: 'Test Stage',
        titleKey: 'stageTitle_test',
        pattern: 'in-out',
        duration: 10,
        inhaleMethod: 'deep',
        exhaleMethod: 'slow',
      );
      final json = stage.toJson();
      expect(json['title'], 'Test Stage');
      expect(json['title_key'], 'stageTitle_test');
      expect(json['pattern'], 'in-out');
      expect(json['duration'], 10);
      expect(json['inhale_method'], 'deep');
      expect(json['exhale_method'], 'slow');
    });
  });

  group('BreathingExercise', () {
    test('fromJson creates correct BreathingExercise', () {
      final json = {
        'id': 'test-exercise',
        'title': 'Test Exercise',
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'Test intro',
        'type': 'normal',
      };
      final exercise = BreathingExercise.fromJson(json, 'en');
      expect(exercise.id, 'test-exercise');
      expect(exercise.title, 'Test Exercise');
      expect(exercise.pattern, 'in-out');
      expect(exercise.duration, '5 min');
      expect(exercise.intro, 'Test intro');
      expect(exercise.type, 'normal');
    });

    test('fromJson handles multilingual title', () {
      final json = {
        'id': 'test-exercise',
        'title': {'en': 'English Exercise', 'es': 'Ejercicio Español'},
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'Test intro',
      };
      final exerciseEn = BreathingExercise.fromJson(json, 'en');
      expect(exerciseEn.title, 'English Exercise');

      final exerciseEs = BreathingExercise.fromJson(json, 'es');
      expect(exerciseEs.title, 'Ejercicio Español');
    });

    test('fromJson handles title_key', () {
      final json = {
        'id': 'test-exercise',
        'title_key': 'exerciseTitle_relaxingBreath',
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'Test intro',
      };
      final exercise = BreathingExercise.fromJson(json, 'en');
      expect(exercise.titleKey, 'exerciseTitle_relaxingBreath');
      expect(exercise.title, 'exerciseTitle_relaxingBreath');
    });

    test('fromJson handles stages', () {
      final json = {
        'id': 'test-exercise',
        'title': 'Test Exercise',
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'Test intro',
        'stages': [
          {'title': 'Stage 1', 'pattern': 'in', 'duration': 5},
          {'title': 'Stage 2', 'pattern': 'out', 'duration': 5},
        ],
      };
      final exercise = BreathingExercise.fromJson(json, 'en');
      expect(exercise.hasStages, true);
      expect(exercise.stages, isNotNull);
      expect(exercise.stages!.length, 2);
    });

    test('fromJson handles versions', () {
      final json = {
        'id': 'test-exercise',
        'title': 'Test Exercise',
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'Test intro',
        'versions': {
          'short': {
            'duration': '3 min',
            'stage_durations': [3, 3, 3],
          },
          'long': {
            'duration': '10 min',
            'stage_durations': [10, 10, 10],
          },
        },
      };
      final exercise = BreathingExercise.fromJson(json, 'en');
      expect(exercise.hasVersions, true);
      expect(exercise.versions, isNotNull);
      expect(exercise.versions!.containsKey(ExerciseVersion.short), true);
      expect(exercise.versions!.containsKey(ExerciseVersion.long), true);
    });

    test('hasStages returns correct value', () {
      final exerciseWithStages = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
        'stages': [
          {'title': 'S1', 'pattern': 'in', 'duration': 10},
        ],
      }, 'en');
      expect(exerciseWithStages.hasStages, true);

      final exerciseWithoutStages = BreathingExercise.fromJson({
        'id': 'test2',
        'title': 'Test2',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
      }, 'en');
      expect(exerciseWithoutStages.hasStages, false);
    });

    test('hasVersions returns correct value', () {
      final exerciseWithVersions = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
        'versions': {
          'short': {'duration': '1 min'},
        },
      }, 'en');
      expect(exerciseWithVersions.hasVersions, true);

      final exerciseWithoutVersions = BreathingExercise.fromJson({
        'id': 'test2',
        'title': 'Test2',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
      }, 'en');
      expect(exerciseWithoutVersions.hasVersions, false);
    });

    test('isStretchingExercise returns correct value', () {
      final stretching = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
        'type': 'stretching',
      }, 'en');
      expect(stretching.isStretchingExercise, true);
      expect(stretching.isProgressiveExercise, false);
    });

    test('isProgressiveExercise returns correct value', () {
      final progressive = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
        'type': 'progressive',
      }, 'en');
      expect(progressive.isProgressiveExercise, true);

      final staged = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '1 min',
        'intro': 'intro',
        'stages': [
          {'title': 'S1', 'pattern': 'in', 'duration': 10},
        ],
      }, 'en');
      expect(staged.isProgressiveExercise, true);
    });

    test('exerciseType returns correct type string', () {
      expect(
        BreathingExercise.fromJson({
          'id': 'test',
          'title': 'Test',
          'pattern': 'in',
          'duration': '1 min',
          'intro': 'intro',
          'type': 'stretching',
        }, 'en').exerciseType,
        'stretching',
      );

      expect(
        BreathingExercise.fromJson({
          'id': 'test',
          'title': 'Test',
          'pattern': 'in',
          'duration': '1 min',
          'intro': 'intro',
          'stages': [
            {'title': 'S1', 'pattern': 'in', 'duration': 10},
          ],
        }, 'en').exerciseType,
        'progressive',
      );

      expect(
        BreathingExercise.fromJson({
          'id': 'test',
          'title': 'Test',
          'pattern': 'in',
          'duration': '1 min',
          'intro': 'intro',
        }, 'en').exerciseType,
        'normal',
      );
    });

    test('getVersionData returns correct version data', () {
      final exercise = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in-out',
        'duration': '5 min',
        'intro': 'intro',
        'versions': {
          'short': {'duration': '3 min'},
        },
      }, 'en');
      expect(exercise.getVersionData(ExerciseVersion.short), isNotNull);
      expect(exercise.getVersionData(ExerciseVersion.short)!.duration, '3 min');
      expect(exercise.getVersionData(ExerciseVersion.normal), null);
    });

    test('getPatternForVersion returns correct pattern', () {
      final exercise = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'base-pattern',
        'duration': '5 min',
        'intro': 'intro',
        'versions': {
          'short': {'pattern': 'short-pattern'},
        },
      }, 'en');
      expect(
        exercise.getPatternForVersion(ExerciseVersion.short),
        'short-pattern',
      );
      expect(
        exercise.getPatternForVersion(ExerciseVersion.normal),
        'base-pattern',
      );
    });

    test('getDurationForVersion returns correct duration', () {
      final exercise = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '5 min',
        'intro': 'intro',
        'versions': {
          'short': {'duration': '3 min'},
        },
      }, 'en');
      expect(exercise.getDurationForVersion(ExerciseVersion.short), '3 min');
      expect(exercise.getDurationForVersion(ExerciseVersion.normal), '5 min');
    });

    test('getStagesForVersion returns correct stages', () {
      final exercise = BreathingExercise.fromJson({
        'id': 'test',
        'title': 'Test',
        'pattern': 'in',
        'duration': '5 min',
        'intro': 'intro',
        'stages': [
          {'title': 'S1', 'pattern': 'in', 'duration': 5},
        ],
        'versions': {
          'short': {
            'stage_durations': [10],
          },
        },
      }, 'en');
      final shortStages = exercise.getStagesForVersion(ExerciseVersion.short);
      expect(shortStages, isNotNull);
      expect(shortStages![0].duration, 10);

      final normalStages = exercise.getStagesForVersion(ExerciseVersion.normal);
      expect(normalStages, isNotNull);
      expect(normalStages![0].duration, 5);
    });
  });

  group('loadBreathingExercisesForLanguageCode', () {
    test('loads exercises from assets', () async {
      await loadBreathingExercisesForLanguageCode('en');
      expect(breathingExercises.length, greaterThan(0));
    });

    test('loads exercises for different languages', () async {
      await loadBreathingExercisesForLanguageCode('es');
      expect(breathingExercises.length, greaterThan(0));
    });

    test('filter out test exercise in release mode', () async {
      await loadBreathingExercisesForLanguageCode('en');
      final hasTestExercise = breathingExercises.any(
        (e) => e.id == 'test-5-0-5-0',
      );
      expect(hasTestExercise, false);
    });
  });
}
