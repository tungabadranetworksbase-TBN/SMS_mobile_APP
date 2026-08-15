import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/managers/session_manager.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/models/smr_dashboard_dto.dart';
import 'package:intl/intl.dart';

class SmrDashboardScreen extends ConsumerWidget {
  const SmrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(smrDashboardProvider);
    final user = locator<SessionManager>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(smrDashboardProvider.notifier).refresh(),
          color: AppColors.primary,
          child: dashboardState.when(
            data: (data) => _buildContent(context, user, data),
            loading: () => _buildLoading(),
            error: (error, _) => ErrorStateView(
              message: error.toString(),
              onRetry: () => ref.read(smrDashboardProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SessionManager user,
    SmrDashboardDto data,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          const SizedBox(height: AppSpacing.xl),
          _buildHeroStats(data.stats),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Active Batches Overview'),
          const SizedBox(height: AppSpacing.md),
          _buildActiveBatches(data.activeBatches),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: AppSpacing.md),
          _buildRecentActivity(data.recentActivities),
        ],
      ),
    );
  }

  Widget _buildHeader(SessionManager user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.userName?.split(' ').first ?? 'Manager'} 👋',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'SMR Dashboard',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceContainer,
          backgroundImage: user.userAvatar != null
              ? NetworkImage(user.userAvatar!)
              : null,
          child: user.userAvatar == null
              ? const Icon(Icons.person_rounded, color: AppColors.textMuted)
              : null,
        ),
      ],
    );
  }

  Widget _buildHeroStats(SmrStatsDto stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Students',
          value: '${stats.totalStudents}',
          icon: Icons.people_alt_rounded,
          color: AppColors.info,
        ),
        _StatCard(
          title: 'Active Batches',
          value: '${stats.activeBatches}',
          icon: Icons.class_rounded,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Today\'s Attendance',
          value: '${stats.todayAttendance}',
          icon: Icons.fact_check_rounded,
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Pending Tickets',
          value: '${stats.pendingTickets}',
          icon: Icons.support_agent_rounded,
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildActiveBatches(List<ActiveBatchDto> batches) {
    if (batches.isEmpty) {
      return const _EmptyCard(message: 'No active batches assigned.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: batches.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final batch = batches[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    batch.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      '${batch.studentCount} Students',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Trainer: ${batch.trainerName}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: batch.progress,
                      backgroundColor: AppColors.surfaceContainer,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(batch.progress * 100).toInt()}%',
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
    );
  }

  Widget _buildRecentActivity(List<RecentActivityDto> activities) {
    if (activities.isEmpty) {
      return const _EmptyCard(message: 'No recent activity.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (_, __) =>
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      itemBuilder: (context, index) {
        final activity = activities[index];

        IconData icon;
        Color color;

        switch (activity.type) {
          case 'ticket':
            icon = Icons.support_agent_rounded;
            color = AppColors.warning;
            break;
          case 'attendance':
            icon = Icons.fact_check_rounded;
            color = AppColors.success;
            break;
          case 'enrollment':
            icon = Icons.person_add_rounded;
            color = AppColors.info;
            break;
          default:
            icon = Icons.notifications_rounded;
            color = AppColors.primary;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      DateFormat.yMMMd().add_jm().format(activity.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 150, height: 28),
                SizedBox(height: 8),
                ShimmerBox(width: 100, height: 16),
              ],
            ),
            ShimmerBox(width: 48, height: 48, borderRadius: 24),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: List.generate(
            4,
            (_) => const ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: AppSpacing.radiusLg,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const ShimmerBox(width: 120, height: 24),
        const SizedBox(height: AppSpacing.md),
        const ShimmerCard(),
        const SizedBox(height: AppSpacing.xl),
        const ShimmerBox(width: 120, height: 24),
        const SizedBox(height: AppSpacing.md),
        const ShimmerCard(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
