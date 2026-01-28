import 'dart:io';
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
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
            ),
          );
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            _userInputController.text = _lastWords;
          });
        },
      );
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

    try {
      final geminiService = GeminiService();

      // Set loading to false to hide the loader in this screen,
      // since the detail screen will show its own loading
      setState(() {
        _isLoading = false;
      });

      // Navigate immediately to ExerciseDetailScreen with AI callback
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (detailContext) => ExerciseDetailScreen(
              aiRecommendationCallback: () async {
                try {
                  // Enhance the user input with structured context for better recommendations
                  String enhancedPrompt =
                      "I need a personalized breathing exercise recommendation based on my input: '${_userInputController.text}'. "
                      "Please recommend the most appropriate breathing exercise from the following list of exercises, considering: "
                      "1) My emotional state described in my input "
                      "2) My desired outcome based on my input "
                      "3) The exercise duration and complexity level that matches my current situation. "
                      "Provide only the ID of the most suitable breathing exercise from the available options. "
                      "Available exercise categories include: stress relief, sleep preparation, anxiety management, "
                      "energy boosting, focus enhancement, meditation preparation, physical recovery, and general relaxation.";

                  final recommendedId = await geminiService.recommendExercise(
                    enhancedPrompt,
                    breathingExercises,
                  );

                  if (recommendedId == null) {
                    // API call failed
                    if (detailContext.mounted) {
                      ScaffoldMessenger.of(detailContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to connect to AI service. Please check your internet connection and try again.',
                          ),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                    return null;
                  }

                  if (recommendedId == 'none') {
                    // No suitable recommendation
                    if (detailContext.mounted) {
                      ScaffoldMessenger.of(detailContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No suitable exercise found for your request. Try describing your mood or goal differently.',
                          ),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                    return null;
                  }

                  // Find the recommended exercise
                  BreathingExercise? recommendedExercise;
                  try {
                    recommendedExercise = breathingExercises.firstWhere(
                      (exercise) => exercise.id == recommendedId,
                    );
                  } catch (e) {
                    // Exercise not found, fallback to first exercise
                    if (breathingExercises.isNotEmpty) {
                      recommendedExercise = breathingExercises.first;
                    } else {
                      if (detailContext.mounted) {
                        ScaffoldMessenger.of(detailContext).showSnackBar(
                          const SnackBar(
                            content: Text('No exercises available.'),
                          ),
                        );
                      }
                      return null;
                    }
                  }

                  return recommendedExercise;
                } catch (e) {
                  if (detailContext.mounted) {
                    ScaffoldMessenger.of(detailContext).showSnackBar(
                      SnackBar(
                        content: Text('An error occurred: ${e.toString()}'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  return null;
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 1),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  Theme.of(context).colorScheme.primary
                                      .withValues(alpha: 0.08),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.psychology_outlined,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tell me about your mood or what you need',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _userInputController,
                              decoration: InputDecoration(
                                hintText:
                                    'e.g., "stressed", "need to focus", "just worked out"',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(24),
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isLoading)
                                        Container(
                                          width: 24,
                                          height: 24,
                                          padding: const EdgeInsets.all(2),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        )
                                      else if (Platform.isAndroid ||
                                          Platform.isIOS)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                _isListening
                                                    ? Icons.mic_off
                                                    : Icons.mic,
                                                color: _isListening
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                    : Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                size: 24,
                                              ),
                                              onPressed: _isListening
                                                  ? _stopListening
                                                  : _startListening,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        )
                                      else
                                        SizedBox.shrink(),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.send,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            size: 20,
                                          ),
                                          onPressed: _getRecommendation,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              onSubmitted: (_) => _getRecommendation(),
                              maxLines: 3,
                              cursorColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              cursorWidth: 2,
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
