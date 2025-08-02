import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationLocalDataSource {
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationLocalDataSourceImpl(this.flutterLocalNotificationsPlugin) {
    _init();
  }

  void _init() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones(); // مهمة لجدولة الإشعار في وقت محلي
  }

  @override
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // تحويل id من String إلى int
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel_id',
          'Booking Reminder',
          channelDescription: 'Reminders before booking time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // استبدال androidAllowWhileIdle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
