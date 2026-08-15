import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../controllers/assessment_controller.dart';

class QuizPlayerScreen extends ConsumerStatefulWidget {
  final String assessmentId;
  final String title;

  const QuizPlayerScreen({
    super.key,
    required this.assessmentId,
    required this.title,
  });

  @override
  ConsumerState<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends ConsumerState<QuizPlayerScreen> {
  int _currentIndex = 0;
  final Map<String, String> _answers = {};
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    if (_timer != null) return;
    _secondsRemaining = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    final success = await ref
        .read(assessmentControllerProvider.notifier)
        .submitAssessment(widget.assessmentId, _answers);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Submitted',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Your assessment has been submitted successfully.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to course
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
      );
    } else {
      // Check if it was an error or just queued offline
      final state = ref.read(assessmentControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit. Please try again.')),
        );
      } else {
        // Queued offline
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Offline Mode',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'You are offline. Your assessment has been saved and will sync automatically when you reconnect.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncAssessment = ref.watch(assessmentProvider(widget.assessmentId));
    final controllerState = ref.watch(assessmentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
        actions: [
          if (_secondsRemaining > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: asyncAssessment.when(
        data: (assessment) {
          if (assessment.questions.isEmpty) {
            return const Center(
              child: Text(
                'No questions available.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          // Start timer if not started
          _startTimer(assessment.durationMinutes);

          final question = assessment.questions[_currentIndex];
          final isLast = _currentIndex == assessment.questions.length - 1;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / assessment.questions.length,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Question Text
                Text(
                  'Question ${_currentIndex + 1} of ${assessment.questions.length}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  question.text,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Options
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected = _answers[question.id] == option;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _answers[question.id] = option;
                          });
                        },
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  option,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation Buttons
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentIndex--);
                          },
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        text: isLast ? 'Submit Quiz' : 'Next',
                        isLoading: controllerState.isLoading,
                        onPressed: () {
                          if (isLast) {
                            _submitQuiz();
                          } else {
                            setState(() => _currentIndex++);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load assessment',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
