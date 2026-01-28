import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/exercise_screen.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:BreathSpace/rate_limiter.dart'; // Import the rate limiter

class ExerciseDetailScreen extends StatefulWidget {
  final BreathingExercise? exercise;
  final Future<BreathingExercise?> Function()? aiRecommendationCallback;

  const ExerciseDetailScreen({
    super.key,
    this.exercise,
    this.aiRecommendationCallback,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  ExerciseVersion _selectedVersion = ExerciseVersion.normal;
  BreathingExercise? _currentExercise;
  bool _isLoading = true;
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercise;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // If we have an AI callback, execute it to get the exercise
    if (widget.aiRecommendationCallback != null) {
      _fetchExerciseWithAi();
    } else {
      // If we already have an exercise, stop loading
      if (widget.exercise != null) {
        _isLoading = false;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _navigateDown();
          break;
        case LogicalKeyboardKey.arrowUp:
          _navigateUp();
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _selectCurrentItem();
          break;
        case LogicalKeyboardKey.escape:
          Navigator.of(context).pop();
          break;
        case LogicalKeyboardKey.digit1:
          _selectVersion(ExerciseVersion.short);
          break;
        case LogicalKeyboardKey.digit2:
          _selectVersion(ExerciseVersion.normal);
          break;
        case LogicalKeyboardKey.digit3:
          _selectVersion(ExerciseVersion.long);
          break;
      }
    }
  }

  void _navigateDown() {
    final totalItems = _getTotalItems();
    if (totalItems > 0) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % totalItems;
      });
    }
  }

  void _navigateUp() {
    final totalItems = _getTotalItems();
    if (totalItems > 0) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + totalItems) % totalItems;
      });
    }
  }

  int _getTotalItems() {
    if (_currentExercise?.versions != null) {
      return 1 + 3; // Start button + 3 version buttons
    }
    return 1; // Just start button
  }

  void _selectCurrentItem() {
    if (_selectedIndex == 0) {
      if (_currentExercise != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseScreen(
              exercise: _currentExercise!,
              selectedVersion: _selectedVersion,
            ),
          ),
        );
      }
    } else if (_currentExercise?.versions != null) {
      switch (_selectedIndex - 1) {
        case 0:
          _selectVersion(ExerciseVersion.short);
          break;
        case 1:
          _selectVersion(ExerciseVersion.normal);
          break;
        case 2:
          _selectVersion(ExerciseVersion.long);
          break;
      }
    }
  }

  void _selectVersion(ExerciseVersion version) {
    setState(() {
      _selectedVersion = version;
    });
  }

  Future<void> _fetchExerciseWithAi() async {
    try {
      final recommendedExercise = await widget.aiRecommendationCallback!();
      if (recommendedExercise != null) {
        setState(() {
          _currentExercise = recommendedExercise;
          _isLoading = false;
        });
      } else {
        // Check if the failure might be due to rate limiting
        final isLimited = await RateLimiter.isRateLimited();

        if (isLimited && !kDebugMode) {
          final stats = await RateLimiter.getRequestStats();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Daily limit reached. You have used ${stats['current']} of ${stats['max']} daily requests. Try again tomorrow.',
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Unable to connect to AI service. Please check your internet connection and try again.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }

        // Handle case where AI couldn't recommend an exercise
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error case
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exercise: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: _isLoading || _currentExercise == null
              ? Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  _currentExercise?.getLocalizedTitle(
                        AppLocalizations.of(context)!,
                      ) ??
                      'Loading...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                ).scaffoldBackgroundColor.withValues(alpha: 0.98),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _isLoading
                                ? null
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.08),
                                    ],
                                  ),
                            boxShadow: _isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                            color: _isLoading
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.1)
                                : null,
                          ),
                          child: _isLoading
                              ? null
                              : Icon(
                                  Icons.spa_outlined,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        const SizedBox(height: 32),
                        _isLoading || _currentExercise == null
                            ? Container(
                                width: 200,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                _currentExercise?.getLocalizedTitle(
                                      AppLocalizations.of(context)!,
                                    ) ??
                                    'Loading...',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 16),
                        _isLoading || _currentExercise == null
                            ? Container(
                                width: 250,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                _currentExercise?.getLocalizedIntro(
                                      AppLocalizations.of(context)!,
                                    ) ??
                                    'Loading introduction...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                  height: 1.5,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 40),

                        // Version selection buttons
                        if (!_isLoading &&
                            _currentExercise?.hasVersions == true) ...[
                          Text(
                            'Choose Duration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildVersionButton(
                                ExerciseVersion.short,
                                'Short',
                              ),
                              const SizedBox(width: 12),
                              _buildVersionButton(
                                ExerciseVersion.normal,
                                'Normal',
                              ),
                              const SizedBox(width: 12),
                              _buildVersionButton(ExerciseVersion.long, 'Long'),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ] else if (_isLoading) ...[
                          // Skeleton for version selection buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],

                        // Exercise details
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (_isLoading) ...[
                                // Skeleton for progressive exercise content
                                Container(
                                  width: 140,
                                  height: 20,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ] else if (_currentExercise?.hasStages == true ||
                                  _currentExercise?.getStagesForVersion(
                                        _selectedVersion,
                                      ) !=
                                      null) ...[
                                Text(
                                  'Progressive Exercise',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    letterSpacing: -0.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ...?(_currentExercise!
                                        .getStagesForVersion(_selectedVersion)
                                        ?.map(
                                          (stage) => Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    stage.getLocalizedTitle(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${stage.pattern} • ${_formatDuration(stage.duration)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ) ??
                                    _currentExercise?.stages?.map(
                                      (stage) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                stage.getLocalizedTitle(
                                                  AppLocalizations.of(context)!,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${stage.pattern} • ${_formatDuration(stage.duration)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ] else ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pattern,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentExercise?.getPatternForVersion(
                                            _selectedVersion,
                                          ) ??
                                          'Pattern not available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentExercise?.getDurationForVersion(
                                            _selectedVersion,
                                          ) ??
                                          'Duration not available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ), // Extra space before the fixed button
                      ],
                    ),
                  ),
                ),

                // Fixed start button at bottom
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _currentExercise != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ExerciseScreen(
                                          exercise: _currentExercise!,
                                          selectedVersion: _selectedVersion,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedIndex == 0 && _focusNode.hasFocus
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.8)
                                  : Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              side: _selectedIndex == 0 && _focusNode.hasFocus
                                  ? BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.5),
                                      width: 2,
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.start,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
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

  Widget _buildVersionButton(ExerciseVersion version, String label) {
    final versionIndex = _getVersionIndex(version);
    final isFocused =
        _selectedIndex == (versionIndex + 1) && _focusNode.hasFocus;

    if (_isLoading ||
        _currentExercise == null ||
        _currentExercise?.hasVersions != true) {
      // Return a disabled skeleton button when loading or if versions are not available
      return Expanded(
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    final isSelected = version == _selectedVersion;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedVersion = version;
          });
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isFocused
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isFocused
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
              width: isSelected || isFocused ? 2 : 1,
            ),
            boxShadow: isSelected || isFocused
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: isSelected ? 0.3 : 0.1,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      final minutes = seconds ~/ 60;
      return '$minutes min';
    }
  }

  int _getVersionIndex(ExerciseVersion version) {
    switch (version) {
      case ExerciseVersion.short:
        return 0;
      case ExerciseVersion.normal:
        return 1;
      case ExerciseVersion.long:
        return 2;
    }
  }
}
