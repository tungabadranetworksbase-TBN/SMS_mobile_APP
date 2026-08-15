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
import '../../data/models/student_dashboard_dto.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(studentDashboardProvider);
    final user = locator<SessionManager>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(studentDashboardProvider.notifier).refresh(),
          color: AppColors.primary,
          child: dashboardState.when(
            data: (data) => _buildContent(context, user, data),
            loading: () => _buildLoading(),
            error: (error, _) => ErrorStateView(
              message: error.toString(),
              onRetry: () =>
                  ref.read(studentDashboardProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SessionManager user,
    StudentDashboardDto data,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user, data.currentClassName),
          const SizedBox(height: AppSpacing.xl),
          _buildHeroStats(data.stats),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Active Courses'),
          const SizedBox(height: AppSpacing.md),
          _buildActiveBatches(data.activeBatches),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Upcoming Tasks'),
          const SizedBox(height: AppSpacing.md),
          _buildUpcomingTasks(data.upcomingTasks),
        ],
      ),
    );
  }

  Widget _buildHeader(SessionManager user, String className) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.userName?.split(' ').first ?? 'Student'} 👋',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              className,
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

  Widget _buildHeroStats(DashboardStatsDto stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Attendance',
            value: '${(stats.attendancePercentage * 100).toInt()}%',
            icon: Icons.calendar_today_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            title: 'Pending Tasks',
            value: '${stats.pendingTasksCount}',
            icon: Icons.assignment_late_rounded,
            color: AppColors.warning,
          ),
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

  Widget _buildActiveBatches(List<StudentBatchDto> batches) {
    if (batches.isEmpty) {
      return const _EmptyCard(message: 'No active courses at the moment.');
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
              Text(
                batch.courseTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                batch.name,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: batch.progress,
                backgroundColor: AppColors.surfaceContainer,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                minHeight: 6,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTasks(List<UpcomingTaskDto> tasks) {
    if (tasks.isEmpty) {
      return const _EmptyCard(message: 'You\'re all caught up!');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      task.courseName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
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
      children: const [
        Row(
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
        SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: AppSpacing.radiusLg,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: AppSpacing.radiusLg,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        ShimmerBox(width: 120, height: 24),
        SizedBox(height: AppSpacing.md),
        ShimmerCard(),
        SizedBox(height: AppSpacing.xl),
        ShimmerBox(width: 120, height: 24),
        SizedBox(height: AppSpacing.md),
        ShimmerCard(),
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
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
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
