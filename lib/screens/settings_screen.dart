import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';

/// 계정 / 동기화 설정.
/// - 로그인 안 함 (로컬 저장)  → "Google 계정으로 로그인" 노출
/// - 익명 / Google 로그인 됨   → 표시명/이메일 + "로그아웃" 노출
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _login() async {
    if (kIsWeb) {
      _snack('웹에서는 아직 Google 로그인이 지원되지 않습니다. 모바일 앱에서 사용해 주세요.');
      return;
    }
    setState(() => _busy = true);
    try {
      // 로컬에 저장된 일정이 있으면 클라우드로 옮길지 먼저 묻고,
      // 사용자가 동의해야 로그인 → 마이그레이션 순으로 진행.
      final localRepo = ref.read(todosRepositoryProvider);
      final localBefore = await localRepo.snapshot();
      final hasLocal = localBefore.isNotEmpty && localRepo is LocalTodosRepository;

      bool migrate = false;
      if (hasLocal && mounted) {
        migrate = await _askMigrate(localBefore.length) ?? false;
      }

      await signInWithGoogle();

      if (migrate) {
        // 로그인 후엔 todosRepositoryProvider가 FirestoreTodosRepository로 교체됨.
        // 새로 ref.read해서 cloud repo를 가져와 bulkAdd.
        final cloudRepo = ref.read(todosRepositoryProvider);
        await cloudRepo.bulkAdd(localBefore);
        // 로컬 비우기 (마이그레이션 완료 후)
        if (localRepo is LocalTodosRepository) {
          await localRepo.clearAll();
        }
        _snack('로그인됐어요. 일정 ${localBefore.length}개를 Google 계정으로 옮겼습니다.');
      } else {
        _snack('로그인됐어요.');
      }
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _snack('로그인 실패: ${e.code.name}');
      }
    } catch (e) {
      _snack('로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    try {
      await signOutCompletely();
      _snack('로그아웃됐어요. 다시 로컬 저장으로 돌아갑니다.');
    } catch (e) {
      _snack('로그아웃 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _askMigrate(int count) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기기 일정을 옮길까요?'),
        content: Text(
          '현재 기기에 저장된 일정 $count개가 있어요.\n'
          'Google 계정으로 옮기면 다른 기기에서도 같은 일정을 볼 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('아니요, 그냥 로그인'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('옮기기'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );
    final loggedIn = user != null && !user.isAnonymous;
    final anonymous = user != null && user.isAnonymous;

    final String accountTitle;
    final String accountSubtitle;
    if (loggedIn) {
      accountTitle = user.displayName ?? user.email ?? 'Google 계정';
      accountSubtitle = user.email ?? '';
    } else if (anonymous) {
      accountTitle = '익명 계정 (v1.1.17 이전 사용자)';
      accountSubtitle = 'Google 계정으로 연결하면 다른 기기에서도 사용할 수 있어요.';
    } else {
      accountTitle = '로그인 안 됨';
      accountSubtitle = '일정은 이 기기에만 저장됩니다. Google 로그인 시 동기화 가능.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              '계정',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                loggedIn
                    ? Icons.person
                    : anonymous
                        ? Icons.person_outline
                        : Icons.no_accounts,
              ),
            ),
            title: Text(accountTitle),
            subtitle: accountSubtitle.isEmpty ? null : Text(accountSubtitle),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: loggedIn
                ? OutlinedButton.icon(
                    onPressed: _busy ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('로그아웃'),
                  )
                : FilledButton.icon(
                    onPressed: _busy ? null : _login,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(anonymous ? 'Google 계정 연결' : 'Google 계정으로 로그인'),
                  ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '저장 방식',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(loggedIn ? Icons.cloud_done : Icons.smartphone),
            title: Text(loggedIn ? 'Google 계정에 동기화 중' : '이 기기에만 저장'),
            subtitle: Text(
              loggedIn
                  ? '여러 기기에서 같은 일정을 볼 수 있어요.'
                  : '로그인하지 않아도 일정 추가/편집이 가능합니다.',
            ),
          ),
        ],
      ),
    );
  }
}
