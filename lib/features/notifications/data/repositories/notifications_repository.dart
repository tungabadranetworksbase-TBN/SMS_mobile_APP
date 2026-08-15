import '../../../../core/demo/demo_mode.dart';
import '../../../../core/network/api_exception.dart';
import '../models/notification_message_dto.dart';
import '../services/notifications_api_service.dart';

class NotificationsRepository {
  final NotificationsApiService _apiService;

  NotificationsRepository({required NotificationsApiService apiService})
      : _apiService = apiService;

  Future<List<NotificationMessageDto>> getNotifications() async {
    if (DemoMode().isActive) {
      return [];
    }
    try {
      final response = await _apiService.getNotifications();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(message: response.message ?? 'Failed to load notifications');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    if (DemoMode().isActive) {
      return;
    }
    try {
      final response = await _apiService.markAsRead(id);
      if (!response.success) {
        throw ApiException(message: response.message ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (DemoMode().isActive) {
      return;
    }
    try {
      final response = await _apiService.markAllAsRead();
      if (!response.success) {
        throw ApiException(message: response.message ?? 'Failed to mark all as read');
      }
    } catch (e) {
      rethrow;
    }
  }
}

