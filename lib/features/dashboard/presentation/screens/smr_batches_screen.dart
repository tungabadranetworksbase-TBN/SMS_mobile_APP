import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/services/dashboard_api_service.dart';

class SmrBatchesScreen extends ConsumerWidget {
  const SmrBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffBatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.invalidate(staffBatchesProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No batches found.'));
          }
          // A full page almost certainly means there are more behind it.
          final capped = rows.length >= kStaffPageSize;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(staffBatchesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: rows.length + (capped ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == rows.length) {
                  return Text(
                    'Showing the first ${rows.length} batches.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  );
                }
                final batch = rows[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              batch.name,
                              style: AppTypography.titleLarge,
                            ),
                          ),
                          AppBadge(
                            text: batch.status,
                            variant: AppBadgeVariant.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        batch.courseTitle,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        '${batch.memberCount} students · ${batch.trainerName}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
