import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/managers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../controllers/checkout_controller.dart';
import '../../../../core/di/service_locator.dart';

class CheckoutScreen extends ConsumerWidget {
  final String courseId;
  final String courseTitle;
  final double price;

  const CheckoutScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for payment completion/error
    ref.listen<AsyncValue<void>>(checkoutControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          // On success, go back to dashboard or course details
          if (context.canPop()) {
            context.pop(true); // Return true to indicate success
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    final checkoutState = ref.watch(checkoutControllerProvider);
    final currencyFormat = NumberFormat.simpleCurrency(
      name: 'INR',
    ); // Default to INR for Razorpay

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Item
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          courseTitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(price),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.md),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(price),
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Security Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Secure Payment by Razorpay',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Pay Button
            GradientButton(
              text: 'Pay ${currencyFormat.format(price)}',
              isLoading: checkoutState.isLoading,
              onPressed: () {
                final session = locator<SessionManager>();
                ref
                    .read(checkoutControllerProvider.notifier)
                    .startCheckout(
                      courseId: courseId,
                      price: price,
                      courseName: courseTitle,
                      userEmail: session.userEmail ?? 'user@example.com',
                    );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
