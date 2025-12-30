import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BreathSpace/widgets/kids_bubble_widget.dart';
import 'package:BreathSpace/widgets/emotion_selector_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:BreathSpace/kids_mode_selection_screen.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';

// Enum to track the current breathing phase
enum BreathingPhase { inhale, hold1, exhale, hold2 }

class KidsModeExerciseScreen extends StatefulWidget {
  final Emotion emotion;

  const KidsModeExerciseScreen({super.key, required this.emotion});

  @override
  State<KidsModeExerciseScreen> createState() => _KidsModeExerciseScreenState();
}

class _KidsModeExerciseScreenState extends State<KidsModeExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _completionController;
  late Animation<double> _completionAnimation;

  BreathingPhase _currentPhase = BreathingPhase.inhale;
  String _instruction = "";
  bool _isCompleted = false;
  int _breathingCycleCount = 0;
  final int _totalCycles = 5; // 5 complete breathing cycles for kids

  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  String _lastInstruction = '';

  // Simple 4-4-4-4 pattern for kids (easier to follow)
  static const int _inhaleTime = 4;
  static const int _hold1Time = 4;
  static const int _exhaleTime = 4;
  static const int _hold2Time = 4;
  static const int _totalCycleTime =
      _inhaleTime + _hold1Time + _exhaleTime + _hold2Time;

  @override
  void initState() {
    super.initState();

    // Keep the screen awake during the exercise
    WakelockPlus.enable();

    // Hide the status bar during the exercise
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize animations
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalCycleTime),
    );

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _completionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.elasticOut),
    );

    // Start the breathing exercise after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startBreathingExercise();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_instruction.isEmpty) {
      _instruction = AppLocalizations.of(context).kidsGetReady;
    }
  }

  void _startBreathingExercise() {
    _breathingController.repeat();
    _breathingController.addListener(_updateBreathingPhase);
  }

  double _getCurrentBreathingScale() {
    final currentTime = _breathingController.value * _totalCycleTime;

    if (currentTime >= 0 && currentTime < _inhaleTime) {
      // Inhale - expand from 0.8 to 1.3
      final progress = currentTime / _inhaleTime;
      return 0.8 + (0.5 * progress);
    } else if (currentTime >= _inhaleTime &&
        currentTime < (_inhaleTime + _hold1Time)) {
      // Hold1 - stay at 1.3
      return 1.3;
    } else if (currentTime >= (_inhaleTime + _hold1Time) &&
        currentTime < (_inhaleTime + _hold1Time + _exhaleTime)) {
      // Exhale - contract from 1.3 to 0.8
      final progress = (currentTime - _inhaleTime - _hold1Time) / _exhaleTime;
      return 1.3 - (0.5 * progress);
    } else {
      // Hold2 - stay at 0.8
      return 0.8;
    }
  }

  void _updateBreathingPhase() {
    if (_isCompleted) return;

    final currentTime = _breathingController.value * _totalCycleTime;
    String newInstruction = '';
    BreathingPhase newPhase = _currentPhase;
    final l10n = AppLocalizations.of(context);

    if (currentTime >= 0 && currentTime < _inhaleTime) {
      newInstruction = l10n.kidsBreatheIn;
      newPhase = BreathingPhase.inhale;
      // Play sound effect only once when entering inhale phase
      if (_lastInstruction != newInstruction) {
        _playInhaleSound();
      }
    } else if (currentTime >= _inhaleTime &&
        currentTime < (_inhaleTime + _hold1Time)) {
      newInstruction = l10n.kidsHoldBreath;
      newPhase = BreathingPhase.hold1;
      // Play sound effect only once when entering hold1 phase
      if (_lastInstruction != newInstruction) {
        _playHoldSound();
      }
    } else if (currentTime >= (_inhaleTime + _hold1Time) &&
        currentTime < (_inhaleTime + _hold1Time + _exhaleTime)) {
      newInstruction = l10n.kidsBreatheOut;
      newPhase = BreathingPhase.exhale;
      // Play sound effect only once when entering exhale phase
      if (_lastInstruction != newInstruction) {
        _playExhaleSound();
      }
    } else if (currentTime >= (_inhaleTime + _hold1Time + _exhaleTime)) {
      newInstruction = l10n.kidsHold;
      newPhase = BreathingPhase.hold2;
      // Play sound effect only once when entering hold2 phase
      if (_lastInstruction != newInstruction) {
        _playHoldSound();
      }
    }

    // Check for phase transition to count cycles
    if (newPhase != _currentPhase) {
      if (newPhase == BreathingPhase.inhale &&
          _currentPhase != BreathingPhase.inhale) {
        _breathingCycleCount++;

        // Check if exercise is completed
        if (_breathingCycleCount >= _totalCycles) {
          _onExerciseComplete();
          return; // Don't update instruction if completing
        }
      }
      _currentPhase = newPhase;
    }

    _lastInstruction = newInstruction;

    if (mounted && !_isCompleted) {
      setState(() {
        _instruction = newInstruction;
      });
    }
  }

  void _playInhaleSound() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.soundEffectsEnabled) {
      _soundEffectPlayer.play(AssetSource('sounds/in.wav'));
    }
  }

  void _playExhaleSound() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.soundEffectsEnabled) {
      _soundEffectPlayer.play(AssetSource('sounds/out.wav'));
    }
  }

  void _playHoldSound() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.soundEffectsEnabled) {
      _soundEffectPlayer.play(AssetSource('sounds/in.wav'));
    }
  }

  void _onExerciseComplete() {
    if (_isCompleted) return;

    _isCompleted = true;
    _breathingController.stop();
    _completionController.forward();

    final l10n = AppLocalizations.of(context);
    setState(() {
      _instruction = l10n.kidsExerciseFinished;
    });

    // Play celebration sound if enabled
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.soundEffectsEnabled) {
      // You could add a celebration sound here
    }
  }

  void _onContinuePressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const KidsModeSelectionScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _completionController.dispose();
    _soundEffectPlayer.dispose();

    // Disable wakelock when exercise is finished
    WakelockPlus.disable();
    // Restore the status bar when exercise is finished
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
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
              widget.emotion.color.withValues(alpha: 0.3),
              widget.emotion.color.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header - no back button in kids mode
              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing bubble with face and speech
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            return KidsBubbleWidget(
                              speechText: _instruction,
                              size: 200,
                              bubbleColor: widget.emotion.color,
                              isAnimating:
                                  false, // We control animation externally
                              showFace: true,
                              breathingScale: _isCompleted
                                  ? 1.0
                                  : _getCurrentBreathingScale(),
                            );
                          },
                        ),
                      ),
                    ),

                    // Progress indicator at bottom
                    if (!_isCompleted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context).kidsBreaths,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: widget.emotion.color,
                                ),
                              ),
                              ...List.generate(_totalCycles, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index < _breathingCycleCount
                                        ? widget.emotion.color
                                        : Colors.grey.shade300,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                    // Continue button after completion
                    if (_isCompleted) ...[
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _completionAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _completionAnimation.value,
                            child: Container(
                              width: 200,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.emotion.color,
                                    widget.emotion.color.withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.emotion.color.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 3,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: _onContinuePressed,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context).kidsContinue,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
