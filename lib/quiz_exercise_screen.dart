import 'package:flutter/material.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/exercise_detail_screen.dart';
import 'package:BreathSpace/gemini_service.dart';

class QuizExerciseScreen extends StatefulWidget {
  const QuizExerciseScreen({super.key});

  @override
  State<QuizExerciseScreen> createState() => _QuizExerciseScreenState();
}

class _QuizExerciseScreenState extends State<QuizExerciseScreen> {
  // Quiz step tracking
  int _currentStep = 0;

  // Selected emoji choices - store the label instead of the icon string
  String? _selectedMood;
  String? _selectedFeeling;
  String? _selectedNeed;

  // Icon options for each category
  final List<Map<String, dynamic>> _moodOptions = [
    {'icon': Icons.mood, 'label': 'Happy'},
    {'icon': Icons.sentiment_dissatisfied, 'label': 'Sad'},
    {'icon': Icons.psychology_alt_outlined, 'label': 'Anxious'},
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Stressed'},
    {'icon': Icons.bedtime, 'label': 'Tired'},
    {'icon': Icons.sentiment_neutral, 'label': 'Neutral'},
    {'icon': Icons.gavel, 'label': 'Angry'},
    {'icon': Icons.sentiment_satisfied, 'label': 'Calm'},
  ];

  final List<Map<String, dynamic>> _feelingOptions = [
    {'icon': Icons.crisis_alert, 'label': 'Overwhelmed'},
    {'icon': Icons.psychology_alt_outlined, 'label': 'Dizzy'},
    {'icon': Icons.favorite_border, 'label': 'Heartbroken'},
    {'icon': Icons.help_outline, 'label': 'Confused'},
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Frustrated'},
    {'icon': Icons.hourglass_empty, 'label': 'Exhausted'},
    {'icon': Icons.psychology_alt_outlined, 'label': 'Nervous'},
    {'icon': Icons.sentiment_satisfied, 'label': 'Okay'},
  ];

  final List<Map<String, dynamic>> _needOptions = [
    {'icon': Icons.bedtime, 'label': 'Sleep'},
    {'icon': Icons.self_improvement, 'label': 'Relax'},
    {'icon': Icons.flash_on, 'label': 'Energy'},
    {'icon': Icons.psychology_alt_outlined, 'label': 'Focus'},
    {'icon': Icons.favorite_border, 'label': 'Comfort'},
    {'icon': Icons.bolt, 'label': 'Motivation'},
    {'icon': Icons.mood, 'label': 'Happiness'},
    {'icon': Icons.sentiment_satisfied, 'label': 'Peace'},
  ];

  // Quiz steps data
  late List<Map<String, dynamic>> _quizSteps;

  @override
  void initState() {
    super.initState();
    _quizSteps = [
      {
        'title': 'How is your mood?',
        'subtitle': 'Choose an icon that best describes your current mood',
        'options': _moodOptions,
        'getSelectedValue': () => _selectedMood,
        'onChanged': (String? value) {
          setState(() {
            _selectedMood = value; // Now storing the label
          });
        },
      },
      {
        'title': 'How are you feeling?',
        'subtitle': 'Describe how you feel right now',
        'options': _feelingOptions,
        'getSelectedValue': () => _selectedFeeling,
        'onChanged': (String? value) {
          setState(() {
            _selectedFeeling = value; // Now storing the label
          });
        },
      },
      {
        'title': 'What do you need?',
        'subtitle': 'Select what would help you most',
        'options': _needOptions,
        'getSelectedValue': () => _selectedNeed,
        'onChanged': (String? value) {
          setState(() {
            _selectedNeed = value; // Now storing the label
          });
        },
      },
    ];
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
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
                    Icons.question_mark,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _quizSteps[_currentStep]['title'],
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
                  _quizSteps[_currentStep]['subtitle'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _quizSteps.length; i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentStep
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),

                // Emoji Selection - Using Wrap to prevent stretching
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter, // Center the content
                    child: _buildEmojiSelection(
                      options: _quizSteps[_currentStep]['options'],
                      selectedValue:
                          _quizSteps[_currentStep]['getSelectedValue'](),
                      onChanged: _quizSteps[_currentStep]['onChanged'],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_currentStep > 0)
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _quizSteps[_currentStep]['getSelectedValue']() !=
                                  null
                              ? _nextStep
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            _currentStep < _quizSteps.length - 1
                                ? 'Next'
                                : 'Find My Exercise',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiSelection({
    required List<Map<String, dynamic>> options,
    required String? selectedValue,
    required void Function(String? value) onChanged,
  }) {
    // Using Wrap to make the buttons compact and not stretch
    return Center(
      child: Wrap(
        spacing: 8.0, // Horizontal spacing
        runSpacing: 8.0, // Vertical spacing
        alignment: WrapAlignment.center,
        children: options.map((option) {
          final isSelected = selectedValue == option['label'];
          return GestureDetector(
            onTap: () => onChanged(option['label']),
            child: Container(
              width: 70, // Fixed width
              height: 80, // Fixed height
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option['icon'] as IconData,
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _quizSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // All questions answered, navigate to exercise
      _navigateToRecommendedExercise();
    }
  }

  void _navigateToRecommendedExercise() {
    // Create a description from the quiz selections to send to Gemini API
    String moodDescription = _selectedMood != null
        ? _getIconLabelFromValue(_selectedMood!)
        : '';
    String feelingDescription = _selectedFeeling != null
        ? _getIconLabelFromValue(_selectedFeeling!)
        : '';
    String needDescription = _selectedNeed != null
        ? _getIconLabelFromValue(_selectedNeed!)
        : '';

    // Create a descriptive prompt for the Gemini API with more context and structure
    String prompt =
        "I need a personalized breathing exercise recommendation based on my current state. "
        "My mood is ${moodDescription.isEmpty ? 'not specified' : moodDescription.toLowerCase()}, "
        "I'm feeling ${feelingDescription.isEmpty ? 'not specified' : feelingDescription.toLowerCase()}, "
        "and what I need most right now is ${needDescription.isEmpty ? 'not specified' : needDescription.toLowerCase()}. "
        "Please recommend the most appropriate breathing exercise from the following list of exercises, considering: "
        "1) My emotional state (${moodDescription.isEmpty ? 'not specified' : moodDescription.toLowerCase()}, ${feelingDescription.isEmpty ? 'not specified' : feelingDescription.toLowerCase()}) "
        "2) My desired outcome (${needDescription.isEmpty ? 'not specified' : needDescription.toLowerCase()}) "
        "3) The exercise duration and complexity level that matches my current situation. "
        "Provide only the ID of the most suitable breathing exercise from the available options. "
        "Available exercise categories include: stress relief, sleep preparation, anxiety management, "
        "energy boosting, focus enhancement, meditation preparation, physical recovery, and general relaxation.";

    // Navigate to ExerciseDetailScreen with AI callback to get personalized recommendation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (detailContext) => ExerciseDetailScreen(
          aiRecommendationCallback: () async {
            try {
              final geminiService = GeminiService();
              final recommendedId = await geminiService.recommendExercise(
                prompt,
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
                        'No suitable exercise found for your selections. Try different selections.',
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
                      const SnackBar(content: Text('No exercises available.')),
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

  // Helper method - now we're storing labels directly, no need to map icon to label
  String _getIconLabelFromValue(String iconValue) {
    // Since we're now storing the label directly, we can just return the value
    return iconValue;
  }
}
