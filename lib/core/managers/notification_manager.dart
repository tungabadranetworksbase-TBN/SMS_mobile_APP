import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Tungabadra Networks LMS — Notification Manager
///
/// Handles push notifications and local scheduling.
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Android Initialization
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Standard Flutter icon name

    // iOS Initialization
    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    _logger.i('NotificationManager initialized.');
  }

  /// Handle notification tap when app is in foreground/background.
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _logger.i('Notification Tapped with payload: ${response.payload}');
      // Example routing based on payload:
      // if (response.payload == 'course_update') {
      //   locator<NavigationManager>().pushNamed('course-details');
      // }
    }
  }

  /// Show a basic immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tbn_lms_channel',
          'TBN LMS Notifications',
          channelDescription:
              'General notifications for Tungabadra Networks LMS',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
