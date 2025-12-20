import 'package:flutter/material.dart';

enum Emotion {
  tired(Icons.bedtime_rounded, "Tired", Colors.blue),
  stressed(Icons.sentiment_very_dissatisfied_rounded, "Stressed", Colors.orange),
  angry(Icons.mood_bad_rounded, "Angry", Colors.red),
  sad(Icons.sentiment_dissatisfied_rounded, "Sad", Colors.indigo),
  excited(Icons.sentiment_very_satisfied_rounded, "Excited", Colors.green),
  calm(Icons.sentiment_satisfied_rounded, "Calm", Colors.teal);

  const Emotion(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

class EmotionSelectorWidget extends StatefulWidget {
  final Function(Emotion) onEmotionSelected;
  final bool constrainWidth;

  const EmotionSelectorWidget({
    super.key,
    required this.onEmotionSelected,
    this.constrainWidth = true,
  });

  @override
  State<EmotionSelectorWidget> createState() => _EmotionSelectorWidgetState();
}

class _EmotionSelectorWidgetState extends State<EmotionSelectorWidget>
    with TickerProviderStateMixin {
  Emotion? _selectedEmotion;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onEmotionTap(Emotion emotion) {
    setState(() {
      _selectedEmotion = emotion;
    });
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    // Give a small delay to show the selection before callback
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onEmotionSelected(emotion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "How are you feeling?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          
          // Emotion grid - now scrollable and dynamic
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate columns based on available width
                int crossAxisCount;
                if (constraints.maxWidth < 400) {
                  crossAxisCount = 2; // Small screens - 2x3
                } else if (constraints.maxWidth < 600) {
                  crossAxisCount = 3; // Medium screens - 3x2
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 4; // Large tablets - 4x2
                } else {
                  crossAxisCount = 6; // Desktop - all in one row
                }

                final gridView = GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: constraints.maxWidth > 1200 ? 20 : 8,
                        mainAxisSpacing: constraints.maxWidth > 1200 ? 20 : 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: Emotion.values.length,
                  itemBuilder: (context, index) {
                    final emotion = Emotion.values[index];
                    final isSelected = _selectedEmotion == emotion;
                    
                    return AnimatedBuilder(
                      animation: isSelected && _selectedEmotion == emotion 
                          ? _bounceAnimation 
                          : const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isSelected ? _bounceAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: () => _onEmotionTap(emotion),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? emotion.color.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected 
                                      ? emotion.color 
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: emotion.color.withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 5,
                                        ),
                                    ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    emotion.icon,
                                    size: 28,
                                    color: isSelected 
                                        ? emotion.color 
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    emotion.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected 
                                          ? emotion.color 
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );

                // Apply constraint only if requested (for desktop layouts)
                if (widget.constrainWidth) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth > 800 ? 600.0 : double.infinity,
                      ),
                      child: gridView,
                    ),
                  );
                } else {
                  return gridView;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
