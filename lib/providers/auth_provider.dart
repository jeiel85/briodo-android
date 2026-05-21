import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 로그인 상태. UI는 .when(data:, loading:, error:)로 그림.
/// FirebaseAuth.authStateChanges()를 그대로 스트림으로 노출.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 편의용 — 현재 uid (null이면 로그아웃 상태).
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
});
