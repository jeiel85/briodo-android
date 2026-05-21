import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 로컬 알림 — Capacitor v1.1.17 채널 구조와 일관성 유지.
/// 4개 채널을 우선순위별로 분리해 시스템 알림 음/진동/중요도가 자연스럽게 차이남.
class NotificationsService {
  NotificationsService._();
  static final instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelUrgent = 'briodo_urgent';
  static const String _channelHigh = 'briodo_high';
  static const String _channelMedium = 'briodo_medium';
  static const String _channelLow = 'briodo_low';
  static const String _channelOngoing = 'briodo_ongoing';
  static const int _ongoingId = 999999;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    // 한국 기본 — 추후 사용자 설정으로 노출 예정.
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await _createChannels(androidImpl);
      }
    }
    _initialized = true;
  }

  Future<void> _createChannels(
      AndroidFlutterLocalNotificationsPlugin androidImpl) async {
    final channels = <AndroidNotificationChannel>[
      const AndroidNotificationChannel(
        _channelUrgent,
        '긴급',
        description: '긴급 우선순위 일정 알림',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        _channelHigh,
        '높음',
        description: '높음 우선순위 일정 알림',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        _channelMedium,
        '보통',
        description: '보통 우선순위 일정 알림',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        _channelLow,
        '낮음',
        description: '낮음 우선순위 일정 알림',
        importance: Importance.low,
      ),
      const AndroidNotificationChannel(
        _channelOngoing,
        '상시 표시',
        description: '상태바에 오늘 할 일 개수 상주 표시',
        importance: Importance.min,
        showBadge: false,
      ),
    ];
    for (final c in channels) {
      await androidImpl.createNotificationChannel(c);
    }
  }

  /// POST_NOTIFICATIONS 권한 확인/요청.
  /// 반환: 사용자가 허용했는지.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Permission.notification.isGranted;
    }
    return true;
  }

  /// todo id를 32비트 정수로 해싱 — 알림 ID로 사용.
  int notificationIdFor(String todoId) {
    var h = 0;
    for (final code in todoId.codeUnits) {
      h = (h * 31 + code) & 0x7fffffff;
    }
    return h;
  }

  /// 특정 일자/시각에 한 번 발송.
  Future<void> scheduleTodo({
    required String todoId,
    required String title,
    required String body,
    required DateTime when,
    required String priority,
  }) async {
    if (!_initialized) await init();
    final channelId = _channelFor(priority);
    final importance = _importanceFor(priority);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName(channelId),
        importance: importance,
        priority: _androidPriorityFor(priority),
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: notificationIdFor(todoId),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: todoId,
    );
  }

  Future<void> cancel(String todoId) async {
    if (!_initialized) await init();
    await _plugin.cancel(id: notificationIdFor(todoId));
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  /// 상태바 상주 알림. 사용자가 끌 때까지 계속 표시.
  /// activeCount/firstLine을 업데이트하면 같은 ID로 갱신.
  Future<void> showOngoing({
    required int activeCount,
    required String firstLine,
  }) async {
    if (!_initialized) await init();
    final body = firstLine.isEmpty ? '오늘 할 일이 없어요' : firstLine;
    final title = activeCount > 0 ? '오늘 할 일 $activeCount개' : '오늘은 비어있어요';
    await _plugin.show(
      id: _ongoingId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelOngoing,
          '상시 표시',
          importance: Importance.min,
          priority: Priority.min,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          onlyAlertOnce: true,
          category: AndroidNotificationCategory.status,
        ),
      ),
    );
  }

  Future<void> cancelOngoing() async {
    if (!_initialized) await init();
    await _plugin.cancel(id: _ongoingId);
  }

  String _channelFor(String priority) {
    switch (priority) {
      case 'urgent':
        return _channelUrgent;
      case 'high':
        return _channelHigh;
      case 'low':
        return _channelLow;
      case 'medium':
      default:
        return _channelMedium;
    }
  }

  String _channelName(String id) {
    switch (id) {
      case _channelUrgent:
        return '긴급';
      case _channelHigh:
        return '높음';
      case _channelLow:
        return '낮음';
      default:
        return '보통';
    }
  }

  Importance _importanceFor(String priority) {
    switch (priority) {
      case 'urgent':
        return Importance.max;
      case 'high':
        return Importance.high;
      case 'low':
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _androidPriorityFor(String priority) {
    switch (priority) {
      case 'urgent':
        return Priority.max;
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }
}
