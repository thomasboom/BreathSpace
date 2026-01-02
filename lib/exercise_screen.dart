import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/exercise_finished_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'settings_screen.dart'; // Import settings screen

// Enum to track the current breathing phase
enum BreathingPhase { inhale, hold1, exhale, hold2 }

class ExerciseScreen extends StatefulWidget {
  final BreathingExercise exercise;
  final ExerciseVersion? selectedVersion;

  const ExerciseScreen({
    super.key,
    required this.exercise,
    this.selectedVersion,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with TickerProviderStateMixin {
  bool _patternInvalid = false;
  bool _exerciseCompleted = false; // Track if exercise completion has started
  late AnimationController _controller;
  late Animation<double> _breatheAnimation;
  late AnimationController _bubbleAnimationController;
  late Animation<double> _bubbleAnimation;
  String _instruction = '';
  // int _currentCycle = 0; // Unused field
  int _currentStageIndex = 0;
  late List<BreathingStage> _stages;
  late int _stageStartTime;
  bool _waitingForCycleCompletion =
      false; // Track if we're waiting for current cycle to complete before stage transition

  // Track when sound effects have been played to prevent repetition
  // bool _inhaleSoundPlayed = false; // Unused field
  // bool _exhaleSoundPlayed = false; // Unused field
  // bool _holdSoundPlayed = false; // Unused field
  String _lastInstruction = ''; // Track the previous instruction

  // Track the current phase for breathing method instructions
  BreathingPhase _currentPhase = BreathingPhase.inhale;

  // Track complete breathing cycles for instruction display
  int _breathingCycleCount = 0;

  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Store reference to settings provider for disposing the listener
  SettingsProvider? _settingsProvider;

  // Navigation guard to prevent multiple settings navigations
  bool _isNavigatingToSettings = false;

  // Initialize player modes for Android to allow simultaneous playback
  Future<void> _initPlayers() async {
    await _soundEffectPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
  }

  // Initialize all components in the correct order
  Future<void> _initializeComponents() async {
    try {
      await _initPlayers();
      _initializeStage(0);
    } catch (e) {
      setState(() {
        _patternInvalid = true;
      });
    }
  }

  // Keyboard navigation
  final FocusNode _focusNode = FocusNode();

  List<int> _parsePattern(String pattern) {
    return pattern.split('-').map(int.parse).toList();
  }

  Map<String, int> _getPatternTimings(List<int> patternValues) {
    int inhale = 0, hold1 = 0, exhale = 0, hold2 = 0;

    switch (patternValues.length) {
      case 1:
        inhale = patternValues[0];
        exhale = patternValues[0];
        break;
      case 2:
        inhale = patternValues[0];
        exhale = patternValues[1];
        break;
      case 3:
        inhale = patternValues[0];
        hold1 = patternValues[1];
        exhale = patternValues[2];
        break;
      case 4:
      default:
        inhale = patternValues[0];
        hold1 = patternValues[1];
        exhale = patternValues[2];
        hold2 = patternValues[3];
        break;
    }
    return {'inhale': inhale, 'hold1': hold1, 'exhale': exhale, 'hold2': hold2};
  }

  bool _isCurrentCycleComplete(double currentTime, Map<String, int> timings) {
    int inhale = timings['inhale']!;
    int hold1 = timings['hold1']!;
    int exhale = timings['exhale']!;
    int hold2 = timings['hold2']!;
    int totalCycleDuration = inhale + hold1 + exhale + hold2;

    // Check if we're at or past the end of the current cycle
    return currentTime >=
        totalCycleDuration - 0.1; // Small buffer for floating point precision
  }

  @override
  void initState() {
    super.initState();

    // Keep the screen awake during the exercise
    WakelockPlus.enable();

    // Hide the status bar during the exercise
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize stages based on selected version
    final selectedVersion = widget.selectedVersion ?? ExerciseVersion.normal;

    if (widget.exercise.hasStages ||
        widget.exercise.getStagesForVersion(selectedVersion) != null) {
      _stages =
          widget.exercise.getStagesForVersion(selectedVersion) ??
          widget.exercise.stages!;
    } else {
      // Create a single stage from the original exercise for backward compatibility
      _stages = [
        BreathingStage(
          title: widget.exercise.title,
          pattern: widget.exercise.getPatternForVersion(selectedVersion),
          duration: _parseDurationString(
            widget.exercise.getDurationForVersion(selectedVersion),
          ),
          inhaleMethod: widget.exercise.inhaleMethod,
          exhaleMethod: widget.exercise.exhaleMethod,
        ),
      ];
    }

    try {
      // Initialize controllers
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _bubbleAnimationController = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
    } catch (e) {
      setState(() {
        _patternInvalid = true;
      });
    }

    // Listen for settings changes to immediately apply music changes
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider!.addListener(_handleSettingsChange);

    // Setup keyboard focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Initialize player modes for simultaneous playback on Android, then start stage
    _initializeComponents();
  }

  // Handle settings changes to immediately apply music changes
  void _handleSettingsChange() {
    // Only handle music mode changes
    _updateMusicPlayback(_settingsProvider!.musicMode);
  }

  // Update music playback based on the new music mode
  Future<void> _updateMusicPlayback(MusicMode newMusicMode) async {
    // Stop current music if playing
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(1.0);

    // Start new music if not off
    if (newMusicMode != MusicMode.off) {
      String musicFile = '';
      if (newMusicMode == MusicMode.nature) {
        musicFile = 'music/nature.mp3';
      } else if (newMusicMode == MusicMode.lofi) {
        musicFile = 'music/lofi.mp3';
      } else if (newMusicMode == MusicMode.piano) {
        musicFile = 'music/piano.mp3';
      }
      await _musicPlayer.play(AssetSource(musicFile));
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    }
  }

  void _initializeStage(int stageIndex) {
    _currentStageIndex = stageIndex;
    final stage = _stages[stageIndex];

    // Reset sound tracking variables for new stage
    _lastInstruction = '';
    _waitingForCycleCompletion =
        false; // Reset cycle completion flag for new stage

    // Reset breathing cycle count for new stage
    _breathingCycleCount = 0;

    List<int> patternValues;
    try {
      patternValues = _parsePattern(stage.pattern);
      final timings = _getPatternTimings(patternValues);
      int inhale = timings['inhale']!;
      int hold1 = timings['hold1']!;
      int exhale = timings['exhale']!;
      int hold2 = timings['hold2']!;

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
        items.add(
          TweenSequenceItem(
            tween: Tween(
              begin: 0.5,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: inhale.toDouble(),
          ),
        );
      }
      if (hold1 > 0) {
        items.add(
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: hold1.toDouble(),
          ),
        );
      }
      if (exhale > 0) {
        items.add(
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 0.5,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: exhale.toDouble(),
          ),
        );
      }
      if (hold2 > 0) {
        items.add(
          TweenSequenceItem(
            tween: Tween(
              begin: 0.5,
              end: 0.5,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: hold2.toDouble(),
          ),
        );
      }

      _breatheAnimation = TweenSequence<double>(items).animate(_controller);

      _startAnimation();
    } catch (e) {
      setState(() {
        _patternInvalid = true;
      });
    }
  }

  void _startAnimation() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final stage = _stages[_currentStageIndex];
    final patternValues = _parsePattern(stage.pattern);
    final timings = _getPatternTimings(patternValues);
    int inhale = timings['inhale']!;
    int hold1 = timings['hold1']!;
    int exhale = timings['exhale']!;
    int hold2 = timings['hold2']!;
    int totalDurationSeconds = inhale + hold1 + exhale + hold2;

    // Reset sound tracking variables for new animation cycle
    _lastInstruction = '';
    _waitingForCycleCompletion =
        false; // Reset cycle completion flag for new animation cycle
    _breathingCycleCount =
        0; // Reset breathing cycle count for new animation cycle

    if (settings.musicMode != MusicMode.off) {
      String musicFile = '';
      if (settings.musicMode == MusicMode.nature) {
        musicFile = 'music/nature.mp3';
      } else if (settings.musicMode == MusicMode.lofi) {
        musicFile = 'music/lofi.mp3';
      } else if (settings.musicMode == MusicMode.piano) {
        musicFile = 'music/piano.mp3';
      }
      await _musicPlayer.play(AssetSource(musicFile));
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    }

    _controller.repeat();
    _controller.addListener(() {
      double currentTime = _controller.value * totalDurationSeconds;

      // Check if we need to move to the next stage (moved from addStatusListener)
      final elapsedSeconds =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) - _stageStartTime;
      final currentStage = _stages[_currentStageIndex];

      if (elapsedSeconds >= currentStage.duration) {
        // Stage time is up - check if we need to wait for cycle completion
        if (!_waitingForCycleCompletion) {
          // We're not waiting yet - check if cycle is complete
          if (_isCurrentCycleComplete(currentTime, timings)) {
            // Cycle is complete - transition immediately
            if (_currentStageIndex < _stages.length - 1) {
              _initializeStage(_currentStageIndex + 1);
              return; // Exit early to avoid processing instruction for the old stage
            } else {
              // Exercise completed - fade out music before navigating away
              _onExerciseComplete();
              return; // Exit early
            }
          } else {
            // Cycle is not complete - start waiting for cycle completion
            _waitingForCycleCompletion = true;
          }
        } else {
          // We're waiting for cycle completion - check if it's now complete
          if (_isCurrentCycleComplete(currentTime, timings)) {
            // Cycle is now complete - transition to next stage
            _waitingForCycleCompletion = false;
            if (_currentStageIndex < _stages.length - 1) {
              _initializeStage(_currentStageIndex + 1);
              return; // Exit early to avoid processing instruction for the old stage
            } else {
              // Exercise completed - fade out music before navigating away
              _onExerciseComplete();
              return; // Exit early
            }
          }
          // If we're waiting but cycle is not complete yet, do nothing and continue waiting
        }
      }

      setState(() {
        final l10n = AppLocalizations.of(context);
        BreathingPhase newPhase =
            _currentPhase; // Track what the new phase will be

        if (currentTime >= 0 && currentTime < inhale) {
          _instruction = l10n.inhale;
          newPhase = BreathingPhase.inhale;
          // Play sound effect only once when entering inhale phase
          if (settings.voiceGuideMode == VoiceGuideMode.thomas &&
              _lastInstruction != _instruction) {
            _soundEffectPlayer.play(AssetSource('sounds/in.wav'));
          }
        } else if (hold1 > 0 &&
            currentTime >= inhale &&
            currentTime < (inhale + hold1)) {
          _instruction = 'Hold';
          newPhase = BreathingPhase.hold1;
          // Play sound effect only once when entering first hold phase
          if (settings.voiceGuideMode == VoiceGuideMode.thomas &&
              _lastInstruction != _instruction) {
            _soundEffectPlayer.play(AssetSource('sounds/hold.wav'));
          }
        } else if (currentTime >= (inhale + hold1) &&
            currentTime < (inhale + hold1 + exhale)) {
          _instruction = l10n.exhale;
          newPhase = BreathingPhase.exhale;
          // Play sound effect only once when entering exhale phase
          if (settings.voiceGuideMode == VoiceGuideMode.thomas &&
              _lastInstruction != _instruction) {
            _soundEffectPlayer.play(AssetSource('sounds/out.wav'));
          }
        } else if (hold2 > 0 &&
            currentTime >= (inhale + hold1 + exhale) &&
            currentTime <= totalDurationSeconds) {
          _instruction = 'Hold';
          newPhase = BreathingPhase.hold2;
          // Play sound effect only once when entering second hold phase
          if (settings.voiceGuideMode == VoiceGuideMode.thomas &&
              _lastInstruction != _instruction) {
            _soundEffectPlayer.play(AssetSource('sounds/hold.wav'));
          }
        }

        // Check if this is a new phase and handle breathing cycle counting
        if (newPhase != _currentPhase) {
          // Increment breathing cycle count when we transition back to inhale (start of new cycle)
          if (newPhase == BreathingPhase.inhale &&
              _currentPhase != BreathingPhase.inhale) {
            _breathingCycleCount++;
          }
          _currentPhase = newPhase;
        }

        // Update last instruction
        _lastInstruction = _instruction;

        HapticFeedback.lightImpact();
      });
    });

    // Removed the addStatusListener that was checking for stage transitions
  }

