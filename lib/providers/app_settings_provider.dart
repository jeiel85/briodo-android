import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todos_provider.dart';

/// 앱 전역 사용자 설정 (현재 디바이스 로컬에만 저장).
/// 향후 로그인 시 userSettings 컬렉션과 동기화 예정.
class AppSettings {
  const AppSettings({
    this.allDayReminderHour = 9,
    this.allDayReminderMinute = 0,
  });

  /// 종일 일정 알림 시각 (기본 09:00)
  final int allDayReminderHour;
  final int allDayReminderMinute;

  AppSettings copyWith({int? allDayReminderHour, int? allDayReminderMinute}) =>
      AppSettings(
        allDayReminderHour: allDayReminderHour ?? this.allDayReminderHour,
        allDayReminderMinute:
            allDayReminderMinute ?? this.allDayReminderMinute,
      );
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _keyHour = 'settings.allDayReminderHour';
  static const _keyMinute = 'settings.allDayReminderMinute';

  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      allDayReminderHour: _prefs.getInt(_keyHour) ?? 9,
      allDayReminderMinute: _prefs.getInt(_keyMinute) ?? 0,
    );
  }

  Future<void> setAllDayReminderTime({required int hour, required int minute}) async {
    await _prefs.setInt(_keyHour, hour);
    await _prefs.setInt(_keyMinute, minute);
    state = state.copyWith(
      allDayReminderHour: hour,
      allDayReminderMinute: minute,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
