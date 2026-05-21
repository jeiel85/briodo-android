import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

/// Google 로그인 → Firebase Auth 자격증명 발급까지.
/// 호출 전에 main()에서 [GoogleSignIn.instance.initialize]가 한 번 실행돼 있어야 함.
/// 사용자가 시트를 닫으면 [GoogleSignInException](code: canceled)를 던지므로
/// 호출 측에서 try/catch로 구분 처리.
Future<UserCredential> signInWithGoogle() async {
  final googleUser = await GoogleSignIn.instance.authenticate();
  final idToken = googleUser.authentication.idToken;
  if (idToken == null) {
    throw StateError('Google idToken을 받지 못했습니다.');
  }
  final credential = GoogleAuthProvider.credential(idToken: idToken);
  return FirebaseAuth.instance.signInWithCredential(credential);
}

/// Firebase + Google 양쪽에서 모두 로그아웃.
/// Google 쪽만 풀어두면 다음 로그인 시 계정 선택 시트가 안 뜨는 케이스가 있어
/// 같이 호출.
Future<void> signOutCompletely() async {
  await FirebaseAuth.instance.signOut();
  try {
    await GoogleSignIn.instance.signOut();
  } catch (_) {
    // 익명 사용자 같이 Google 세션이 없던 경우는 무시.
  }
}
