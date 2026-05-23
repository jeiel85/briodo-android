import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';
import '../theme.dart';
import '../widgets/brio_components.dart';

/// 동기부여 대시보드 — 스트릭/누적 + 주/월 미니 카드 + 주간 막대 + 12주 기여 그래프.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, this.embedded = false});

  /// MainShell의 GrowthScreen 안에 임베드되었는지 — AppBar를 띄울지 결정.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final todosAsync = ref.watch(todosStreamProvider);

    final body = todosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
      data: (todos) {
        final s = _Stats.from(todos);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            if (!embedded)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '동기부여 대시보드',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _BigStatCard(
                    icon: Icons.local_fire_department,
                    accent: BrioColors.warning,
                    container:
                        BrioColors.warningContainerOf(context),
                    label: '현재 스트릭',
                    value: '${s.streak}일',
                    sub: '계속 달려요! 🏃',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigStatCard(
                    icon: Icons.emoji_events,
                    accent: BrioColors.primary,
                    container: Theme.of(context).colorScheme.primaryContainer,
                    label: '누적 완료',
                    value: '${s.totalDone}개',
                    sub: '총 성과물!',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStat(label: '이번 주 완료', value: '${s.weekDone}개')),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(label: '이번 달 완료', value: '${s.monthDone}개')),
              ],
            ),
            const SizedBox(height: 16),
            BrioCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주간 할 일 완료율 그래프',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 130,
                    child: _WeeklyBars(values: s.weekly),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BrioCard(
              padding: const EdgeInsets.all(16),
              child: BrioContributionGraph(dailyCounts: s.daily),
            ),
          ],
        );
      },
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.stats,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: body,
    );
  }
}

class _Stats {
  _Stats({
    required this.weekDone,
    required this.monthDone,
    required this.totalDone,
    required this.streak,
    required this.daily,
    required this.weekly,
  });

  final int weekDone;
  final int monthDone;
  final int totalDone;
  final int streak;

  /// dateKey → 완료 수
  final Map<String, int> daily;

  /// 월~일 7개 카운트
  final List<int> weekly;

  static _Stats from(List<Todo> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    int weekDone = 0;
    int monthDone = 0;
    int totalDone = 0;
    final daily = <String, int>{};
    final weekly = List<int>.filled(7, 0);

    for (final t in todos) {
      if (!t.completed) continue;
      final d = parseDateKey(t.date);
      totalDone += 1;
      daily[t.date] = (daily[t.date] ?? 0) + 1;
      if (d.year == today.year && d.month == today.month) monthDone += 1;
      if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
        weekDone += 1;
        weekly[(d.weekday - 1) % 7] += 1;
      }
    }

    int streak = 0;
    for (var i = 0; i < 400; i++) {
      final d = today.subtract(Duration(days: i));
      if ((daily[dateKey(d)] ?? 0) > 0) {
        streak += 1;
      } else if (i == 0) {
        break;
      } else {
        break;
      }
    }

    return _Stats(
      weekDone: weekDone,
      monthDone: monthDone,
      totalDone: totalDone,
      streak: streak,
      daily: daily,
      weekly: weekly,
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.icon,
    required this.accent,
    required this.container,
    required this.label,
    required this.value,
    required this.sub,
  });
  final IconData icon;
  final Color accent;
  final Color container;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return BrioCard(
      backgroundColor: container,
      borderless: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: accent.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BrioCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values});
  final List<int> values;

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = values.fold<int>(0, (a, b) => a > b ? a : b);
    final peak = maxVal == 0 ? 1 : maxVal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[i] > 0 ? '${values[i]}' : '',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: BrioColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: (values[i] / peak * 100).clamp(10, 100),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                    color: values[i] > 0
                        ? BrioColors.primary
                        : cs.onSurface.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
