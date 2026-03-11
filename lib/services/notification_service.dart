import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint(
          'NotificationService: Web platform detected - skipping native notification init');
      return;
    }

    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      _isInitialized = true;
      debugPrint(
          'NotificationService: Native platform - notifications initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Failed to initialize notifications: $e');
    }
  }

  Future<void> scheduleExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime expiryDate,
    int daysBefore = 1,
  }) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint(
          'NotificationService: Skipping schedule on web or uninitialized plugin');
      return;
    }

    // Calculate when the notification should fire
    final scheduledDate = expiryDate.subtract(Duration(days: daysBefore));

    // If that date has already passed, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
          'NotificationService: Scheduled date for $title is in the past. Canceling.');
      return;
    }

    try {
      debugPrint(
          'NotificationService: Scheduling notification for $title on $scheduledDate');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_expiry_channel',
            'Medicine Expiry Alerts',
            channelDescription: 'Notifications for expiring medicines',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('NotificationService: Notification scheduled successfully');
    } catch (e) {
      debugPrint('NotificationService: Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      debugPrint('NotificationService: Cancelling notification $id');
      await flutterLocalNotificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notification $id: $e');
    }
  }
}
