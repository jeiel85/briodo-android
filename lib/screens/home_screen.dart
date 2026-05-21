import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import '../providers/todos_provider.dart';
import '../services/analytics_service.dart';
import '../widgets/calendar_header.dart';
import '../widgets/todo_editor_dialog.dart';
import 'settings_screen.dart';

/// 캘린더 + 선택 날짜의 할 일 리스트.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};

  Color _priorityColor(String p, ColorScheme cs) {
    switch (p) {
      case 'urgent':
        return cs.error;
      case 'high':
        return Colors.orange;
      case 'low':
        return cs.outline;
      case 'medium':
      default:
        return cs.primary;
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Todo? initial,
  }) async {
    final repo = ref.read(todosRepositoryProvider);
    final selected = ref.read(selectedDateProvider);
    final result = await showDialog<TodoEditorResult>(
      context: context,
      builder: (_) => TodoEditorDialog(
        initial: initial,
        defaultDate: selected,
      ),
    );
    if (result == null) return;

    if (initial == null) {
      await repo.add(
        text: result.text,
        description: result.description,
        date: result.date,
        time: result.time,
        tags: result.tags,
        priority: result.priority,
      );
      unawaited(AnalyticsService.instance.logTodoCreate(
        priority: result.priority,
        tagCount: result.tags.length,
      ));
    } else {
      await repo.update(initial.copyWith(
        text: result.text,
        description: result.description,
        date: result.date,
        time: result.time,
        tags: result.tags,
        priority: result.priority,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todosAsync = ref.watch(todosStreamProvider);
    final repo = ref.read(todosRepositoryProvider);
    final selected = ref.watch(selectedDateProvider);
    final today = dateKey(DateTime.now());
    final isToday = selected == today;

    final allTodos = todosAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Todo>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrioDo'),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () => ref.read(selectedDateProvider.notifier).resetToToday(),
              child: const Text('오늘'),
            ),
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarHeader(
            selected: selected,
            todos: allTodos,
            onSelect: (date) => ref.read(selectedDateProvider.notifier).set(date),
          ),
          const Divider(height: 1),
          Expanded(
            child: todosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('오류: $err')),
              data: (todos) {
                final filtered = todos.where((t) => t.date == selected).toList()
                  ..sort(_compareTodos);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      isToday
                          ? '오늘 할 일이 없어요\n+ 버튼으로 추가하세요'
                          : '이 날짜에 할 일이 없어요',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, i) {
                    final t = filtered[i];
                    final color = _priorityColor(t.priority, theme.colorScheme);
                    final subtitleParts = <String>[
                      if (t.time.isNotEmpty) t.time,
                      ...t.tags.map((x) => '#$x'),
                    ];
                    return Dismissible(
                      key: ValueKey(t.id),
                      background: Container(
                        color: theme.colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        repo.delete(t.id);
                        unawaited(AnalyticsService.instance.logTodoDelete());
                      },
                      child: ListTile(
                        onTap: () => _openEditor(context, ref, initial: t),
                        leading: GestureDetector(
                          onTap: () {
                            repo.toggleComplete(t);
                            if (!t.completed) {
                              unawaited(AnalyticsService.instance.logTodoComplete(
                                priority: t.priority,
                              ));
                            }
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.completed ? color.withValues(alpha: 0.7) : Colors.transparent,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: t.completed
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          t.text,
                          style: t.completed
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        subtitle: subtitleParts.isEmpty
                            ? null
                            : Text(
                                subtitleParts.join('  '),
                                style: theme.textTheme.bodySmall,
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 미완료 → 시간(없는 건 뒤) → 우선순위(urgent>high>medium>low).
  int _compareTodos(Todo a, Todo b) {
    if (a.completed != b.completed) return a.completed ? 1 : -1;
    final at = a.time.isEmpty ? '99:99' : a.time;
    final bt = b.time.isEmpty ? '99:99' : b.time;
    final tc = at.compareTo(bt);
    if (tc != 0) return tc;
    final ap = _priorityOrder[a.priority] ?? 2;
    final bp = _priorityOrder[b.priority] ?? 2;
    return ap.compareTo(bp);
  }
}
