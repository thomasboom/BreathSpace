import 'package:flutter/material.dart';
import 'package:BreathSpace/widgets/kids_bubble_widget.dart';
import 'package:BreathSpace/widgets/emotion_selector_widget.dart';
import 'package:BreathSpace/widgets/kids_start_button.dart';
import 'package:BreathSpace/kids_mode_exercise_screen.dart';


class KidsModeSelectionScreen extends StatefulWidget {
  const KidsModeSelectionScreen({super.key});

  @override
  State<KidsModeSelectionScreen> createState() => _KidsModeSelectionScreenState();
}

class _KidsModeSelectionScreenState extends State<KidsModeSelectionScreen> {
  Emotion? _selectedEmotion;
  bool _showStartButton = false;

  void _onEmotionSelected(Emotion emotion) {
    setState(() {
      _selectedEmotion = emotion;
      _showStartButton = true;
    });
  }

  void _onStartPressed() {
    if (_selectedEmotion != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => KidsModeExerciseScreen(
            emotion: _selectedEmotion!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  String _getWelcomeText() {
    if (_selectedEmotion == null) {
      return "Hi! I'm Breathe Buddy! How are you feeling today?";
    } else {
      return "Great! I can help you feel better. Ready to start our breathing adventure?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade100,
              Colors.purple.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header - no back button in kids mode
                const SizedBox(height: 20),
                
                const SizedBox(height: 40),
                
                // Breathing buddy with speech
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KidsBubbleWidget(
                        speechText: _getWelcomeText(),
                        size: 160,
                        bubbleColor: Colors.purple,
                        isAnimating: false,
                        showFace: true,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Either emotion selector or start button
                      if (!_showStartButton)
                        Expanded(
                          child: EmotionSelectorWidget(
                            onEmotionSelected: _onEmotionSelected,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              KidsStartButton(
                                onPressed: _onStartPressed,
                                text: "START",
                                backgroundColor: _selectedEmotion!.color,
                                size: 100,
                              ),
                              const SizedBox(height: 20),
                              // Allow re-selection
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showStartButton = false;
                                    _selectedEmotion = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Choose a different feeling",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
