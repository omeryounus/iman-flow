import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:adhan/adhan.dart';
import 'prayer_service.dart';

/// Notification Service for Prayer Times and Daily Reminders
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  /// Initialize notification service
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to appropriate screen
    // This would be handled by the app's navigation
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }

  /// Schedule Adhan notifications for all prayer times
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    // Cancel existing prayer notifications
    await cancelPrayerNotifications();
    
    final prayers = [
      (Prayer.fajr, prayerTimes.fajr, 'Fajr', '🌅'),
      (Prayer.dhuhr, prayerTimes.dhuhr, 'Dhuhr', '☀️'),
      (Prayer.asr, prayerTimes.asr, 'Asr', '🌤️'),
      (Prayer.maghrib, prayerTimes.maghrib, 'Maghrib', '🌅'),
      (Prayer.isha, prayerTimes.isha, 'Isha', '🌙'),
    ];
    
    for (var i = 0; i < prayers.length; i++) {
      final (prayer, time, name, emoji) = prayers[i];
      
      if (time.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 100 + i, // Prayer notification IDs start at 100
          title: '$emoji Time for $name Prayer',
          body: 'It\'s time to pray. May Allah accept your prayer. 🤲',
          scheduledTime: time,
          payload: 'prayer_$name',
        );
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      sound: 'adhan.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule daily Hadith reminder
  Future<void> scheduleDailyHadith({int hour = 9, int minute = 0}) async {
    await _notifications.zonedSchedule(
      200, // Daily Hadith notification ID
      '📖 Daily Hadith',
      'Start your day with wisdom from the Prophet ﷺ',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily Islamic reminders',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_hadith',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Cancel all prayer notifications
  Future<void> cancelPrayerNotifications() async {
    for (var i = 100; i < 106; i++) {
      await _notifications.cancel(i);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Show immediate notification
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'general',
        'General',
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 10000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
