import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/app_badge.dart';
import '../../../../shared/components/app_button.dart';

class SmrStudentsScreen extends ConsumerStatefulWidget {
  const SmrStudentsScreen({super.key});

  @override
  ConsumerState<SmrStudentsScreen> createState() => _SmrStudentsScreenState();
}

class _SmrStudentsScreenState extends ConsumerState<SmrStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showAddStudentModal(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          children: [
            AppTextField(
              controller: _searchController,
              hintText: 'Search by name, email, or ID...',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSpacing.s24),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Mock data
                itemBuilder: (context, index) {
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            'S${index + 1}',
                            style: AppTypography.labelLarge.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student ${index + 1}',
                                style: AppTypography.titleMedium,
                              ),
                              Text(
                                'student${index + 1}@example.com',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        AppBadge(
                          text: index % 2 == 0 ? 'Active' : 'Pending',
                          variant: index % 2 == 0
                              ? AppBadgeVariant.success
                              : AppBadgeVariant.warning,
                        ),
                      ],
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

  void _showAddStudentModal(BuildContext context) {
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
                  Text('Add New Student', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              const AppTextField(
                labelText: 'Full Name',
                hintText: 'Enter student name',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.s16),
              const AppTextField(
                labelText: 'Email Address',
                hintText: 'student@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.s16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Assign Course',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Cisco CCNA')),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('AWS Solutions Architect'),
                  ),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: AppSpacing.s32),
              AppButton(
                text: 'Create Student Account',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student successfully created!'),
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
