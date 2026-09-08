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
          _buildHeader(user, data.continueLearning?.courseTitle),
          const SizedBox(height: AppSpacing.xl),
          _buildHeroStats(data.stats),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Your courses'),
          const SizedBox(height: AppSpacing.md),
          _buildCourses(data.courses),
        ],
      ),
    );
  }

  Widget _buildHeader(SessionManager user, String? continueTitle) {
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
              continueTitle == null
                  ? 'Ready to learn'
                  : 'Continue: $continueTitle',
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
            title: 'Courses',
            value: '${stats.enrolledCourses}',
            icon: Icons.school_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            title: 'Lectures',
            value: '${stats.completedLectures}',
            icon: Icons.play_circle_outline_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            title: 'Purchases',
            value: '${stats.purchases}',
            icon: Icons.receipt_long_outlined,
            color: AppColors.info,
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

  Widget _buildCourses(List<DashboardCourseDto> courses) {
    if (courses.isEmpty) {
      return const _EmptyCard(message: 'No enrolled courses yet.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final course = courses[index];
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
                course.courseTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                course.educatorName,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: course.progress,
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
