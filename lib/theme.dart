import 'package:flutter/material.dart';

/// Material 3 테마. seedColor 한 줄로 라이트/다크 자동 생성.
/// 현재 Capacitor 버전의 #10151f 다크/포인트 컬러 톤과 가깝게 맞춤.
class AppTheme {
  static const _seed = Color(0xFF5B8DEF);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      );
}
