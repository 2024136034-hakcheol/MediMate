import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _androidDetails = AndroidNotificationDetails(
    'medimate_channel',
    '복용 알림',
    channelDescription: '약 복용 시간 알림',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _details = NotificationDetails(android: _androidDetails);

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 매일 특정 시간에 반복 알림 등록
  Future<void> scheduleDailyDose({
    required int id,
    required String medicineName,
    required int hour,
    required int minute,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _plugin.zonedSchedule(
        id,
        'MediMate 복용 알림',
        '$medicineName 복용 시간입니다',
        _nextInstanceOf(hour, minute),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    // Windows/Linux는 스케줄 알림 미지원 — 데모용 즉시 알림 생략
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showImmediate({required int id, required String medicineName}) async {
    await _plugin.show(id, 'MediMate', '$medicineName 복용 완료 기록됨', _details);
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
