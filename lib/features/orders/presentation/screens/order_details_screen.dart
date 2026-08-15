import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/orders_controller.dart';
import '../../data/models/order_dto.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrder = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.surface,
      ),
      body: asyncOrder.when(
        data: (order) {
          final dateFormat = DateFormat('MMMM dd, yyyy - hh:mm a');
          final currencyFormat = NumberFormat.simpleCurrency(
            name: order.currency,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        order.displayId,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        order.status.toUpperCase(),
                        style: AppTypography.titleMedium.copyWith(
                          color: order.status == 'PAID'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Items List
                Text(
                  'Items',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...order.items.map(
                  (item) => _OrderItemRow(item: item, currency: order.currency),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Total
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(order.totalAmount),
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Receipt Download Button (If available)
                if (order.receiptUrl != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      // Trigger download manager for receiptUrl
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download Receipt'),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load details.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemDto item;
  final String currency;

  const _OrderItemRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(name: currency);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.type,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(item.price),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
