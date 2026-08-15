import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/models/notification_message_dto.dart';
import '../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return locator<NotificationsRepository>();
});

final notificationsProvider = FutureProvider<List<NotificationMessageDto>>((
  ref,
) {
  return ref.read(notificationsRepositoryProvider).getNotifications();
});

class NotificationsController extends StateNotifier<AsyncValue<void>> {
  final NotificationsRepository _repository;
  final Ref _ref;

  NotificationsController({
    required NotificationsRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      _ref.invalidate(notificationsProvider);
    } catch (e) {
      state = AsyncValue.error(
        ApiException(message: e.toString()),
        StackTrace.current,
      );
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAllAsRead();
      _ref.invalidate(notificationsProvider);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(
        ApiException(message: e.toString()),
        StackTrace.current,
      );
    }
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, AsyncValue<void>>((ref) {
      return NotificationsController(
        repository: ref.watch(notificationsRepositoryProvider),
        ref: ref,
      );
    });
