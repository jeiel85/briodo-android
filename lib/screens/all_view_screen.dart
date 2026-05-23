import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';
import '../services/todo_actions.dart';
import '../theme.dart';
import '../widgets/brio_components.dart';
import '../widgets/todo_editor_sheet.dart';

enum _Range { all, month, week }

/// 모든 할 일 한 화면. 기간 필터 + 날짜 타임라인 그룹.
class AllViewScreen extends ConsumerStatefulWidget {
  const AllViewScreen({super.key});

  @override
  ConsumerState<AllViewScreen> createState() => _AllViewScreenState();
}

class _AllViewScreenState extends ConsumerState<AllViewScreen> {
  _Range _range = _Range.all;
  late final TodoActions _actions = TodoActions(ref);

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
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.allView,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: BrioSegmentTabs<_Range>(
              value: _range,
              onChanged: (v) => setState(() => _range = v),
              items: [
                (_Range.all, l.filterAll),
                (_Range.month, l.filterMonth),
                (_Range.week, l.filterWeek),
              ],
            ),
          ),
          Expanded(
            child: todosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                  return BrioEmptyState(
                    title: '해당하는 할 일이 없습니다',
                    subtitle: '루틴을 추가해 BrioDo 캘린더를 풍성하게 메워보세요!',
                    icon: Icon(
                      Icons.event_busy,
                      size: 54,
                      color: cs.primary.withValues(alpha: 0.35),
                    ),
                  );
                }
                final grouped = <String, List<Todo>>{};
                for (final t in filtered) {
                  grouped.putIfAbsent(t.date, () => []).add(t);
                }
                final entries = grouped.entries.toList();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    return _DateGroup(
                      date: e.key,
                      todos: e.value,
                      onTap: (t) => openTodoEditorSheet(
                        context,
                        ref: ref,
                        initial: t,
                      ),
                      onToggle: _actions.toggle,
                      onDelete: _actions.delete,
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
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final String date;
  final List<Todo> todos;
  final void Function(Todo) onTap;
  final void Function(Todo) onToggle;
  final void Function(Todo) onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isToday = date == dateKey(DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 헤더
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? BrioColors.primary : cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${todos.length}개)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 세로 라인
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 2,
                    color: cs.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (final t in todos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BrioTodoTile(
                            todo: t,
                            onToggle: () => onToggle(t),
                            onTap: () => onTap(t),
                            onDelete: () => onDelete(t),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
