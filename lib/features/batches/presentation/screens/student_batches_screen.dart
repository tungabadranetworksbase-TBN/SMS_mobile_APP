import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/batches_controller.dart';
import '../../data/models/batch_dto.dart';

class StudentBatchesScreen extends ConsumerStatefulWidget {
  const StudentBatchesScreen({super.key});

  @override
  ConsumerState<StudentBatchesScreen> createState() =>
      _StudentBatchesScreenState();
}

class _StudentBatchesScreenState extends ConsumerState<StudentBatchesScreen> {
  /// Id of the batch whose join is in flight, so only its button spins.
  String? _joiningId;

  Future<void> _join(BatchDto batch) async {
    setState(() => _joiningId = batch.id);
    try {
      await joinBatch(ref, batch.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${batch.name}.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _joiningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = ref.watch(myBatchesProvider);
    final available = ref.watch(availableBatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBatchesProvider);
          ref.invalidate(availableBatchesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            _Section(
              title: 'My batches',
              state: mine,
              onRetry: () => ref.invalidate(myBatchesProvider),
              emptyMessage: 'You have not joined a batch yet.',
              builder: (batch) => _BatchCard(batch: batch),
            ),
            const SizedBox(height: AppSpacing.s24),
            _Section(
              title: 'Available to join',
              state: available,
              onRetry: () => ref.invalidate(availableBatchesProvider),
              emptyMessage: 'No batches are open for enrolment.',
              builder: (batch) => _BatchCard(
                batch: batch,
                action: AppButton(
                  text: 'Join',
                  isLoading: _joiningId == batch.id,
                  onPressed: _joiningId == null ? () => _join(batch) : null,
                  variant: AppButtonVariant.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AsyncValue<List<BatchDto>> state;
  final VoidCallback onRetry;
  final String emptyMessage;
  final Widget Function(BatchDto) builder;

  const _Section({
    required this.title,
    required this.state,
    required this.onRetry,
    required this.emptyMessage,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.s12),
        state.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) =>
              ErrorStateView(message: error.toString(), onRetry: onRetry),
          data: (batches) {
            if (batches.isEmpty) {
              return Text(emptyMessage, style: AppTypography.bodyMedium);
            }
            return Column(children: batches.map(builder).toList());
          },
        ),
      ],
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchDto batch;
  final Widget? action;

  const _BatchCard({required this.batch, this.action});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(batch.name, style: AppTypography.titleLarge),
              ),
              if (batch.status.isNotEmpty)
                AppBadge(
                  text: batch.status,
                  variant: AppBadgeVariant.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(batch.courseTitle, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '${batch.memberCount} students · ${batch.trainerName}',
            style: AppTypography.bodySmall,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Align(alignment: Alignment.centerRight, child: action!),
          ],
        ],
      ),
    );
  }
}
