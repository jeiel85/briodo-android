import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todos_provider.dart';

/// 사용자가 명시적으로 선택한 언어. null이면 시스템 언어 따름.
/// 지원: ko, en, ja, zh
class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'app.locale';
  static const supported = ['ko', 'en', 'ja', 'zh'];

  late SharedPreferences _prefs;

  @override
  Locale? build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final code = _prefs.getString(_key);
    if (code == null || code.isEmpty) return null;
    if (!supported.contains(code)) return null;
    return Locale(code);
  }

  Future<void> setLanguageCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _prefs.remove(_key);
      state = null;
      return;
    }
    if (!supported.contains(code)) return;
    await _prefs.setString(_key, code);
    state = Locale(code);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
