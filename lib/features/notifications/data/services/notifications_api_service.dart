import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/json_value.dart';
import '../models/notification_message_dto.dart';

class NotificationsApiService {
  final ApiClient _apiClient;

  NotificationsApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<ApiResponse<List<NotificationMessageDto>>> getNotifications() async {
    return _apiClient.get<List<NotificationMessageDto>>(
      ApiEndpoints.notifications,
      fromJson: (json) {
        final raw = json is List ? json : jsonList(jsonMap(json)['notifications']);
        return raw
            .map((e) => NotificationMessageDto.fromJson(jsonMap(e)))
            .toList();
      },
    );
  }

  Future<ApiResponse<void>> markAsRead(String id) async {
    return _apiClient.post<void>(
      ApiEndpoints.withParams(ApiEndpoints.markNotificationRead, {'id': id}),
    );
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    return _apiClient.post<void>(ApiEndpoints.markAllNotificationsRead);
  }
}
