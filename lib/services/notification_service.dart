import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import '../utils/time_formatter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'task_timers',
      'Task Timers',
      description: 'Notifications for running task timers',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - app will open to main screen
    // No action needed, the app will automatically show active tasks
  }

  Future<void> showTimerNotification({
    required Task task,
    required int elapsedSeconds,
    required bool isRunning,
    required bool isPaused,
  }) async {
    if (!_initialized) await initialize();

    final taskId = task.id!;
    final timeText = TimeFormatter.formatElapsedTime(elapsedSeconds);
    
    // Determine status text
    final statusText = isPaused ? 'Paused' : 'Running';

    final androidDetails = AndroidNotificationDetails(
      'task_timers',
      'Task Timers',
      channelDescription: 'Notifications for running task timers',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: isRunning || isPaused, // Non-dismissible while active
      autoCancel: false,
      showWhen: false,
      usesChronometer: false,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(
        task.description ?? '',
        contentTitle: task.title,
        summaryText: '$statusText • $timeText',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      taskId, // Use taskId as notification ID
      task.title,
      '$statusText • $timeText',
      notificationDetails,
      payload: taskId.toString(),
    );
  }

  Future<void> updateTimerNotification({
    required Task task,
    required int elapsedSeconds,
    required bool isRunning,
    required bool isPaused,
  }) async {
    // Just call showTimerNotification - it will update the existing notification
    await showTimerNotification(
      task: task,
      elapsedSeconds: elapsedSeconds,
      isRunning: isRunning,
      isPaused: isPaused,
    );
  }

  Future<void> cancelNotification(int taskId) async {
    await _notifications.cancel(taskId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }
}
