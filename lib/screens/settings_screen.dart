import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/todos_provider.dart';
import '../services/analytics_service.dart';

/// 계정 / 동기화 / 언어 설정.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _login() async {
    final l = AppLocalizations.of(context)!;
    if (kIsWeb) {
      _snack(l.webNoGoogleLogin);
      return;
    }
    setState(() => _busy = true);
    try {
      final localRepo = ref.read(todosRepositoryProvider);
      final localBefore = await localRepo.snapshot();
      final hasLocal = localBefore.isNotEmpty && localRepo is LocalTodosRepository;

      bool migrate = false;
      if (hasLocal && mounted) {
        migrate = await _askMigrate(localBefore.length) ?? false;
      }

      final cred = await signInWithGoogle();
      unawaited(AnalyticsService.instance.logLogin());
      unawaited(AnalyticsService.instance.setUserId(cred.user?.uid));

      if (migrate) {
        final cloudRepo = ref.read(todosRepositoryProvider);
        await cloudRepo.bulkAdd(localBefore);
        if (localRepo is LocalTodosRepository) {
          await localRepo.clearAll();
        }
        _snack(l.snackLoginMigrated(localBefore.length));
      } else {
        _snack(l.snackLoginSuccess);
      }
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _snack(l.snackLoginFailed(e.code.name));
      }
    } catch (e) {
      _snack(l.snackLoginFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await signOutCompletely();
      unawaited(AnalyticsService.instance.setUserId(null));
      _snack(l.snackLogoutSuccess);
    } catch (e) {
      _snack(l.snackLogoutFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _askMigrate(int count) {
    final l = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.migrateDialogTitle),
        content: Text(l.migrateDialogBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.migrateDeclineButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.migrateAcceptButton),
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
    final l = AppLocalizations.of(context)!;
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );
    final loggedIn = user != null && !user.isAnonymous;
    final anonymous = user != null && user.isAnonymous;
    final currentLocale = ref.watch(localeProvider);

    final String accountTitle;
    final String accountSubtitle;
    if (loggedIn) {
      accountTitle = user.displayName ?? user.email ?? 'Google';
      accountSubtitle = user.email ?? '';
    } else if (anonymous) {
      accountTitle = l.anonymousAccount;
      accountSubtitle = l.anonymousSubtitle;
    } else {
      accountTitle = l.notSignedIn;
      accountSubtitle = l.notSignedInSubtitle;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l.account,
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
                    label: Text(l.signOut),
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
                    label: Text(anonymous ? l.linkGoogle : l.signInWithGoogle),
                  ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l.storage,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(loggedIn ? Icons.cloud_done : Icons.smartphone),
            title: Text(loggedIn ? l.syncedToCloud : l.deviceOnly),
            subtitle: Text(loggedIn ? l.syncedSubtitle : l.deviceOnlySubtitle),
          ),
          if (loggedIn) _CalendarSyncSection(),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l.notifications,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _AllDayReminderTile(),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l.language,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _LanguageTile(
            label: l.languageSystem,
            selected: currentLocale == null,
            onTap: () =>
                ref.read(localeProvider.notifier).setLanguageCode(null),
          ),
          _LanguageTile(
            label: l.languageKorean,
            selected: currentLocale?.languageCode == 'ko',
            onTap: () =>
                ref.read(localeProvider.notifier).setLanguageCode('ko'),
          ),
          _LanguageTile(
            label: l.languageEnglish,
            selected: currentLocale?.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).setLanguageCode('en'),
          ),
          _LanguageTile(
            label: l.languageJapanese,
            selected: currentLocale?.languageCode == 'ja',
            onTap: () =>
                ref.read(localeProvider.notifier).setLanguageCode('ja'),
          ),
          _LanguageTile(
            label: l.languageChinese,
            selected: currentLocale?.languageCode == 'zh',
            onTap: () =>
                ref.read(localeProvider.notifier).setLanguageCode('zh'),
          ),
        ],
      ),
    );
  }
}

class _CalendarSyncSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(appSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.event_repeat),
          title: Text(l.calendarSync),
          subtitle: Text(l.calendarSyncSubtitle),
          value: s.calendarSyncEnabled,
          onChanged: (v) =>
              ref.read(appSettingsProvider.notifier).setCalendarSyncEnabled(v),
        ),
        if (s.calendarSyncEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.calendarNoTimePolicy,
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(
                      label: Text(l.calendarNoTimeAllday),
                      selected: s.calendarSyncNoTime == 'allday',
                      onSelected: (_) => ref
                          .read(appSettingsProvider.notifier)
                          .setCalendarSyncNoTime('allday'),
                    ),
                    ChoiceChip(
                      label: Text(l.calendarNoTimeSkip),
                      selected: s.calendarSyncNoTime == 'skip',
                      onSelected: (_) => ref
                          .read(appSettingsProvider.notifier)
                          .setCalendarSyncNoTime('skip'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AllDayReminderTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(appSettingsProvider);
    final timeStr =
        '${s.allDayReminderHour.toString().padLeft(2, '0')}:${s.allDayReminderMinute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: Text(l.allDayReminderTime),
      subtitle: Text(l.allDayReminderTimeSubtitle),
      trailing: Text(timeStr, style: const TextStyle(fontSize: 16)),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: s.allDayReminderHour,
            minute: s.allDayReminderMinute,
          ),
        );
        if (picked != null) {
          await ref.read(appSettingsProvider.notifier).setAllDayReminderTime(
                hour: picked.hour,
                minute: picked.minute,
              );
        }
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
    );
  }
}
