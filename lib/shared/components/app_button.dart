import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;
    Gradient? gradient;

    switch (variant) {
      case AppButtonVariant.primary:
        gradient = onPressed == null ? null : AppColors.primaryGradient;
        backgroundColor = onPressed == null
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primary;
        foregroundColor = onPressed == null
            ? colorScheme.onSurfaceVariant
            : colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = onPressed == null
            ? colorScheme.surfaceContainerHighest
            : colorScheme.secondaryContainer;
        foregroundColor = onPressed == null
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSecondaryContainer;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = onPressed == null
            ? colorScheme.onSurfaceVariant
            : colorScheme.primary;
        borderSide = BorderSide(
          color: onPressed == null
              ? colorScheme.outlineVariant
              : colorScheme.primary,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = onPressed == null
            ? colorScheme.onSurfaceVariant
            : colorScheme.primary;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.roundedPill,
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        border: borderSide != null ? Border.all(color: borderSide.color) : null,
        boxShadow: (variant == AppButtonVariant.primary && onPressed != null)
            ? [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.roundedPill,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: AppSpacing.s20,
                    width: AppSpacing.s20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: foregroundColor, size: AppSpacing.s20),
                    const SizedBox(width: AppSpacing.s8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
