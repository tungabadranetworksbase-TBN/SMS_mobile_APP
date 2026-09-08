import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/models/crm_insights_dto.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(crmInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              final data = state.asData?.value;
              if (data != null) _exportReport(context, data);
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.invalidate(crmInsightsProvider),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(crmInsightsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales funnel', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: Column(
                      children: [
                        _buildFunnelRow(
                          'Total leads',
                          '${data.totalLeads}',
                          colorScheme.primary,
                        ),
                        const Divider(),
                        _buildFunnelRow(
                          'Converted',
                          '${data.convertedLeads}',
                          const Color(0xFF10B981),
                        ),
                        const Divider(),
                        _buildFunnelRow(
                          'Conversion',
                          '${data.conversionRatePct}%',
                          colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  Text('Pipeline', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: data.pipeline.isEmpty
                        ? const Text('No pipeline data.')
                        : Column(
                            children: [
                              for (final e in data.pipeline.entries) ...[
                                _buildFunnelRow(
                                  e.key,
                                  '${e.value}',
                                  colorScheme.primary,
                                ),
                                if (e.key != data.pipeline.keys.last)
                                  const Divider(),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  Text('Follow-ups', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  AppCard(
                    child: Column(
                      children: [
                        _buildFunnelRow(
                          'Pending',
                          '${data.pendingFollowUps}',
                          colorScheme.primary,
                        ),
                        const Divider(),
                        _buildFunnelRow(
                          'Overdue',
                          '${data.overdueFollowUps}',
                          const Color(0xFFEF4444),
                        ),
                        const Divider(),
                        _buildFunnelRow(
                          'Stuck records',
                          '${data.stuckRecords}',
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFunnelRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.s12),
              Text(label, style: AppTypography.bodyLarge),
            ],
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(
    BuildContext context,
    CrmInsightsDto data,
  ) async {
    final csv =
        'Metric,Value\n'
        'Total Leads,${data.totalLeads}\n'
        'Converted,${data.convertedLeads}\n'
        'Conversion %,${data.conversionRatePct}\n'
        'Pending follow-ups,${data.pendingFollowUps}\n'
        'Overdue,${data.overdueFollowUps}\n'
        'Stuck,${data.stuckRecords}\n';
    await SharePlus.instance.share(
      ShareParams(text: csv, subject: 'Analytics Report'),
    );
  }
}
