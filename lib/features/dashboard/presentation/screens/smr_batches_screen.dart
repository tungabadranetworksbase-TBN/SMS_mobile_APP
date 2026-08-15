import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/app_button.dart';

class SmrBatchesScreen extends ConsumerWidget {
  const SmrBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Batches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateBatchModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: 3, // Mock data
        itemBuilder: (context, index) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Batch 2024-${String.fromCharCode(65 + index)}', style: AppTypography.titleLarge),
                    AppBadge(
                      text: index == 0 ? 'Completed' : 'In Progress',
                      variant: index == 0 ? AppBadgeVariant.success : AppBadgeVariant.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text('Advanced Networking & Security', style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded, size: AppSpacing.s20),
                        const SizedBox(width: AppSpacing.s8),
                        Text('${(index + 1) * 15} Students', style: AppTypography.labelMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateBatchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.s24)),
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
                  Text('Create New Batch', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              const AppTextField(
                labelText: 'Batch Name',
                hintText: 'e.g., Batch 2024-X',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: AppSpacing.s16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Cisco CCNA')),
                  DropdownMenuItem(value: '2', child: Text('AWS Solutions Architect')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: AppSpacing.s16),
              const AppTextField(
                labelText: 'Start Date',
                hintText: 'Tap to select date',
                prefixIcon: Icons.calendar_today_rounded,
                // In a real app, wrap with GestureDetector to show date picker
              ),
              const SizedBox(height: AppSpacing.s32),
              AppButton(
                text: 'Create Batch',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch successfully created!')),
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
