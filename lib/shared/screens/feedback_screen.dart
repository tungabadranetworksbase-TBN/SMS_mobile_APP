import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../components/app_button.dart';

enum FeedbackType { success, error, warning, info }

class FeedbackScreen extends StatelessWidget {
  final FeedbackType type;
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool isFullScreen;

  const FeedbackScreen({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.isFullScreen = true,
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

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          // Icon with glow effect
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: AppSpacing.s80,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s40),
          
          // Title
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),
          
          // Message
          Text(
            message,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          
          // Actions
          AppButton(
            text: primaryButtonText,
            variant: type == FeedbackType.error ? AppButtonVariant.primary : AppButtonVariant.primary, 
            onPressed: onPrimaryPressed ?? () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
          if (secondaryButtonText != null) ...[
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              text: secondaryButtonText!,
              variant: AppButtonVariant.text,
              onPressed: onSecondaryPressed,
            ),
          ],
          const SizedBox(height: AppSpacing.s32),
        ],
      ),
    );

    if (!isFullScreen) {
      return content;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Force users to use the action buttons
      ),
      body: SafeArea(child: content),
    );
  }
}
