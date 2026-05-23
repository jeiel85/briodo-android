import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievements.dart';
import '../models/achievement.dart';
import '../providers/achievements_provider.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';
import '../widgets/brio_components.dart';

/// 업적 모달 — 진행률 카드 + 카테고리 세그먼트 + 배지 카드.
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key, this.embedded = false});

  /// MainShell의 GrowthScreen 안에 임베드되었는지 — AppBar를 띄울지 결정.
  final bool embedded;

  @override
  ConsumerState<AchievementsScreen> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  String _filter = 'all';

  static const _topCategories = [
    ('all', '전체'),
    (AchievementCategory.completion, '성취'),
    (AchievementCategory.streak, '스트릭'),
    (AchievementCategory.special, '특별'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementsProvider);
    final cs = Theme.of(context).colorScheme;
    final localeCode = ref.watch(localeProvider)?.languageCode ?? 'ko';

    final filtered = _filter == 'all'
        ? kAchievementDefs
        : kAchievementDefs.where((d) => d.category == _filter).toList();

    final unlockedCount =
        kAchievementDefs.where((d) => state.unlocked.contains(d.id)).length;
    final progress = unlockedCount / kAchievementDefs.length;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        if (!widget.embedded)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '명예의 전당 (Brio 배지)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        // Progress hero
        BrioCard(
          backgroundColor: cs.secondaryContainer,
          borderless: true,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BrioDo 업적 부스터',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: cs.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '열린 훈장: $unlockedCount / ${kAchievementDefs.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}% 정복',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      BrioColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '업적을 해제할 때마다 활기찬 동력원이 공급됩니다! 🌟',
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BrioSegmentTabs<String>(
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
          items: _topCategories.toList(),
        ),
        const SizedBox(height: 12),
        for (final d in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BadgeCard(
              def: d,
              unlocked: state.unlocked.contains(d.id),
              localeCode: localeCode,
            ),
          ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '업적',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: body,
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.def,
    required this.unlocked,
    required this.localeCode,
  });
  final AchievementDef def;
  final bool unlocked;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BrioCard(
      backgroundColor:
          unlocked ? cs.surface : cs.surface.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? cs.secondaryContainer
                  : cs.onSurface.withValues(alpha: 0.05),
            ),
            alignment: Alignment.center,
            child: Text(
              def.icon,
              style: TextStyle(
                fontSize: 24,
                color: unlocked
                    ? null
                    : cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  def.name.forLocale(localeCode),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: unlocked
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  def.desc.forLocale(localeCode),
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: unlocked
                  ? BrioColors.successContainerOf(context)
                  : cs.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unlocked ? '잠금해제 ✨' : '잠김 🔒',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: unlocked
                    ? BrioColors.success
                    : cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
