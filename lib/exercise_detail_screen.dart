import 'package:flutter/material.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/exercise_screen.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:clipboard/clipboard.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  ExerciseVersion _selectedVersion = ExerciseVersion.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.exercise.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.exercise.intro,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),

            // Version selection buttons
            if (widget.exercise.hasVersions) ...[
              Text(
                'Choose Version:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildVersionButton(ExerciseVersion.short, 'Short'),
                  const SizedBox(width: 8.0),
                  _buildVersionButton(ExerciseVersion.normal, 'Normal'),
                  const SizedBox(width: 8.0),
                  _buildVersionButton(ExerciseVersion.long, 'Long'),
                ],
              ),
              const SizedBox(height: 16.0),
            ],

            if (widget.exercise.hasStages || widget.exercise.getStagesForVersion(_selectedVersion) != null) ...[
              Text(
                AppLocalizations.of(context).progressiveExercise,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              ...?(widget.exercise.getStagesForVersion(_selectedVersion)?.map((stage) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stage.title}: ${stage.pattern} (${_formatDuration(stage.duration)})',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )) ?? widget.exercise.stages?.map((stage) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stage.title}: ${stage.pattern} (${_formatDuration(stage.duration)})',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ))),
            ] else ...[
              Text(
                'Pattern: ${widget.exercise.getPatternForVersion(_selectedVersion)}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Duration: ${widget.exercise.getDurationForVersion(_selectedVersion)}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseScreen(
                        exercise: widget.exercise,
                        selectedVersion: _selectedVersion,
                      ),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context).start),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionButton(ExerciseVersion version, String label) {
    final isSelected = version == _selectedVersion;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedVersion = version;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white
            : null,
      ),
      child: Text(label),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      final minutes = seconds ~/ 60;
      return '$minutes min';
    }
  }

  void _copyExerciseLink(BuildContext context) {
    final String shareUrl = 'https://openbreath.vercel.app/exercise/${widget.exercise.id}';

    FlutterClipboard.copy(shareUrl).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(this.context).linkCopied),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
