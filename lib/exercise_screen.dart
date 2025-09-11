import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  final String pattern;
  const ExerciseScreen({super.key, required this.pattern});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breatheAnimation;
  late AnimationController _bubbleAnimationController;
  late Animation<double> _bubbleAnimation;
  String _instruction = 'Inhale';
  int _currentCycle = 0;
  final int _totalCycles = 4; // For a 4-minute exercise (4-4-4-4 breathing, 16s per cycle, 15 cycles = 4 minutes)

  List<int> _parsePattern(String pattern) {
    return pattern.split('-').map(int.parse).toList();
  }

  @override
  void initState() {
    super.initState();
    final patternValues = _parsePattern(widget.pattern);
    int inhale = patternValues[0];
    int hold1 = patternValues.length > 1 ? patternValues[1] : 0;
    int exhale = patternValues.length > 2 ? patternValues[2] : 0;
    int hold2 = patternValues.length > 3 ? patternValues[3] : 0;

    int totalDurationSeconds = inhale + hold1 + exhale + hold2;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalDurationSeconds),
    );

    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Adjust duration for desired bubble speed
    )..repeat(reverse: true); // Repeat with reverse to create a pulsating effect

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bubbleAnimationController,
        curve: Curves.easeInOut, // Smooth transition
      ),
    );

        List<TweenSequenceItem<double>> items = [];

    if (inhale > 0) {
      items.add(TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: inhale.toDouble())); // Inhale
    }
    if (hold1 > 0) {
      items.add(TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: hold1.toDouble())); // Hold 1
    }
    if (exhale > 0) {
      items.add(TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: exhale.toDouble())); // Exhale
    }
    if (hold2 > 0) {
      items.add(TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: hold2.toDouble())); // Hold 2
    }

    _breatheAnimation = TweenSequence<double>(items).animate(_controller);

    _startAnimation();
  }

  void _startAnimation() {
    final patternValues = _parsePattern(widget.pattern);
    int inhale = patternValues[0];
    int hold1 = patternValues.length > 1 ? patternValues[1] : 0;
    int exhale = patternValues.length > 2 ? patternValues[2] : 0;
    int hold2 = patternValues.length > 3 ? patternValues[3] : 0;
    int totalDurationSeconds = inhale + hold1 + exhale + hold2;

    double inhaleEnd = inhale / totalDurationSeconds;
    double hold1End = (inhale + hold1) / totalDurationSeconds;
    double exhaleEnd = (inhale + hold1 + exhale) / totalDurationSeconds;

    _controller.repeat();
    _controller.addListener(() {
      if (_controller.value >= 0.0 && _controller.value < inhaleEnd) {
        setState(() {
          _instruction = 'Inhale';
          HapticFeedback.lightImpact();
        });
      } else if (_controller.value >= inhaleEnd && _controller.value < hold1End) {
        setState(() {
          _instruction = 'Hold';
          HapticFeedback.lightImpact();
        });
      } else if (_controller.value >= hold1End && _controller.value < exhaleEnd) {
        setState(() {
          _instruction = 'Exhale';
          HapticFeedback.lightImpact();
        });
      } else if (_controller.value >= exhaleEnd && _controller.value <= 1.0) {
        setState(() {
          _instruction = 'Hold';
          HapticFeedback.lightImpact();
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentCycle++;
        if (_currentCycle >= _totalCycles) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubbleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_breatheAnimation, _bubbleAnimation]),
                  builder: (context, child) {
                    final currentRadius = 150 * _breatheAnimation.value;
                    return CustomPaint(
                      painter: BubblePainter(
                        _bubbleAnimation.value,
                        currentRadius,
                        Theme.of(context).colorScheme.secondary, // Use a theme-aware color
                      ),
                      child: Container(
                        width: currentRadius * 2,
                        height: currentRadius * 2,
                        child: Center(
                          child: Text(
                            _instruction,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary, // Use onPrimary for text on primary-colored background
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 30,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onSelected: (String result) {
                if (result == 'close') {
                  Navigator.pop(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'close',
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double animationValue;
  final double radius;
  final Color bubbleColor;

  BubblePainter(this.animationValue, this.radius, this.bubbleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    Path path = Path();
    for (double i = 0; i < 2 * math.pi; i += 0.1) {
      // Combine multiple sine waves for less predictable distortion
      double distortion1 = math.sin(i * 3 + animationValue * 2 * math.pi) * (radius * 0.01);
      double distortion2 = math.sin(i * 7 + animationValue * 3 * math.pi + math.pi / 2) * (radius * 0.0075);

      double totalDistortion = distortion1 + distortion2;

      double x = center.dx + (radius + totalDistortion) * math.cos(i);
      double y = center.dy + (radius + totalDistortion) * math.sin(i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}