import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Funnel', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              child: Column(
                children: [
                  _buildFunnelRow('Total Leads', '1,245', colorScheme.primary),
                  const Divider(),
                  _buildFunnelRow(
                    'Contacted',
                    '830',
                    colorScheme.primary.withValues(alpha: 0.8),
                  ),
                  const Divider(),
                  _buildFunnelRow(
                    'Qualified',
                    '450',
                    colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const Divider(),
                  _buildFunnelRow(
                    'Enrolled',
                    '120',
                    const Color(0xFF10B981),
                  ), // Success green
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
            Text('Recent Enrollments', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.s16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(
                    'Student ${index + 1}',
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: const Text('Enrolled in Cisco CCNA'),
                  trailing: Text(
                    '₹15,000',
                    style: AppTypography.labelLarge.copyWith(
                      color: const Color(0xFF10B981),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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

  Future<void> _exportReport(BuildContext context) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating report...')));

      const csvData =
          'Metric,Value\n'
          'Total Leads,1245\n'
          'Contacted,830\n'
          'Qualified,450\n'
          'Enrolled,120\n';

      if (context.mounted) {
        await SharePlus.instance.share(
          ShareParams(text: csvData, subject: 'Analytics Report'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export report: $e')));
      }
    }
  }
}
