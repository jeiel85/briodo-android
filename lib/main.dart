import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
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
  await GoogleSignIn.instance.initialize(
    serverClientId: _googleServerClientId,
  );
  runApp(const ProviderScope(child: BrioDoApp()));
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
      home: const AuthGate(),
    );
  }
}
