import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 생산성 통계: contribution graph (최근 20주) + streak + 주/월 완료 수 + 우선순위 분포.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.stats)),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
        data: (todos) {
          final stats = _StatsModel.build(todos);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l.statsThisWeek,
                      value: '${stats.weekDone}',
                      sub: l.statsCompleted,
                      color: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: l.statsThisMonth,
                      value: '${stats.monthDone}',
                      sub: l.statsCompleted,
                      color: theme.colorScheme.secondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l.statsStreak,
                      value: l.streakDays(stats.streak),
                      sub: '',
                      color: theme.colorScheme.tertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: l.statsTotal,
                      value: '${stats.totalDone}',
                      sub: l.statsCompleted,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l.statsContribution, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _ContributionGrid(stats: stats),
              const SizedBox(height: 24),
              _WeeklyBarChart(stats: stats),
            ],
          );
        },
      ),
    );
  }
}

class _StatsModel {
  _StatsModel({
    required this.weekDone,
    required this.monthDone,
    required this.totalDone,
    required this.streak,
    required this.dailyCounts,
    required this.last7Days,
  });

  final int weekDone;
  final int monthDone;
  final int totalDone;
  final int streak;

  /// dateKey → 완료 수 (최근 20주)
  final Map<String, int> dailyCounts;

  /// 최근 7일 완료 수 (오늘이 마지막)
  final List<int> last7Days;

  static _StatsModel build(List<Todo> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daily = <String, int>{};
    int weekDone = 0;
    int monthDone = 0;
    int totalDone = 0;

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    for (final t in todos) {
      if (!t.completed) continue;
      final d = parseDateKey(t.date);
      totalDone += 1;
      if (d.year == today.year && d.month == today.month) {
        monthDone += 1;
      }
      if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
        weekDone += 1;
      }
      daily[t.date] = (daily[t.date] ?? 0) + 1;
    }

    // streak: 오늘부터 거꾸로 — 완료 todo가 있는 날이 연속되는 동안 +1
    int streak = 0;
    for (var i = 0; i < 400; i++) {
      final d = today.subtract(Duration(days: i));
      if ((daily[dateKey(d)] ?? 0) > 0) {
        streak += 1;
      } else if (i == 0) {
        // 오늘 안 한 경우 streak 0 (기존 streak 깨짐).
        break;
      } else {
        break;
      }
    }

    final last7Days = List<int>.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return daily[dateKey(d)] ?? 0;
    });

    return _StatsModel(
      weekDone: weekDone,
      monthDone: monthDone,
      totalDone: totalDone,
      streak: streak,
      dailyCounts: daily,
      last7Days: last7Days,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium),
          const SizedBox(height: 8),
          Text(value, style: t.headlineSmall),
          if (sub.isNotEmpty) Text(sub, style: t.bodySmall),
        ],
      ),
    );
  }
}

class _ContributionGrid extends StatelessWidget {
  const _ContributionGrid({required this.stats});

  final _StatsModel stats;

  Color _cellColor(int count, ColorScheme cs) {
    if (count <= 0) return cs.surfaceContainerHighest;
    if (count == 1) return cs.primary.withValues(alpha: 0.3);
    if (count == 2) return cs.primary.withValues(alpha: 0.55);
    if (count <= 4) return cs.primary.withValues(alpha: 0.8);
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 20주 = 140일. 그리드는 7행 x 20열, 좌→우 시간순.
    const weeks = 20;
    final start = today.subtract(Duration(days: weeks * 7 - 1));
    return AspectRatio(
      aspectRatio: weeks / 7 * 1.2,
      child: LayoutBuilder(
        builder: (_, c) {
          final cellSize = (c.maxWidth - (weeks - 1) * 3) / weeks;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var w = 0; w < weeks; w++) ...[
                Column(
                  children: [
                    for (var dow = 0; dow < 7; dow++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: () {
                          final d = start.add(Duration(days: w * 7 + dow));
                          if (d.isAfter(today)) {
                            return SizedBox(
                              width: cellSize,
                              height: cellSize,
                            );
                          }
                          final count = stats.dailyCounts[dateKey(d)] ?? 0;
                          return Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: _cellColor(count, cs),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }(),
                      ),
                  ],
                ),
                if (w < weeks - 1) const SizedBox(width: 3),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.stats});

  final _StatsModel stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxY = stats.last7Days.isEmpty
        ? 1.0
        : (stats.last7Days.reduce((a, b) => a > b ? a : b).toDouble() + 1);
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final d = today.subtract(Duration(days: 6 - v.toInt()));
                  const wd = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      wd[(d.weekday - 1) % 7],
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < stats.last7Days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: stats.last7Days[i].toDouble(),
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                    color: cs.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
