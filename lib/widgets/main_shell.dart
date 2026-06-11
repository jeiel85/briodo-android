import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/achievement.dart';
import '../providers/achievements_provider.dart';
import '../providers/locale_provider.dart';
import '../screens/achievements_screen.dart';
import '../screens/all_view_screen.dart';
import '../screens/home_screen.dart';
import '../screens/lists_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../theme.dart';
import 'todo_editor_sheet.dart';

/// 5탭 BottomNav 메인 셸.
/// 탭: 홈 / 전체 / 태그 / 성장(통계+업적) / 설정
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 업적 잠금 해제 스트림 listen — 홈 탭이 아니어도 알림이 보이도록 셸에서 처리.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(achievementsProvider.notifier).unlockStream.listen(_onUnlock);
    });
  }

  void _onUnlock(AchievementDef def) {
    if (!mounted) return;
    final localeCode = ref.read(localeProvider)?.languageCode ?? 'ko';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(def.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(def.name.forLocale(localeCode)),
                  Text(def.desc.forLocale(localeCode),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToTab(int i) => setState(() => _index = i);

  Future<void> _openQuickAdd() async {
    await openTodoEditorSheet(context, ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final bodyContent = IndexedStack(
      index: _index,
      children: [
        HomeScreen(onTagToHome: _goToTab),
        const AllViewScreen(),
        ListsScreen(onSelectTagDate: (date) {
          // 태그에서 날짜를 누르면 홈 탭으로 점프 → HomeScreen이 selectedDate를 듣고 있음.
          _goToTab(0);
        }),
        const GrowthScreen(),
        const SettingsScreen(),
      ],
    );

    return Scaffold(
      body: isLandscape
          ? Row(
              children: [
                Expanded(child: bodyContent),
                const VerticalDivider(width: 1, thickness: 0.6),
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _goToTab,
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('홈'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.format_list_bulleted_outlined),
                      selectedIcon: Icon(Icons.format_list_bulleted),
                      label: Text('전체'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.label_outline),
                      selectedIcon: Icon(Icons.label),
                      label: Text('태그'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      selectedIcon: Icon(Icons.emoji_events),
                      label: Text('성장'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: Text(l.settings),
                    ),
                  ],
                ),
              ],
            )
          : bodyContent,
      bottomNavigationBar: isLandscape
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _goToTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: '홈',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.format_list_bulleted_outlined),
                  selectedIcon: Icon(Icons.format_list_bulleted),
                  label: '전체',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.label_outline),
                  selectedIcon: Icon(Icons.label),
                  label: '태그',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: '성장',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l.settings,
                ),
              ],
            ),
      floatingActionButton: (_index == 0 || _index == 1)
          ? FloatingActionButton.extended(
              onPressed: _openQuickAdd,
              icon: const Icon(Icons.add),
              label: const Text(
                '빠른 추가',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          : null,
      floatingActionButtonLocation: isLandscape
          ? FloatingActionButtonLocation.startFloat
          : null,
      // Search bar는 홈 탭의 AppBar에서.
    );
  }
}

/// 통계 + 업적을 하나의 탭에 합친 화면.
class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  String _mode = 'stats';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '성장',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _GrowthTabButton(
                    icon: Icons.timeline,
                    label: '활동 통계',
                    selected: _mode == 'stats',
                    color: cs.primary,
                    onTap: () => setState(() => _mode = 'stats'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GrowthTabButton(
                    icon: Icons.emoji_events,
                    label: '업적 배지',
                    selected: _mode == 'achievements',
                    color: BrioColors.secondary,
                    onTap: () => setState(() => _mode = 'achievements'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _mode == 'stats'
                ? const StatsScreen(embedded: true)
                : const AchievementsScreen(embedded: true),
          ),
        ],
      ),
    );
  }
}

class _GrowthTabButton extends StatelessWidget {
  const _GrowthTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : cs.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
