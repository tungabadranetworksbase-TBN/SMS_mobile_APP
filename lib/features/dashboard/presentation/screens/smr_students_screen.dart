import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';

class SmrStudentsScreen extends ConsumerStatefulWidget {
  const SmrStudentsScreen({super.key});

  @override
  ConsumerState<SmrStudentsScreen> createState() => _SmrStudentsScreenState();
}

class _SmrStudentsScreenState extends ConsumerState<SmrStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          children: [
            AppTextField(
              controller: _searchController,
              hintText: 'Search by name or email',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSpacing.s24),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(staffStudentsProvider),
                ),
                data: (rows) {
                  final filtered = _query.isEmpty
                      ? rows
                      : rows
                            .where(
                              (r) =>
                                  r.name.toLowerCase().contains(_query) ||
                                  r.email.toLowerCase().contains(_query),
                            )
                            .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(staffStudentsProvider),
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final row = filtered[index];
                        return AppCard(
                          margin: const EdgeInsets.only(
                            bottom: AppSpacing.s12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  row.name.isEmpty
                                      ? '?'
                                      : row.name[0].toUpperCase(),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      row.name,
                                      style: AppTypography.titleMedium,
                                    ),
                                    Text(
                                      row.email,
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              AppBadge(
                                text: row.status,
                                variant: row.status == 'ACTIVE'
                                    ? AppBadgeVariant.success
                                    : AppBadgeVariant.warning,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
