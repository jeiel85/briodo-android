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
import '../theme.dart';
import '../widgets/brio_components.dart';

/// 계정 / 동기화 / 알림 / 개인화 설정 — BrioCard 섹션으로 묶었다.
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
      final hasLocal =
          localBefore.isNotEmpty && localRepo is LocalTodosRepository;

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
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );
    final loggedIn = user != null && !user.isAnonymous;
    final anonymous = user != null && user.isAnonymous;
    final settings = ref.watch(appSettingsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.settings,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _SectionHeader(l.account),
          BrioCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!loggedIn && !anonymous) ...[
                  Text(
                    l.notSignedIn,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.notSignedInSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _login,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: Text(l.signInWithGoogle),
                  ),
                ] else if (anonymous) ...[
                  Text(
                    l.anonymousAccount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.anonymousSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _login,
                    icon: const Icon(Icons.link),
                    label: Text(l.linkGoogle),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? user.email ?? 'Google',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if ((user.email ?? '').isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.email!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              l.syncedToCloud,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: BrioColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _busy ? null : _logout,
                        child: Text(l.signOut),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (loggedIn) ...[
            const SizedBox(height: 16),
            _SectionHeader('Google Calendar'),
            BrioCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.event_repeat),
                    title: Text(
                      l.calendarSync,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(l.calendarSyncSubtitle),
                    value: settings.calendarSyncEnabled,
                    onChanged: (v) => ref
                        .read(appSettingsProvider.notifier)
                        .setCalendarSyncEnabled(v),
                  ),
                  if (settings.calendarSyncEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.calendarNoTimePolicy,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              ChoiceChip(
                                label: Text(l.calendarNoTimeAllday),
                                selected:
                                    settings.calendarSyncNoTime == 'allday',
                                onSelected: (_) => ref
                                    .read(appSettingsProvider.notifier)
                                    .setCalendarSyncNoTime('allday'),
                              ),
                              ChoiceChip(
                                label: Text(l.calendarNoTimeSkip),
                                selected:
                                    settings.calendarSyncNoTime == 'skip',
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
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionHeader(l.notifications),
          BrioCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(
                    l.allDayReminderTime,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(l.allDayReminderTimeSubtitle),
                  trailing: Text(
                    '${settings.allDayReminderHour.toString().padLeft(2, '0')}:${settings.allDayReminderMinute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.allDayReminderHour,
                        minute: settings.allDayReminderMinute,
                      ),
                    );
                    if (picked != null) {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setAllDayReminderTime(
                            hour: picked.hour,
                            minute: picked.minute,
                          );
                    }
                  },
                ),
                Divider(
                  color: cs.outlineVariant,
                  thickness: 0.6,
                  height: 0,
                  indent: 16,
                  endIndent: 16,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_paused_outlined),
                  title: Text(
                    l.statusBarOngoing,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(l.statusBarOngoingSubtitle),
                  value: settings.statusBarOngoingEnabled,
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setStatusBarOngoingEnabled(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('테마 & 글꼴'),
          BrioCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.themeMode,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'system', label: Text(l.themeSystem)),
                    ButtonSegment(value: 'light', label: Text(l.themeLight)),
                    ButtonSegment(value: 'dark', label: Text(l.themeDark)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => ref
                      .read(appSettingsProvider.notifier)
                      .setThemeMode(s.first),
                ),
                const SizedBox(height: 16),
                Text(l.fontSize,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 6),
                SegmentedButton<double>(
                  segments: [
                    ButtonSegment(value: 0.9, label: Text(l.fontSizeSmall)),
                    ButtonSegment(value: 1.0, label: Text(l.fontSizeMedium)),
                    ButtonSegment(value: 1.15, label: Text(l.fontSizeLarge)),
                    ButtonSegment(value: 1.3, label: Text(l.fontSizeXLarge)),
                  ],
                  selected: {settings.fontScale},
                  onSelectionChanged: (s) => ref
                      .read(appSettingsProvider.notifier)
                      .setFontScale(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(l.completeMode),
          BrioCard(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'toggle', label: Text(l.completeToggle)),
                ButtonSegment(
                    value: 'delete', label: Text(l.completeDelete)),
              ],
              selected: {settings.completeMode},
              onSelectionChanged: (s) => ref
                  .read(appSettingsProvider.notifier)
                  .setCompleteMode(s.first),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(l.language),
          BrioCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                _LangTile(
                  label: l.languageSystem,
                  selected: currentLocale == null,
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLanguageCode(null),
                ),
                _LangTile(
                  label: l.languageKorean,
                  selected: currentLocale?.languageCode == 'ko',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLanguageCode('ko'),
                ),
                _LangTile(
                  label: l.languageEnglish,
                  selected: currentLocale?.languageCode == 'en',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLanguageCode('en'),
                ),
                _LangTile(
                  label: l.languageJapanese,
                  selected: currentLocale?.languageCode == 'ja',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLanguageCode('ja'),
                ),
                _LangTile(
                  label: l.languageChinese,
                  selected: currentLocale?.languageCode == 'zh',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLanguageCode('zh'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: cs.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
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
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? cs.primary : null,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
    );
  }
}
