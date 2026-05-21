import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';

enum _Range { all, month, week }

/// 모든 할 일 한 화면. 기간 필터 + 날짜별 그룹.
class AllViewScreen extends ConsumerStatefulWidget {
  const AllViewScreen({super.key});

  @override
  ConsumerState<AllViewScreen> createState() => _AllViewScreenState();
}

class _AllViewScreenState extends ConsumerState<AllViewScreen> {
  _Range _range = _Range.all;

  bool _inRange(Todo t) {
    if (_range == _Range.all) return true;
    final d = parseDateKey(t.date);
    final now = DateTime.now();
    if (_range == _Range.month) {
      return d.year == now.year && d.month == now.month;
    }
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return !d.isBefore(start) && d.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.allView)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<_Range>(
              segments: [
                ButtonSegment(value: _Range.all, label: Text(l.filterAll)),
                ButtonSegment(
                    value: _Range.month, label: Text(l.filterMonth)),
                ButtonSegment(value: _Range.week, label: Text(l.filterWeek)),
              ],
              selected: {_range},
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: todosAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l.errorPrefix(e.toString()))),
              data: (todos) {
                final filtered = todos.where(_inRange).toList()
                  ..sort((a, b) {
                    final c = a.date.compareTo(b.date);
                    if (c != 0) return c;
                    final at = a.time.isEmpty ? '99:99' : a.time;
                    final bt = b.time.isEmpty ? '99:99' : b.time;
                    return at.compareTo(bt);
                  });
                if (filtered.isEmpty) {
                  return Center(child: Text(l.noTodos));
                }
                final grouped = <String, List<Todo>>{};
                for (final t in filtered) {
                  grouped.putIfAbsent(t.date, () => []).add(t);
                }
                final entries = grouped.entries.toList();
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    final isToday = e.key == dateKey(DateTime.now());
                    return _DateGroup(
                      date: e.key,
                      todos: e.value,
                      highlight: isToday,
                      theme: theme,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.todos,
    required this.highlight,
    required this.theme,
  });

  final String date;
  final List<Todo> todos;
  final bool highlight;
  final ThemeData theme;

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent':
        return theme.colorScheme.error;
      case 'high':
        return Colors.orange;
      case 'low':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          color: theme.colorScheme.surface,
          child: Text(
            date,
            style: theme.textTheme.titleSmall?.copyWith(
              color: highlight
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        for (final t in todos)
          ListTile(
            dense: true,
            leading: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _priorityColor(t.priority).withValues(alpha: 0.7),
              ),
            ),
            title: Text(
              t.text,
              style: t.completed
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.outline,
                    )
                  : null,
            ),
            subtitle: [
              if (t.time.isNotEmpty) t.time,
              ...t.tags.map((x) => '#$x'),
            ].isEmpty
                ? null
                : Text([
                    if (t.time.isNotEmpty) t.time,
                    ...t.tags.map((x) => '#$x'),
                  ].join('  ')),
          ),
      ],
    );
  }
}
