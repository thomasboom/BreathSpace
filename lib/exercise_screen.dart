import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:OpenBreath/l10n/app_localizations.dart';
import 'package:OpenBreath/data.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:OpenBreath/settings_provider.dart';
import 'package:provider/provider.dart';

class ExerciseScreen extends StatefulWidget {
  final BreathingExercise exercise;
  const ExerciseScreen({super.key, required this.exercise});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with TickerProviderStateMixin {
  bool _patternInvalid = false;
  late AnimationController _controller;
  late Animation<double> _breatheAnimation;
  late AnimationController _bubbleAnimationController;
  late Animation<double> _bubbleAnimation;
  String _instruction = '';
  int _currentCycle = 0;
  int _currentStageIndex = 0;
  late List<BreathingStage> _stages;
  late int _stageStartTime;

  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  List<int> _parsePattern(String pattern) {
    return pattern.split('-').map(int.parse).toList();
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize stages
    if (widget.exercise.hasStages) {
      _stages = widget.exercise.stages!;
    } else {
      // Create a single stage from the original exercise for backward compatibility
      _stages = [
        BreathingStage(
          title: widget.exercise.title,
          pattern: widget.exercise.pattern,
          duration: _parseDurationString(widget.exercise.duration),
        )
      ];
    }
    
    try {
      // Initialize controllers
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _bubbleAnimationController = AnimationController(vsync: this, duration: Duration.zero);
      
      _initializeStage(0);
    } catch (e) {
      setState(() {
        _patternInvalid = true;
      });
    }
  }

  void _initializeStage(int stageIndex) {
    _currentStageIndex = stageIndex;
    final stage = _stages[stageIndex];
    
    List<int> patternValues;
    try {
      patternValues = _parsePattern(stage.pattern);
      int inhale = patternValues[0];
      int hold1 = patternValues.length > 1 ? patternValues[1] : 0;
      int exhale = patternValues.length > 2 ? patternValues[2] : 0;
      int hold2 = patternValues.length > 3 ? patternValues[3] : 0;

      int totalDurationSeconds = inhale + hold1 + exhale + hold2;
      _stageStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Dispose of existing controllers if they exist
      _controller.dispose();
      _bubbleAnimationController.dispose();

      _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: totalDurationSeconds),
      );

      _bubbleAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);

      _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _bubbleAnimationController,
          curve: Curves.easeInOut,
        ),
      );

      List<TweenSequenceItem<double>> items = [];

      if (inhale > 0) {
        items.add(TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: inhale.toDouble()));
      }
      if (hold1 > 0) {
        items.add(TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: hold1.toDouble()));
      }
      if (exhale > 0) {
        items.add(TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: exhale.toDouble()));
      }
      if (hold2 > 0) {
        items.add(TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: hold2.toDouble()));
      }

      _breatheAnimation = TweenSequence<double>(items).animate(_controller);

      _startAnimation();
    } catch (e) {
      setState(() {
        _patternInvalid = true;
      });
    }
  }

  void _startAnimation() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final stage = _stages[_currentStageIndex];
    final patternValues = _parsePattern(stage.pattern);
    int inhale = patternValues[0];
    int hold1 = patternValues.length > 1 ? patternValues[1] : 0;
    int exhale = patternValues.length > 2 ? patternValues[2] : 0;
    int hold2 = patternValues.length > 3 ? patternValues[3] : 0;
    int totalDurationSeconds = inhale + hold1 + exhale + hold2;

    if (settings.musicMode != MusicMode.off) {
      String musicFile = '';
      if (settings.musicMode == MusicMode.nature) {
        musicFile = 'music/nature.mp3';
      } else if (settings.musicMode == MusicMode.lofi) {
        musicFile = 'music/lofi.mp3';
      }
      _musicPlayer.play(AssetSource(musicFile));
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    }

    _controller.repeat();
    _controller.addListener(() {
      double currentTime = _controller.value * totalDurationSeconds;

      setState(() {
        final l10n = AppLocalizations.of(context);
        if (currentTime >= 0 && currentTime < inhale) {
          _instruction = l10n.inhale;
          if (settings.soundEffectsEnabled) {
            _soundEffectPlayer.play(AssetSource('sounds/in.mp3'));
            _soundEffectPlayer.setPlaybackRate(1 / inhale);
          }
        } else if (hold1 > 0 && currentTime >= inhale && currentTime < (inhale + hold1)) {
          _instruction = l10n.hold;
          _soundEffectPlayer.stop();
        } else if (currentTime >= (inhale + hold1) && currentTime < (inhale + hold1 + exhale)) {
          _instruction = l10n.exhale;
          if (settings.soundEffectsEnabled) {
            _soundEffectPlayer.play(AssetSource('sounds/out.mp3'));
            _soundEffectPlayer.setPlaybackRate(1 / exhale);
          }
        } else if (hold2 > 0 && currentTime >= (inhale + hold1 + exhale) && currentTime <= totalDurationSeconds) {
          _instruction = l10n.hold;
          _soundEffectPlayer.stop();
        }
        HapticFeedback.lightImpact();
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentCycle++;
        
        // Check if we need to move to the next stage
        final elapsedSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - _stageStartTime;
        final stage = _stages[_currentStageIndex];
        
        if (elapsedSeconds >= stage.duration) {
          // Move to next stage or end exercise
          if (_currentStageIndex < _stages.length - 1) {
            _initializeStage(_currentStageIndex + 1);
            _currentCycle = 0;
          } else {
            // Exercise completed
            Navigator.pop(context);
          }
        }
      }
    });
  }

  int _parseDurationString(String duration) {
    // Parse duration string like "4 min" or "240 sec"
    if (duration.contains('min')) {
      final minutes = int.parse(duration.replaceAll(' min', ''));
      return minutes * 60;
    } else if (duration.contains('sec')) {
      return int.parse(duration.replaceAll(' sec', ''));
    } else {
      // Default to minutes if no unit specified
      final minutes = int.parse(duration.replaceAll(RegExp(r'[^0-9]'), ''));
      return minutes * 60;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubbleAnimationController.dispose();
    _soundEffectPlayer.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _patternInvalid
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ':-(',
                    style: TextStyle(fontSize: 64),
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context).exerciseInvalid,
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fixed size container for the bubble to prevent layout shifts
                      Container(
                        width: 300,
                        height: 300,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_breatheAnimation, _bubbleAnimation]),
                          builder: (context, child) {
                            final currentRadius = 150 * _breatheAnimation.value;
                            return CustomPaint(
                              painter: BubblePainter(
                                _bubbleAnimation.value,
                                currentRadius,
                                Theme.of(context).colorScheme.secondary,
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
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      // Display current stage information below the bubble
                      if (widget.exercise.hasStages) ...[
                        Text(
                          '${_stages[_currentStageIndex].title} (${_currentStageIndex + 1}/${_stages.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).pattern}: ${_stages[_currentStageIndex].pattern}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          '${AppLocalizations.of(context).pattern}: ${widget.exercise.pattern}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSelected: (String result) {
                      if (result == 'close') {
                        Navigator.pop(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'close',
                        child: Text(AppLocalizations.of(context).close),
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