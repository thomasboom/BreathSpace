import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:OpenBreath/data.dart';
import 'package:OpenBreath/gemini_service.dart';
import 'package:OpenBreath/exercise_detail_screen.dart';
import 'package:OpenBreath/l10n/app_localizations.dart';
import 'package:OpenBreath/theme_provider.dart';

class GeminiExerciseScreen extends StatefulWidget {
  const GeminiExerciseScreen({super.key});

  @override
  State<GeminiExerciseScreen> createState() => _GeminiExerciseScreenState();
}

class _GeminiExerciseScreenState extends State<GeminiExerciseScreen> {
  final TextEditingController _userInputController = TextEditingController();
  bool _isLoading = false;
  BreathingExercise? _recommendedExercise;

  @override
  void dispose() {
    _userInputController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    if (_userInputController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _recommendedExercise = null;
    });

    final geminiService = GeminiService();
    final recommendedId = await geminiService.recommendExercise(
      _userInputController.text,
      breathingExercises, // Assuming breathingExercises is globally available or passed
    );

    setState(() {
      _isLoading = false;
    });

    if (recommendedId != null && recommendedId != 'none') {
      print('Gemini recommended ID: $recommendedId'); // Debugging line

      BreathingExercise? recommendedExercise;
      try {
        recommendedExercise = breathingExercises.firstWhere(
          (exercise) => exercise.id == recommendedId,
          orElse: () {
            print('Fallback: Recommended ID "$recommendedId" not found. Using first exercise.'); // Debugging line
            return breathingExercises.first; // Fallback to first exercise if not found
          },
        );
      } catch (e) {
        print('Error finding recommended exercise: $e'); // Debugging line
        // Handle case where breathingExercises might be empty or firstWhere fails
        if (breathingExercises.isNotEmpty) {
          recommendedExercise = breathingExercises.first;
        } else {
          print('Error: breathingExercises list is empty!'); // Critical error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No exercises available to recommend.')),
            );
          }
          return;
        }
      }

      if (recommendedExercise != null && mounted) {
        print('Navigating to ExerciseDetailScreen with exercise ID: ${recommendedExercise.id}'); // Debugging line
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exercise: recommendedExercise!), // Assert non-null
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find a suitable exercise to navigate to.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini could not recommend a suitable exercise.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How are you feeling today?', // Friendly title
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _userInputController,
                decoration: InputDecoration(
                  hintText: 'e.g., "stressed", "need to focus", "just worked out"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                          onPressed: _getRecommendation,
                        ),
                ),
                onSubmitted: (_) => _getRecommendation(),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              // Add a subtle settings icon
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
