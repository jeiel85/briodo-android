import 'package:flutter/material.dart';

/// Material 3 테마. seedColor 한 줄로 라이트/다크 자동 생성.
/// Capacitor 버전의 #5B8DEF 포인트 컬러를 그대로 가져와 사용자에게 익숙한 톤 유지.
class AppTheme {
  static const _seed = Color(0xFF5B8DEF);

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(seedColor: _seed);
    return _base(cs);
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _base(cs);
  }

  static ThemeData _base(ColorScheme cs) => ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        // 카드는 그림자 적게, 외곽선만 살짝.
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant, width: 0.5),
          ),
        ),
        // SegmentedButton 톤 정리
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        // ChoiceChip
        chipTheme: ChipThemeData(
          shape: StadiumBorder(
            side: BorderSide(color: cs.outlineVariant),
          ),
        ),
        // ListTile 좌우 패딩 통일
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        // FilledButton 적당한 모서리
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: cs.outlineVariant),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
