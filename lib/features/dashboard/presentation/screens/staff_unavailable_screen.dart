import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class FeatureUnavailableScreen extends StatelessWidget {
  final String message;

  const FeatureUnavailableScreen({
    super.key,
    this.message =
        'This feature is not available in the mobile app. Use the web console.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class StaffUnavailableScreen extends StatelessWidget {
  const StaffUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureUnavailableScreen(
      message:
          'This role is managed on the web console. Nothing to show here.',
    );
  }
}