  // Method to handle exercise completion with smooth music fade out
  Future<void> _onExerciseComplete() async {
    // Prevent multiple calls to exercise completion
    if (_exerciseCompleted) return;
    _exerciseCompleted = true;

    // Fade out music before navigating away
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.musicMode != MusicMode.off) {
      await _fadeOutMusic();
    }

    // Navigate back after fade out is complete
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ExerciseFinishedScreen()),
      );
    }
  }

  // Method to handle exercise completion with immediate stop (hardcut)
  Future<void> _onExerciseCompleteHardCut() async {
    // Prevent multiple calls to exercise completion
    if (_exerciseCompleted) return;
    _exerciseCompleted = true;

    // Immediately stop music without fade out for hardcut
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(1.0);

    // Navigate back immediately without fade out
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ExerciseFinishedScreen()),
      );
    }
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
    _soundEffectPlayer.stop();
    _soundEffectPlayer.dispose();
    _musicPlayer.dispose();
    _focusNode.dispose();
    // Remove settings listener
    _settingsProvider?.removeListener(_handleSettingsChange);
    // Disable wakelock when exercise is finished
    WakelockPlus.disable();
    // Restore the status bar when exercise is finished
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
          _stopExercise();
          break;
        case LogicalKeyboardKey.keyP:
          _togglePlayPause();
          break;
        case LogicalKeyboardKey.keyR:
          _restartExercise();
          break;
        case LogicalKeyboardKey.keyM:
          _toggleMusic();
          break;
        case LogicalKeyboardKey.keyS:
          _openSettings();
          break;
      }
    }
  }

  void _togglePlayPause() {
    // Handle play/pause logic
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      _controller.forward();
    }
  }

  void _restartExercise() {
    // Restart current exercise
    setState(() {
      _currentStageIndex = 0;
      _breathingCycleCount = 0;
      _exerciseCompleted = false;
    });
    _initializeStage(0);
  }

  void _toggleMusic() {
    // Toggle music playback
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    // Cycle through music modes
    final currentMode = settingsProvider.musicMode;
    MusicMode nextMode;
    switch (currentMode) {
      case MusicMode.off:
        nextMode = MusicMode.nature;
        break;
      case MusicMode.nature:
        nextMode = MusicMode.lofi;
        break;
      case MusicMode.lofi:
        nextMode = MusicMode.piano;
        break;
      case MusicMode.piano:
        nextMode = MusicMode.off;
        break;
    }
    settingsProvider.setMusicMode(nextMode);
  }

  void _stopExercise() {
    // Navigate back to stop exercise
    Navigator.of(context).pop();
  }

  void _openSettings() {
    // Open settings screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(fromExercise: true),
      ),
    );
  }

  // Method to fade out music smoothly
  Future<void> _fadeOutMusic() async {
    const steps = 50; // More steps for smoother fade over longer duration
    final stepDuration =
        const Duration(milliseconds: 5000) ~/ steps; // 5 seconds fade out

    double currentVolume = 1.0;
    final stepDecrement = 1.0 / steps;

    for (int i = 0; i < steps; i++) {
      currentVolume -= stepDecrement;
      await _musicPlayer.setVolume(math.max(0.0, currentVolume));
      if (i < steps - 1) {
        // Don't delay after the last step
        await Future.delayed(stepDuration);
      }
    }

    // Ensure music is completely stopped and volume is reset
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(1.0);
  }

  // Method to build breathing method instruction text
  Widget _buildBreathingMethodInstruction(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? instructionText;

    // Get the current stage for breathing method information
    final currentStage = _stages[_currentStageIndex];

    // Show breathing method instructions only for the first two complete breathing cycles
    if (_breathingCycleCount < 2) {
      if (_currentPhase == BreathingPhase.inhale) {
        // Inhale phase - show inhale method
        if (currentStage.inhaleMethod != null) {
          if (currentStage.inhaleMethod == 'nose') {
            instructionText = '${l10n.inhale} ${l10n.throughNose}';
          } else if (currentStage.inhaleMethod == 'mouth') {
            instructionText = '${l10n.inhale} ${l10n.throughMouth}';
          }
        }
      } else if (_currentPhase == BreathingPhase.exhale) {
        // Exhale phase - show exhale method
        if (currentStage.exhaleMethod != null) {
          if (currentStage.exhaleMethod == 'nose') {
            instructionText = '${l10n.exhale} ${l10n.throughNose}';
          } else if (currentStage.exhaleMethod == 'mouth') {
            instructionText = '${l10n.exhale} ${l10n.throughMouth}';
          }
        }
      } else if (_currentPhase == BreathingPhase.hold1 ||
          _currentPhase == BreathingPhase.hold2) {
        // Hold phase - show "Hold calmly" instruction
        instructionText = l10n.hold;
      }
    }

    // Only show the instruction if we have text to display
    if (instructionText != null) {
      return Text(
        instructionText,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 20, // Reduced font size
        ),
        textAlign: TextAlign.center,
      );
    }

    // Return empty container if no instruction to show
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
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
          child: _patternInvalid
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                              Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).exerciseInvalid,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Enhanced breathing bubble
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor
                                        .withValues(alpha: 0.1),
                                    Theme.of(context).scaffoldBackgroundColor
                                        .withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: AnimatedBuilder(
                                animation: Listenable.merge([
                                  _breatheAnimation,
                                  _bubbleAnimation,
                                ]),
                                builder: (context, child) {
                                  final currentRadius =
                                      140 * _breatheAnimation.value;
                                  return CustomPaint(
                                    painter: BubblePainter(
                                      _bubbleAnimation.value,
                                      currentRadius,
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    child: SizedBox(
                                      width: currentRadius * 2,
                                      height: currentRadius * 2,
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _instruction,
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w300,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Breathing method instructions
                            _buildBreathingMethodInstruction(context),
                          ],
                        ),
                      ),
                      // Add swipe detection area for settings
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            // Detect right-to-left swipe
                            if (details.delta.dx < 0) {
                              // Swiping left
                              // Only navigate if the swipe is significant enough and not already navigating
                              if (details.delta.dx < -5 &&
                                  !_isNavigatingToSettings) {
                                _isNavigatingToSettings = true;
                                Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => SettingsScreen(
                                              fromExercise: true,
                                            ),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              // Hard cut transition - instant appearance without animation
                                              return child;
                                            },
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    )
                                    .then((value) {
                                      // If settings return with instruction to stop exercise, handle it
                                      if (value == 'stop_exercise') {
                                        _onExerciseComplete();
                                      } else if (value ==
                                          'stop_exercise_hardcut') {
                                        // Hard cut stop - immediately stop everything without fade
                                        _onExerciseCompleteHardCut();
                                      }
                                      // Reset navigation guard
                                      if (mounted) {
                                        setState(() {
                                          _isNavigatingToSettings = false;
                                        });
                                      }
                                    })
                                    .catchError((error, stackTrace) {
                                      // Reset navigation guard on error
                                      if (mounted) {
                                        setState(() {
                                          _isNavigatingToSettings = false;
                                        });
                                      }
                                    });
                              }
                            }
                          },
                          child: Container(
                            // Transparent container to capture gestures
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
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
      double distortion1 =
          math.sin(i * 3 + animationValue * 2 * math.pi) * (radius * 0.01);
      double distortion2 =
          math.sin(i * 7 + animationValue * 3 * math.pi + math.pi / 2) *
          (radius * 0.0075);

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
