import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'message_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentAlert: false, // Powiadomienia nie pokazują się na ekranie gdy aplikacja jest otwarta
          defaultPresentBadge: false,
          defaultPresentSound: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // W przypadku Androida paczka domyślnie pokazuje powiadomienia na foregroundzie
    // Skonfigurujemy inicjalizację, by zablokować to zachowanie
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Obsługa kliknięcia (opcjonalna)
      },
    );
    
    // Zapytaj o pozwolenie na dokładne alarmy (Android 12+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestExactAlarmsPermission();
    
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> scheduleDailyNotification([String language = 'pl', int hour = 9, int minute = 0]) async {
    await _notifications.cancelAll();
    
    final messages = await HappyMessageService.getAllMessages(language);
    if (messages.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    // TEST: Schedule starting from now + 2 minutes
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour, now.minute).add(const Duration(minutes: 2));

    // Schedule notifications for the next 60 intervals (co 2 minuty)
    for (int i = 0; i < 60; i++) {
      final notificationDate = scheduledDate.add(Duration(minutes: i * 2));
      final messageIndex = (notificationDate.minute ~/ 2) % messages.length;
      final message = messages[messageIndex];
      
      await _notifications.zonedSchedule(
        i,
        'Be Happy Everyday ✨',
        message,
        notificationDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_happy',
            'Daily Happy Messages',
            channelDescription: 'Codzienne wiadomości szczęścia',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
