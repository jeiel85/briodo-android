import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/auth_provider.dart';
import 'demo_screen.dart';

/// 진입 화면 — Google 로그인 1버튼.
/// 익명 로그인은 v1.1.17(Capacitor) → Flutter 마이그레이션 과정에서 폐기.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await signInWithGoogle();
    } on GoogleSignInException catch (e) {
      // 사용자가 시트를 닫은 경우는 조용히 무시.
      if (e.code != GoogleSignInExceptionCode.canceled) {
        setState(() => _error = '로그인에 실패했어요 (${e.code.name})');
      }
    } catch (e) {
      setState(() => _error = '로그인에 실패했어요\n$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BrioDo',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Do it with brio.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _busy ? null : _signInWithGoogle,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(_busy ? '로그인 중…' : 'Google로 시작'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DemoScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.preview, size: 18),
                  label: const Text('데모 보기 (로그인 없이)'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
