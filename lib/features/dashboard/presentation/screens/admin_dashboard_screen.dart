import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/managers/session_manager.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/models/admin_dashboard_dto.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(adminDashboardProvider);
    final user = locator<SessionManager>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(adminDashboardProvider.notifier).refresh(),
          color: AppColors.primary,
          child: dashboardState.when(
            data: (data) => _buildContent(context, user, data),
            loading: () => _buildLoading(),
            error: (error, _) => ErrorStateView(
              message: error.toString(),
              onRetry: () =>
                  ref.read(adminDashboardProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SessionManager user,
    AdminDashboardDto data,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(RoutePaths.staffAnalytics),
              child: const Text('CRM analytics'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHeroStats(data.stats),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Recent activity'),
          const SizedBox(height: AppSpacing.md),
          _buildSystemAlerts(data.systemAlerts),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Orders (30 days)'),
          const SizedBox(height: AppSpacing.md),
          _buildRevenueChart(data.revenueData),
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
              'Hello, ${user.userName?.split(' ').first ?? 'Admin'} 👋',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Admin Dashboard',
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
              ? const Icon(Icons.shield_rounded, color: AppColors.textMuted)
              : null,
        ),
      ],
    );
  }

  Widget _buildHeroStats(AdminStatsDto stats) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Users',
          value: '${stats.totalUsers}',
          icon: Icons.groups_rounded,
          color: AppColors.info,
        ),
        _StatCard(
          title: 'Revenue',
          value: currencyFormatter.format(stats.totalRevenue),
          icon: Icons.payments_rounded,
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Active Courses',
          value: '${stats.activeCourses}',
          icon: Icons.library_books_rounded,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Open alerts',
          value: '${stats.pendingApprovals}',
          icon: Icons.flag_rounded,
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

  Widget _buildSystemAlerts(List<SystemAlertDto> alerts) {
    if (alerts.isEmpty) {
      return const _EmptyCard(message: 'System operating normally.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        Color color;
        IconData icon;

        switch (alert.severity.toLowerCase()) {
          case 'critical':
            color = AppColors.error;
            icon = Icons.error_rounded;
            break;
          case 'high':
            color = AppColors.warning;
            icon = Icons.warning_rounded;
            break;
          default:
            color = AppColors.info;
            icon = Icons.info_rounded;
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat.yMMMd().add_jm().format(alert.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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

  Widget _buildRevenueChart(List<RevenueDataDto> data) {
    if (data.isEmpty) {
      return const _EmptyCard(message: 'No revenue data available.');
    }

    // In a real app, use fl_chart or similar. Here we use a simple bar representation.
    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final heightFactor = maxAmount == 0 ? 0.0 : item.amount / maxAmount;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(item.amount / 1000).toStringAsFixed(1)}k',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 24,
                height: 120 * heightFactor,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.month.substring(0, 3),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
