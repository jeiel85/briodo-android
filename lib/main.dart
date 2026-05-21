import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_settings_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/todos_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/analytics_service.dart';
import 'services/notifications_service.dart';
import 'theme.dart';

// Firebase Console > Authentication > Sign-in method > Google > Web SDK 구성
// 의 클라이언트 ID. Capacitor 시절부터 동일.
const String _googleServerClientId =
    '758825654936-hbi2uo4u34gqn8okvnnaqlm1ic43hfbc.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  await NotificationsService.instance.init();

  final prefs = await SharedPreferences.getInstance();

  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _googleServerClientId,
      );
    } catch (_) {}
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BrioDoApp(),
    ),
  );
}

ThemeMode _themeModeFor(String code) {
  switch (code) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

class BrioDoApp extends ConsumerWidget {
  const BrioDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: 'BrioDo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeModeFor(settings.themeMode),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      navigatorObservers: [AnalyticsService.instance.observer],
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child,
        );
      },
      home: const _AppRoot(),
    );
  }
}

/// 첫 실행이면 OnboardingScreen, 아니면 HomeScreen.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool? _done;

  @override
  void initState() {
    super.initState();
    _done = ref.read(sharedPreferencesProvider).getBool('onboarding.done') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_done == false) {
      return OnboardingScreen(onDone: () => setState(() => _done = true));
    }
    return const HomeScreen();
  }
}
