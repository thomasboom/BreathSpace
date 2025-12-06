import 'package:flutter/material.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/gemini_service.dart';
import 'package:BreathSpace/exercise_detail_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';

class GeminiExerciseScreen extends StatefulWidget {
  const GeminiExerciseScreen({super.key});

  @override
  State<GeminiExerciseScreen> createState() => _GeminiExerciseScreenState();
}

class _GeminiExerciseScreenState extends State<GeminiExerciseScreen> {
  final TextEditingController _userInputController = TextEditingController();
  bool _isLoading = false;
  // BreathingExercise? _recommendedExercise; // Unused field
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void dispose() {
    _userInputController.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = _speechToText.isListening;
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _lastWords = 'Error: ${error.errorMsg}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech recognition error: ${error.errorMsg}')),
          );
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          _userInputController.text = _lastWords;
        });
      });
    } else {
      setState(() {
        _isListening = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _getRecommendation() async {
    if (_userInputController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final geminiService = GeminiService();
    final recommendedId = await geminiService.recommendExercise(
      _userInputController.text,
      breathingExercises, // Assuming breathingExercises is globally available or passed
    );

    setState(() {
      _isLoading = false;
    });

    if (recommendedId != 'none') {
      BreathingExercise? recommendedExercise;
      try {
        recommendedExercise = breathingExercises.firstWhere(
          (exercise) => exercise.id == recommendedId,
          orElse: () => breathingExercises.first, // Fallback to first exercise if not found
        );
      } catch (e) {
        // Handle case where breathingExercises might be empty or firstWhere fails
        if (breathingExercises.isNotEmpty) {
          recommendedExercise = breathingExercises.first;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No exercises available to recommend.')),
            );
          }
          return;
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exercise: recommendedExercise!), // Assert non-null
          ),
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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  controller: _userInputController,
                  decoration: InputDecoration(
                    hintText: 'e.g., "stressed", "need to focus", "just worked out"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                                    color: _isListening
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                                onPressed: _isListening ? _stopListening : _startListening,
                              ),
                        IconButton(
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                          onPressed: _getRecommendation,
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _getRecommendation(),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
