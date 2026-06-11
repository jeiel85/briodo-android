import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todos_provider.dart';

/// 앱 전역 사용자 설정 (현재 디바이스 로컬에만 저장).
/// 향후 로그인 시 userSettings 컬렉션과 동기화 예정.
class AppSettings {
  const AppSettings({
    this.allDayReminderHour = 9,
    this.allDayReminderMinute = 0,
    this.calendarSyncEnabled = false,
    this.calendarSyncNoTime = 'allday',
    this.statusBarOngoingEnabled = false,
    this.themeMode = 'system',
    this.fontScale = 1.0,
    this.defaultView = 'date',
    this.completeMode = 'toggle',
    this.smartInputEngine = 'local',
    this.onDeviceModelPath = '',
    this.onDeviceModelUrl = 'https://huggingface.co/ASahu16/gemma/resolve/main/gemma-2b-it-cpu-int4.bin',
  });

  /// 종일 일정 알림 시각 (기본 09:00)
  final int allDayReminderHour;
  final int allDayReminderMinute;

  /// Google Calendar 양방향 동기화 활성화
  final bool calendarSyncEnabled;

  /// 시간 없는(종일) todo를 캘린더에 어떻게 보낼지 ('allday' | 'skip')
  final String calendarSyncNoTime;

  /// 상태바 상주 알림 (오늘 할 일 N개) 활성
  final bool statusBarOngoingEnabled;

  /// 'system' | 'light' | 'dark'
  final String themeMode;

  /// 1.0 = 기본, 0.9 / 1.1 / 1.25 등
  final double fontScale;

  /// 'date' | 'all' | 'lists'
  final String defaultView;

  /// 완료 시 처리 — 'toggle'(완료 상태 토글) | 'delete'(즉시 삭제)
  final String completeMode;

  /// 'local' | 'ondevice'
  final String smartInputEngine;

  /// 기기에 저장된 실제 모델 파일 경로
  final String onDeviceModelPath;

  /// 모델 다운로드 주소
  final String onDeviceModelUrl;

  AppSettings copyWith({
    int? allDayReminderHour,
    int? allDayReminderMinute,
    bool? calendarSyncEnabled,
    String? calendarSyncNoTime,
    bool? statusBarOngoingEnabled,
    String? themeMode,
    double? fontScale,
    String? defaultView,
    String? completeMode,
    String? smartInputEngine,
    String? onDeviceModelPath,
    String? onDeviceModelUrl,
  }) =>
      AppSettings(
        allDayReminderHour: allDayReminderHour ?? this.allDayReminderHour,
        allDayReminderMinute:
            allDayReminderMinute ?? this.allDayReminderMinute,
        calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
        calendarSyncNoTime: calendarSyncNoTime ?? this.calendarSyncNoTime,
        statusBarOngoingEnabled:
            statusBarOngoingEnabled ?? this.statusBarOngoingEnabled,
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        defaultView: defaultView ?? this.defaultView,
        completeMode: completeMode ?? this.completeMode,
        smartInputEngine: smartInputEngine ?? this.smartInputEngine,
        onDeviceModelPath: onDeviceModelPath ?? this.onDeviceModelPath,
        onDeviceModelUrl: onDeviceModelUrl ?? this.onDeviceModelUrl,
      );
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _keyHour = 'settings.allDayReminderHour';
  static const _keyMinute = 'settings.allDayReminderMinute';
  static const _keyCalSync = 'settings.calendarSyncEnabled';
  static const _keyCalNoTime = 'settings.calendarSyncNoTime';
  static const _keyOngoing = 'settings.statusBarOngoing';
  static const _keyThemeMode = 'settings.themeMode';
  static const _keyFontScale = 'settings.fontScale';
  static const _keyDefaultView = 'settings.defaultView';
  static const _keyCompleteMode = 'settings.completeMode';
  static const _keySmartEngine = 'settings.smartInputEngine';
  static const _keyModelPath = 'settings.onDeviceModelPath';
  static const _keyModelUrl = 'settings.onDeviceModelUrl';

  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      allDayReminderHour: _prefs.getInt(_keyHour) ?? 9,
      allDayReminderMinute: _prefs.getInt(_keyMinute) ?? 0,
      calendarSyncEnabled: _prefs.getBool(_keyCalSync) ?? false,
      calendarSyncNoTime: _prefs.getString(_keyCalNoTime) ?? 'allday',
      statusBarOngoingEnabled: _prefs.getBool(_keyOngoing) ?? false,
      themeMode: _prefs.getString(_keyThemeMode) ?? 'system',
      fontScale: _prefs.getDouble(_keyFontScale) ?? 1.0,
      defaultView: _prefs.getString(_keyDefaultView) ?? 'date',
      completeMode: _prefs.getString(_keyCompleteMode) ?? 'toggle',
      smartInputEngine: _prefs.getString(_keySmartEngine) ?? 'local',
      onDeviceModelPath: _prefs.getString(_keyModelPath) ?? '',
      onDeviceModelUrl: _prefs.getString(_keyModelUrl) ?? 'https://huggingface.co/ASahu16/gemma/resolve/main/gemma-2b-it-cpu-int4.bin',
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

  Future<void> setCalendarSyncEnabled(bool enabled) async {
    await _prefs.setBool(_keyCalSync, enabled);
    state = state.copyWith(calendarSyncEnabled: enabled);
  }

  Future<void> setCalendarSyncNoTime(String policy) async {
    await _prefs.setString(_keyCalNoTime, policy);
    state = state.copyWith(calendarSyncNoTime: policy);
  }

  Future<void> setStatusBarOngoingEnabled(bool enabled) async {
    await _prefs.setBool(_keyOngoing, enabled);
    state = state.copyWith(statusBarOngoingEnabled: enabled);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setFontScale(double scale) async {
    await _prefs.setDouble(_keyFontScale, scale);
    state = state.copyWith(fontScale: scale);
  }

  Future<void> setDefaultView(String view) async {
    await _prefs.setString(_keyDefaultView, view);
    state = state.copyWith(defaultView: view);
  }

  Future<void> setCompleteMode(String mode) async {
    await _prefs.setString(_keyCompleteMode, mode);
    state = state.copyWith(completeMode: mode);
  }

  Future<void> setSmartInputEngine(String engine) async {
    await _prefs.setString(_keySmartEngine, engine);
    state = state.copyWith(smartInputEngine: engine);
  }

  Future<void> setOnDeviceModelPath(String path) async {
    await _prefs.setString(_keyModelPath, path);
    state = state.copyWith(onDeviceModelPath: path);
  }

  Future<void> setOnDeviceModelUrl(String url) async {
    await _prefs.setString(_keyModelUrl, url);
    state = state.copyWith(onDeviceModelUrl: url);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
