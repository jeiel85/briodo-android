import 'package:flutter/material.dart';

/// briodo-renew(Jetpack Compose) 디자인 시스템에서 가져온 BrioDo 브랜드 팔레트.
/// 라이트/다크에서 동일한 의미의 색을 보장한다.
class BrioColors {
  BrioColors._();

  // Light brand
  static const primary = Color(0xFF2563EB); // Energetic soft blue
  static const primaryContainer = Color(0xFFDBEAFE);
  static const onPrimaryContainer = Color(0xFF1E40AF);

  static const secondary = Color(0xFF7C3AED); // Calm lavender
  static const secondaryContainer = Color(0xFFEDE9FE);
  static const onSecondaryContainer = Color(0xFF4C1D95);

  static const success = Color(0xFF10B981); // Fresh green
  static const successContainer = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B); // Warm amber
  static const warningContainer = Color(0xFFFEF3C7);

  static const urgent = Color(0xFFEF4444); // Clean coral red
  static const urgentContainer = Color(0xFFFEE2E2);

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF0F172A);
  static const lightOnSurface = Color(0xFF1E293B);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightOutline = Color(0xFFCBD5E1);

  // Dark brand (OLED friendly)
  static const darkPrimary = Color(0xFF60A5FA);
  static const darkPrimaryContainer = Color(0xFF1E3A8A);
  static const darkOnPrimaryContainer = Color(0xFF93C5FD);

  static const darkSecondary = Color(0xFFC084FC);
  static const darkSecondaryContainer = Color(0xFF4C1D95);
  static const darkOnSecondaryContainer = Color(0xFFEDE9FE);

  static const darkBackground = Color(0xFF070A13); // Deep navy
  static const darkSurface = Color(0xFF0F1626); // Deep slate
  static const darkOnBackground = Color(0xFFF1F5F9);
  static const darkOnSurface = Color(0xFFE2E8F0);
  static const darkSurfaceVariant = Color(0xFF1E293B);
  static const darkOutline = Color(0xFF334155);

  /// brio의 의미 컬러를 라이트/다크 모드에 맞게 골라줌.
  static Color successOf(BuildContext ctx) => success;
  static Color warningOf(BuildContext ctx) => warning;
  static Color urgentOf(BuildContext ctx) => urgent;

  static Color successContainerOf(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF064E3B)
          : successContainer;

  static Color warningContainerOf(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF78350F)
          : warningContainer;

  static Color urgentContainerOf(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF7F1D1D)
          : urgentContainer;
}

/// Material 3 테마. Brio 브랜드 컬러 시스템 적용.
class AppTheme {
  static ThemeData light() {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: BrioColors.primary,
      onPrimary: Colors.white,
      primaryContainer: BrioColors.primaryContainer,
      onPrimaryContainer: BrioColors.onPrimaryContainer,
      secondary: BrioColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: BrioColors.secondaryContainer,
      onSecondaryContainer: BrioColors.onSecondaryContainer,
      tertiary: BrioColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: BrioColors.successContainer,
      onTertiaryContainer: Color(0xFF065F46),
      error: BrioColors.urgent,
      onError: Colors.white,
      errorContainer: BrioColors.urgentContainer,
      onErrorContainer: Color(0xFF991B1B),
      surface: BrioColors.lightSurface,
      onSurface: BrioColors.lightOnSurface,
      surfaceContainerHighest: BrioColors.lightSurfaceVariant,
      onSurfaceVariant: Color(0xFF475569),
      outline: BrioColors.lightOutline,
      outlineVariant: Color(0xFFE2E8F0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF1E293B),
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: BrioColors.darkPrimary,
    );
    return _base(cs, BrioColors.lightBackground);
  }

  static ThemeData dark() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: BrioColors.darkPrimary,
      onPrimary: Color(0xFF0B1220),
      primaryContainer: BrioColors.darkPrimaryContainer,
      onPrimaryContainer: BrioColors.darkOnPrimaryContainer,
      secondary: BrioColors.darkSecondary,
      onSecondary: Color(0xFF1E0B33),
      secondaryContainer: BrioColors.darkSecondaryContainer,
      onSecondaryContainer: BrioColors.darkOnSecondaryContainer,
      tertiary: BrioColors.success,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF064E3B),
      onTertiaryContainer: BrioColors.successContainer,
      error: BrioColors.urgent,
      onError: Colors.white,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: BrioColors.urgentContainer,
      surface: BrioColors.darkSurface,
      onSurface: BrioColors.darkOnSurface,
      surfaceContainerHighest: BrioColors.darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFCBD5E1),
      outline: BrioColors.darkOutline,
      outlineVariant: Color(0xFF1F2937),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE2E8F0),
      onInverseSurface: Color(0xFF0F172A),
      inversePrimary: BrioColors.primary,
    );
    return _base(cs, BrioColors.darkBackground);
  }

  static ThemeData _base(ColorScheme cs, Color scaffoldBg) => ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: scaffoldBg,
        cardTheme: CardThemeData(
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant, width: 0.6),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scaffoldBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: cs.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: cs.primary);
            }
            return IconThemeData(color: cs.onSurfaceVariant);
          }),
          height: 64,
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: StadiumBorder(
            side: BorderSide(color: cs.outlineVariant),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
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
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: cs.outlineVariant,
          thickness: 0.6,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      );
}
