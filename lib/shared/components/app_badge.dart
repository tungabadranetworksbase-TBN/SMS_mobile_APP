import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppBadgeVariant { success, warning, error, info, primary, outline }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppBadgeVariant.success:
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        foregroundColor = const Color(0xFF10B981);
        break;
      case AppBadgeVariant.warning:
        backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        foregroundColor = const Color(0xFFF59E0B);
        break;
      case AppBadgeVariant.error:
        backgroundColor = colorScheme.error.withValues(alpha: 0.1);
        foregroundColor = colorScheme.error;
        break;
      case AppBadgeVariant.info:
        backgroundColor = const Color(0xFF3B82F6).withValues(alpha: 0.1);
        foregroundColor = const Color(0xFF3B82F6);
        break;
      case AppBadgeVariant.primary:
        backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
        foregroundColor = colorScheme.primary;
        break;
      case AppBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurfaceVariant;
        borderSide = BorderSide(color: colorScheme.outlineVariant);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedPill,
        border: borderSide != null ? Border.all(color: borderSide.color) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
