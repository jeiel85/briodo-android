import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/todos_provider.dart';

/// 첫 실행 시 PageView로 노출.
/// 끝나면 SharedPreferences에 'onboarding.done' = true 저장.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding.done', true);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final pages = [
      _OnboardPage(
        icon: '👋',
        title: l.onboardTitle1,
        body: l.onboardBody1,
        bg: theme.colorScheme.primaryContainer,
      ),
      _OnboardPage(
        icon: '📅',
        title: l.onboardTitle2,
        body: l.onboardBody2,
        bg: theme.colorScheme.secondaryContainer,
      ),
      _OnboardPage(
        icon: '☁️',
        title: l.onboardTitle3,
        body: l.onboardBody3,
        bg: theme.colorScheme.tertiaryContainer,
      ),
      _OnboardPage(
        icon: '🏆',
        title: l.onboardTitle4,
        body: l.onboardBody4,
        bg: theme.colorScheme.surfaceContainerHighest,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l.onboardSkip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () {
                  if (_page < pages.length - 1) {
                    _pc.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    );
                  } else {
                    _finish();
                  }
                },
                child: Text(
                    _page < pages.length - 1 ? l.onboardNext : l.onboardStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.bg,
  });

  final String icon;
  final String title;
  final String body;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
