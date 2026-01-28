import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExerciseFinishedScreen extends StatelessWidget {
  const ExerciseFinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.exerciseFinishedTitle),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.exerciseFinishedTitle,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                localizations.exerciseFinishedSubtitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).popUntil((route) => route.isFirst); // Go back to home
                },
                child: Text(localizations.backToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
