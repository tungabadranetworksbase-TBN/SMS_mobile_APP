import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/services/dashboard_api_service.dart';

class SmrStudentsScreen extends ConsumerStatefulWidget {
  const SmrStudentsScreen({super.key});

  @override
  ConsumerState<SmrStudentsScreen> createState() => _SmrStudentsScreenState();
}

class _SmrStudentsScreenState extends ConsumerState<SmrStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // The roster is paged, so filtering locally would only ever search the
    // rows that happened to arrive. Send the query to the server instead,
    // debounced so typing does not fire a request per keystroke.
    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        ref.read(staffStudentQueryProvider.notifier).state =
            _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
                  if (rows.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }
                  // A full page almost certainly means there are more rows
                  // behind it. Say so rather than imply this is everyone.
                  final capped = rows.length >= kStaffPageSize;
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(staffStudentsProvider),
                    child: ListView.builder(
                      itemCount: rows.length + (capped ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == rows.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s16,
                            ),
                            child: Text(
                              'Showing the first ${rows.length}. '
                              'Search to narrow the list.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall,
                            ),
                          );
                        }
                        final row = rows[index];
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
