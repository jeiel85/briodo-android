import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievements.dart';
import '../models/achievement.dart';
import '../providers/achievements_provider.dart';
import '../providers/locale_provider.dart';

/// 업적 모달 — 잠금 해제된 것 + 미해제 + 카테고리 필터.
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  String _filter = 'all'; // 'all' | category id

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(achievementsProvider);
    final localeCode = ref.watch(localeProvider)?.languageCode ?? 'ko';

    final filtered = _filter == 'all'
        ? kAchievementDefs
        : kAchievementDefs.where((d) => d.category == _filter).toList();

    final unlockedCount =
        kAchievementDefs.where((d) => state.unlocked.contains(d.id)).length;
    final progress = unlockedCount / kAchievementDefs.length;

    return Scaffold(
      appBar: AppBar(title: const Text('🏆')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$unlockedCount / ${kAchievementDefs.length}',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(
                  label: 'All',
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                for (final cat in AchievementCategory.all)
                  _Chip(
                    label: _categoryLabel(cat),
                    selected: _filter == cat,
                    onTap: () => setState(() => _filter = cat),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final def = filtered[i];
                final unlocked = state.unlocked.contains(def.id);
                return ListTile(
                  leading: Text(
                    def.icon,
                    style: TextStyle(
                      fontSize: 28,
                      color: unlocked
                          ? null
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  title: Text(
                    def.name.forLocale(localeCode),
                    style: TextStyle(
                      color: unlocked
                          ? null
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  subtitle: Text(def.desc.forLocale(localeCode)),
                  trailing: unlocked
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : Icon(Icons.lock_outline,
                          color: theme.colorScheme.outline),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String c) {
    switch (c) {
      case 'streak':
        return '🔥';
      case 'completion':
        return '✅';
      case 'daily':
        return '☀️';
      case 'weekly':
        return '📊';
      case 'recurrence':
        return '🔄';
      case 'tag':
        return '🏷️';
      case 'subtask':
        return '☑️';
      case 'priority':
        return '⚡';
      case 'calendar':
        return '📆';
      case 'notes':
        return '📝';
      case 'special':
        return '🎉';
      case 'engagement':
        return '🌟';
      default:
        return c;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
