import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:BreathSpace/data.dart';

void main() {
  test('Stages parsing works correctly', () async {
    final file = File('assets/exercises.json');
    final content = await file.readAsString();
    final List<dynamic> data = json.decode(content);

    int stagedExerciseCount = 0;

    for (var exerciseJson in data) {
      final exercise = BreathingExercise.fromJson(exerciseJson, 'en');

      if (exercise.hasStages) {
        stagedExerciseCount++;
        expect(exercise.stages, isNotNull);
        expect(exercise.stages!.isNotEmpty, true);

        for (var stage in exercise.stages!) {
          expect(stage.pattern, isNotEmpty);
          expect(stage.duration, greaterThan(0));
          expect(stage.titleKey ?? stage.title, isNotEmpty);
        }

        if (exercise.hasVersions) {
          for (var version in ExerciseVersion.values) {
            final stages = exercise.getStagesForVersion(version);
            expect(stages, isNotNull);
            expect(stages!.length, exercise.stages!.length);
          }
        }
      }
    }

    expect(stagedExerciseCount, greaterThan(0));
    print('Tested $stagedExerciseCount staged exercises successfully');
  });
}
