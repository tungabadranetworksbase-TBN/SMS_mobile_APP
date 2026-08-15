import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/notifications_controller.dart';
import '../../data/models/notification_message_dto.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsControllerProvider.notifier).markAllAsRead();
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: asyncNotifications.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No notifications',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                return _NotificationTile(notification: notifications[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load notifications.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationMessageDto notification;

  const _NotificationTile({required this.notification});

  IconData _getIcon() {
    switch (notification.type.toUpperCase()) {
      case 'SUCCESS':
        return Icons.check_circle_outline;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'ALERT':
        return Icons.error_outline;
      case 'INFO':
      default:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (notification.type.toUpperCase()) {
      case 'SUCCESS':
        return AppColors.success;
      case 'WARNING':
        return AppColors.warning;
      case 'ALERT':
        return AppColors.error;
      case 'INFO':
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      tileColor: notification.isRead ? AppColors.background : AppColors.primary.withValues(alpha: 0.05),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getIconColor().withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIcon(), color: _getIconColor()),
      ),
      title: Text(
        notification.title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            dateFormat.format(notification.createdAt),
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id);
        }
        if (notification.link != null) {
          // Parse link and navigate
          // context.push(notification.link!);
        }
      },
    );
  }
}
