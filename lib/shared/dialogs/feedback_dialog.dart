import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../components/app_button.dart';
import '../screens/feedback_screen.dart';

class FeedbackDialog extends StatelessWidget {
  final FeedbackType type;
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  const FeedbackDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.onPrimaryPressed,
  });

  IconData _getIcon() {
    switch (type) {
      case FeedbackType.success:
        return AppIcons.success;
      case FeedbackType.error:
        return AppIcons.error;
      case FeedbackType.warning:
        return AppIcons.warning;
      case FeedbackType.info:
        return AppIcons.info;
    }
  }

  Color _getColor(ColorScheme colorScheme) {
    switch (type) {
      case FeedbackType.success:
        return const Color(0xFF10B981);
      case FeedbackType.error:
        return colorScheme.error;
      case FeedbackType.warning:
        return const Color(0xFFF59E0B);
      case FeedbackType.info:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _getColor(colorScheme);

    return Dialog(
      backgroundColor: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  size: AppSpacing.s48,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s32),
            AppButton(
              text: primaryButtonText,
              onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
