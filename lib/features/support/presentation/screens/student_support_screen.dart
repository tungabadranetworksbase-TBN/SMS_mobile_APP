import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_button.dart';

class StudentSupportScreen extends ConsumerWidget {
  const StudentSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hardcoded dummy data for now
    final tickets = [
      {
        'id': 'TKT-1042',
        'title': 'Cannot access Module 3 materials',
        'status': 'open',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'TKT-1021',
        'title': 'Payment confirmation missing',
        'status': 'pending',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'TKT-0985',
        'title': 'How to setup Python environment?',
        'status': 'resolved',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': 'TKT-0950',
        'title': 'Request for leave next week',
        'status': 'resolved',
        'date': DateTime.now().subtract(const Duration(days: 12)),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support & Help'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          'New Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tickets',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (tickets.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text('No support tickets yet.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tickets.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final status = ticket['status'] as String;

                  AppBadgeVariant badgeVariant;
                  if (status == 'open') {
                    badgeVariant =
                        AppBadgeVariant.error; // Red for open action needed
                  } else if (status == 'resolved') {
                    badgeVariant = AppBadgeVariant.success;
                  } else {
                    badgeVariant = AppBadgeVariant.warning;
                  }

                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket['id'] as String,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppBadge(
                              text: status.toUpperCase(),
                              variant: badgeVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ticket['title'] as String,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              DateFormat(
                                'MMM d, yyyy • h:mm a',
                              ).format(ticket['date'] as DateTime),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xxxl), // space for fab
          ],
        ),
      ),
    );
  }

  void _showCreateTicketModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.s24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.s24,
            right: AppSpacing.s24,
            top: AppSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Create New Ticket', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'technical',
                    child: Text('Technical Issue'),
                  ),
                  DropdownMenuItem(
                    value: 'billing',
                    child: Text('Billing / Payment'),
                  ),
                  DropdownMenuItem(
                    value: 'course',
                    child: Text('Course Content'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: AppSpacing.s16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Briefly describe the issue',
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide details about your problem...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              AppButton(
                text: 'Submit Ticket',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support ticket created successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        );
      },
    );
  }
}
