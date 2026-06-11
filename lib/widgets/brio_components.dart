import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../providers/todos_provider.dart' show dateKey;
import '../theme.dart';

/// briodo-renew의 BrioCard. 외곽선이 약하게 잡힌 카드.
class BrioCard extends StatelessWidget {
  const BrioCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.borderless = false,
    this.elevation = 0,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// 컨테이너성 카드(primaryContainer 등)는 외곽선이 거추장스러우니 borderless=true.
  final bool borderless;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surface;
    final radius = BorderRadius.circular(16);
    return Material(
      color: bg,
      elevation: elevation,
      shadowColor: cs.shadow.withValues(alpha: 0.06),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: borderless
                ? null
                : Border.all(
                    color: cs.outlineVariant,
                    width: 0.6,
                  ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// 우선순위 알약. (낮음/보통/높음/긴급)
class BrioPriorityPill extends StatelessWidget {
  const BrioPriorityPill({super.key, required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final ctx = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (priority) {
      case 'low':
        bg = Theme.of(context).colorScheme.secondaryContainer;
        fg = isDark
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : BrioColors.secondary;
        label = '낮음';
        break;
      case 'high':
        bg = BrioColors.warningContainerOf(ctx);
        fg = BrioColors.warning;
        label = '높음';
        break;
      case 'urgent':
        bg = BrioColors.urgentContainerOf(ctx);
        fg = BrioColors.urgent;
        label = '긴급';
        break;
      case 'medium':
      default:
        bg = Theme.of(context).colorScheme.primaryContainer;
        fg = isDark
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : BrioColors.primary;
        label = '보통';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// 태그 칩 (#tagname).
class BrioTagChip extends StatelessWidget {
  const BrioTagChip({super.key, required this.tag, this.onTap});
  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_outline, size: 10, color: cs.primary),
            const SizedBox(width: 4),
            Text(
              tag,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 빈 상태 패널 — 큰 아이콘 + 제목 + 부제.
class BrioEmptyState extends StatelessWidget {
  const BrioEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String title;
  final String subtitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          icon ??
              Icon(
                Icons.check_circle_outline,
                size: 54,
                color: cs.primary.withValues(alpha: 0.35),
              ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Todo 한 줄을 표현하는 카드형 타일.
/// - 원형 체크박스 (success 색)
/// - 우선순위 알약
/// - 서브태스크 인라인 체크
/// - 시간/반복/태그 푸터 칩
class BrioTodoTile extends StatelessWidget {
  const BrioTodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    this.onDelete,
    this.onSubtaskToggle,
    this.calendarSynced = false,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final void Function(int index)? onSubtaskToggle;
  final bool calendarSynced;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final faded = todo.completed;

    return BrioCard(
      backgroundColor: faded
          ? cs.surface.withValues(alpha: 0.7)
          : cs.surface,
      elevation: faded ? 0 : 0.5,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 동그란 체크박스
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.completed ? BrioColors.success : Colors.transparent,
                  border: Border.all(
                    color: todo.completed
                        ? BrioColors.success
                        : cs.primary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: todo.completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          ),
          // 본문
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todo.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: todo.completed
                              ? cs.onSurface.withValues(alpha: 0.45)
                              : cs.onSurface,
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BrioPriorityPill(priority: todo.priority),
                  ],
                ),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                if (todo.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  for (var i = 0; i < todo.subtasks.length; i++)
                    InkWell(
                      onTap: onSubtaskToggle == null
                          ? null
                          : () => onSubtaskToggle!(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              todo.subtasks[i].completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 13,
                              color: todo.subtasks[i].completed
                                  ? BrioColors.success
                                  : cs.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                todo.subtasks[i].text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: todo.subtasks[i].completed
                                      ? cs.onSurface.withValues(alpha: 0.35)
                                      : cs.onSurface.withValues(alpha: 0.7),
                                  decoration: todo.subtasks[i].completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                // 푸터 칩들
                if (_hasFooter(todo)) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (todo.time.isNotEmpty)
                        _IconText(
                          icon: Icons.access_time,
                          text: todo.time,
                          color: cs.primary,
                        ),
                      if (todo.recurrence != 'none')
                        _IconText(
                          icon: Icons.autorenew,
                          text: _recLabel(todo.recurrence),
                          color: BrioColors.secondary,
                        ),
                      if (calendarSynced)
                        _IconText(
                          icon: Icons.cloud_queue,
                          text: 'GCal',
                          color: BrioColors.success,
                        ),
                      ...todo.tags.map((t) => BrioTagChip(tag: t)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: '삭제',
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: cs.error.withValues(alpha: 0.55),
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  static bool _hasFooter(Todo t) =>
      t.time.isNotEmpty || t.recurrence != 'none' || t.tags.isNotEmpty;

  static String _recLabel(String r) {
    switch (r) {
      case 'daily':
        return '매일';
      case 'weekly':
        return '매주';
      case 'monthly':
        return '매월';
      default:
        return '';
    }
  }
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 세그먼트 풀(필터 등). 내부 padding 4, 셀 padding 8.
class BrioSegmentTabs<T> extends StatelessWidget {
  const BrioSegmentTabs({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  final T value;
  final ValueChanged<T> onChanged;

  /// (값, 라벨)
  final List<(T, String)> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final entry in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        value == entry.$1 ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      entry.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: value == entry.$1
                            ? Colors.white
                            : cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 14일 캘린더 리본. 가로 스크롤 가능.
class BrioCalendarRibbon extends StatelessWidget {
  const BrioCalendarRibbon({
    super.key,
    required this.selectedDate,
    required this.todos,
    required this.onSelect,
    this.daysBefore = 5,
    this.daysAfter = 8,
  });

  /// YYYY-MM-DD
  final String selectedDate;
  final List<Todo> todos;
  final ValueChanged<String> onSelect;
  final int daysBefore;
  final int daysAfter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final start = today.subtract(Duration(days: daysBefore));
    final total = daysBefore + daysAfter + 1;
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: total,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = start.add(Duration(days: i));
          final key = dateKey(d);
          final isSelected = key == selectedDate;
          final isToday = key == dateKey(today);
          final hasTodos = todos.any((t) => t.date == key);
          final bg = isSelected ? cs.primary : cs.surface;
          final fg = isSelected ? Colors.white : cs.onSurface;
          final subColor = isSelected
              ? Colors.white.withValues(alpha: 0.8)
              : cs.onSurface.withValues(alpha: 0.45);

          return GestureDetector(
            onTap: () => onSelect(key),
            child: Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isToday
                          ? cs.primary.withValues(alpha: 0.6)
                          : cs.outlineVariant,
                  width: isToday && !isSelected ? 1.2 : 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[(d.weekday - 1) % 7],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: subColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasTodos
                          ? (isSelected
                              ? Colors.white
                              : cs.primary.withValues(alpha: 0.7))
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// GitHub 스타일 12주 기여 그래프.
class BrioContributionGraph extends StatelessWidget {
  const BrioContributionGraph({
    super.key,
    required this.dailyCounts,
    this.weeks = 12,
  });

  final Map<String, int> dailyCounts;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final totalDays = weeks * 7;
    final start = todayDay.subtract(Duration(days: totalDays - 1));

    final dayLabels = ['일', '', '화', '', '목', '', '토'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 $weeks주 완수 기록',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (_, c) {
            final gridWidth = c.maxWidth - 22;
            double cellSize = (gridWidth - (weeks - 1) * 3) / weeks;
            if (cellSize > 14.0) {
              cellSize = 14.0;
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    for (final label in dayLabels)
                      Container(
                        width: 18,
                        height: cellSize,
                        margin: const EdgeInsets.only(bottom: 3),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                for (var w = 0; w < weeks; w++) ...[
                  Column(
                    children: [
                      for (var dow = 0; dow < 7; dow++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: () {
                            final d =
                                start.add(Duration(days: w * 7 + dow));
                            if (d.isAfter(todayDay)) {
                              return SizedBox(
                                width: cellSize,
                                height: cellSize,
                              );
                            }
                            final count = dailyCounts[dateKey(d)] ?? 0;
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
      ],
    );
  }

  Color _cellColor(int count, ColorScheme cs) {
    if (count <= 0) return cs.onSurface.withValues(alpha: 0.05);
    if (count == 1) return BrioColors.success.withValues(alpha: 0.3);
    if (count == 2) return BrioColors.success.withValues(alpha: 0.55);
    if (count == 3) return BrioColors.success.withValues(alpha: 0.8);
    return BrioColors.success;
  }
}
