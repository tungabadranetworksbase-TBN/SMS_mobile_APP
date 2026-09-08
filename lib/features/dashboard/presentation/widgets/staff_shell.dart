import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/capabilities_store.dart';
import '../../../../core/auth/destinations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class StaffShell extends ConsumerWidget {
  final Widget child;

  const StaffShell({super.key, required this.child});

  int _indexForLocation(String location, List<Destination> tabs) {
    var bestIndex = 0;
    var bestLength = -1;
    for (var i = 0; i < tabs.length; i++) {
      final route = tabs[i].route;
      if (location == route || location.startsWith('$route/')) {
        if (route.length > bestLength) {
          bestIndex = i;
          bestLength = route.length;
        }
      }
    }
    return bestIndex;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = locator<CapabilitiesStore>().current;
    final tabs = caps == null
        ? const <Destination>[]
        : visibleStaffDestinations(caps);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = tabs.isEmpty ? 0 : _indexForLocation(location, tabs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: tabs.isEmpty
          ? null
          : _buildBottomNav(context, currentIndex, tabs),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    int currentIndex,
    List<Destination> tabs,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isActive = i == currentIndex;
              return _buildNavItem(tab, isActive, () {
                if (i == currentIndex) return;
                context.go(tab.route);
              });
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(Destination tab, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? tab.activeIcon : tab.icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
