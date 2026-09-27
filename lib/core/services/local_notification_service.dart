import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'medicine_reminders';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDesc = 'Reminders to take your medication';

  // Holds a tap callback set via setOnTapCallback, and any tap payload
  // that arrived before a listener was registered (e.g. app launched
  // from terminated state by tapping a notification).
  void Function(String? payload)? _onTapCallback;
  String? _pendingTapPayload;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we ask explicitly below
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // macOS is treated as its own platform by this plugin (separate from
    // iOS), so it needs its own settings object or initialize() throws
    // when the app is run as a macOS desktop target.
    const DarwinInitializationSettings macOsInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: macOsInit,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (_onTapCallback != null) {
          _onTapCallback!(response.payload);
        } else {
          _pendingTapPayload = response.payload;
        }
      },
    );

    // Android 13+ needs an explicit channel registered
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    // macOS doesn't support permission_handler yet, so skip permission requests
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }

    try {
      final PermissionStatus notifStatus =
          await Permission.notification.request();

      final IOSFlutterLocalNotificationsPlugin? iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final bool? iosGranted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return notifStatus.isGranted || (iosGranted ?? false);
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Deterministic 32-bit id from a Reminder's String id, so the same
  /// reminder always maps to the same OS notification id.
  int notificationIdFor(String reminderId) =>
      reminderId.hashCode & 0x7fffffff;

  /// Schedule a medicine reminder. [id] should be unique per reminder
  /// (use [notificationIdFor]) so you can cancel/update it later.
  Future<void> scheduleReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required DateTime scheduledTime,
    bool repeatsDaily = false,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: 'Time to take $medicineName',
      body: dosage,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          repeatsDaily ? DateTimeComponents.time : null,
      payload: 'reminder:$id',
    );
  }

  Future<void> cancelReminder(int id) async => _plugin.cancel(id: id);

  /// Call this any time after [init] to react to notification taps
  /// (foreground taps and taps that relaunch the app). Safe to call
  /// once your UI is ready to navigate (e.g. after your first screen
  /// mounts), even if a tap already happened before this was registered.
  void setOnTapCallback(void Function(String? payload) onTap) {
    _onTapCallback = onTap;

    if (_pendingTapPayload != null) {
      onTap(_pendingTapPayload);
      _pendingTapPayload = null;
    }
  }
}
