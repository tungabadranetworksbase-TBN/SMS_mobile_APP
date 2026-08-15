import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../data/models/profile_dto.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings screen
            },
          ),
        ],
      ),
      body: asyncProfile.when(
        data: (profile) => _buildProfile(context, ref, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load profile',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    WidgetRef ref,
    ProfileDto profile,
  ) {
    final dateFormat = DateFormat('MMMM yyyy');

    return RefreshIndicator(
      onRefresh: () => ref.refresh(profileProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.name.substring(0, 1).toUpperCase(),
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(RouteNames.editProfile, extra: profile);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name & Email
            Text(
              profile.name,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.email,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Badges / Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                profile.role.toUpperCase(),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Details section
            _buildDetailRow(
              Icons.phone_outlined,
              'Phone',
              profile.phone ?? 'Not provided',
            ),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Address',
              profile.address ?? 'Not provided',
            ),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Joined',
              dateFormat.format(profile.joinedAt),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: () {
                context.pushNamed(RouteNames.editProfile, extra: profile);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Logout Button
            GradientButton(
              text: 'Logout',
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primaryLight),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
