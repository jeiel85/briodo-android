import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'providers/todos_provider.dart';
import 'screens/home_screen.dart';
import 'services/analytics_service.dart';
import 'theme.dart';

// Firebase Console > Authentication > Sign-in method > Google > Web SDK 구성
// 의 클라이언트 ID. Capacitor 시절부터 동일.
const String _googleServerClientId =
    '758825654936-hbi2uo4u34gqn8okvnnaqlm1ic43hfbc.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase는 로그인을 안 했더라도 항상 init — 나중에 옵션 로그인이 사용되면
  // 같은 인스턴스를 사용함. 클라우드 동기화가 꺼져 있어도 비용/성능 영향 없음.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Analytics는 자동으로 app_open / session_start / first_open 수집.
  // 명시 이벤트는 services/analytics_service.dart에서 토글.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // 로컬 저장소 — 로그인 안 한 사용자도 곧바로 todos를 쓸 수 있게 사전 로드.
  final prefs = await SharedPreferences.getInstance();

  // 안드(/iOS)에서만 GIS 초기화. 웹은 OAuth 웹 클라이언트가 localhost 도메인
  // 허용 등록되어야 하므로 일단 스킵. 실패해도 앱 부팅은 막지 않음.
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

class BrioDoApp extends StatelessWidget {
  const BrioDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrioDo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      navigatorObservers: [AnalyticsService.instance.observer],
      home: const HomeScreen(),
    );
  }
}
