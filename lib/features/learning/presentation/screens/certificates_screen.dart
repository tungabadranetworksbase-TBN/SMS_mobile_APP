import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/managers/download_manager.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
import '../../controllers/certificates_controller.dart';
import '../../data/models/certificate_dto.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesState = ref.watch(certificatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(certificatesProvider.notifier).refresh(),
        child: certificatesState.when(
          data: (certificates) => _buildContent(context, certificates),
          loading: () => _buildLoading(),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.read(certificatesProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CertificateDto> certificates) {
    if (certificates.isEmpty) {
      return const Center(
        child: Text('No certificates earned yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        final date = DateTime.parse(cert.issueDate);

        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: AppSpacing.s32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.courseTitle,
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Issued: ${DateFormat.yMMMMd().format(date)}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Download Certificate',
                  icon: Icons.download_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () async {
                    final manager = locator<DownloadManager>();
                    final filename = '${cert.courseTitle.replaceAll(' ', '_')}_Certificate.pdf';
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting download...')),
                    );
                    
                    final file = await manager.downloadFile(cert.downloadUrl, filename);
                    
                    if (context.mounted) {
                      if (file != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Certificate downloaded to ${file.path}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to download certificate.')),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const ShimmerCard();
      },
    );
  }
}
