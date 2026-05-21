import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/app_settings_provider.dart';
import '../providers/todos_provider.dart';
import '../services/analytics_service.dart';
import '../services/notifications_service.dart';
import '../widgets/calendar_header.dart';
import '../widgets/todo_editor_dialog.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// todo의 알림 발송 시각.
/// time(HH:MM)이 있으면 → time - reminderOffset
/// time이 없으면(종일) → date + AppSettings.allDayReminder
/// reminderOffset < 0이면 null (예약 안 함).
DateTime? scheduleAtFor(Todo todo, AppSettings settings) {
  if (todo.reminderOffset < 0) return null;
  final dateParts = todo.date.split('-');
  if (dateParts.length != 3) return null;
  final y = int.tryParse(dateParts[0]);
  final m = int.tryParse(dateParts[1]);
  final d = int.tryParse(dateParts[2]);
  if (y == null || m == null || d == null) return null;

  if (todo.time.isEmpty) {
    return DateTime(
      y,
      m,
      d,
      settings.allDayReminderHour,
      settings.allDayReminderMinute,
    );
  }
  final timeParts = todo.time.split(':');
  if (timeParts.length < 2) return null;
  final hh = int.tryParse(timeParts[0]);
  final mm = int.tryParse(timeParts[1]);
  if (hh == null || mm == null) return null;
  final base = DateTime(y, m, d, hh, mm);
  return base.subtract(Duration(minutes: todo.reminderOffset));
}

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
      final newId = await repo.add(
        text: result.text,
        description: result.description,
        date: result.date,
        time: result.time,
        tags: result.tags,
        priority: result.priority,
        reminderOffset: result.reminderOffset,
        subtasks: result.subtasks,
        recurrence: result.recurrence,
        recurrenceEnd: result.recurrenceEnd,
      );
      unawaited(AnalyticsService.instance.logTodoCreate(
        priority: result.priority,
        tagCount: result.tags.length,
      ));
      await _rescheduleNotification(
        ref,
        Todo(
          id: newId,
          uid: '',
          text: result.text,
          description: result.description,
          date: result.date,
          time: result.time,
          tags: result.tags,
          priority: result.priority,
          reminderOffset: result.reminderOffset,
          subtasks: result.subtasks,
          recurrence: result.recurrence,
          recurrenceEnd: result.recurrenceEnd,
        ),
      );
    } else {
      final updated = initial.copyWith(
        text: result.text,
        description: result.description,
        date: result.date,
        time: result.time,
        tags: result.tags,
        priority: result.priority,
        reminderOffset: result.reminderOffset,
        subtasks: result.subtasks,
        recurrence: result.recurrence,
        recurrenceEnd: result.recurrenceEnd,
      );
      await repo.update(updated);
      await _rescheduleNotification(ref, updated);
    }
  }

  /// 반복 일정 완료 시 다음 occurrence 자동 생성.
  /// recurrence != 'none'이고 recurrenceEnd가 비어있거나 미래면 다음 날짜로 새 todo 추가.
  Future<void> _spawnNextOccurrence(WidgetRef ref, Todo t) async {
    if (t.recurrence == 'none') return;
    final repo = ref.read(todosRepositoryProvider);
    final nextDate = _nextOccurrenceDate(t.date, t.recurrence);
    if (nextDate == null) return;
    if (t.recurrenceEnd.isNotEmpty && nextDate.compareTo(t.recurrenceEnd) > 0) {
      return;
    }
    await repo.add(
      text: t.text,
      description: t.description,
      date: nextDate,
      time: t.time,
      tags: t.tags,
      priority: t.priority,
      reminderOffset: t.reminderOffset,
      subtasks: t.subtasks
          .map((s) => s.copyWith(completed: false))
          .toList(),
      recurrence: t.recurrence,
      recurrenceEnd: t.recurrenceEnd,
    );
  }

  /// recurrence 규칙으로 다음 날짜 계산 (YYYY-MM-DD).
  String? _nextOccurrenceDate(String date, String recurrence) {
    final base = parseDateKey(date);
    switch (recurrence) {
      case 'daily':
        return dateKey(base.add(const Duration(days: 1)));
      case 'weekly':
        return dateKey(base.add(const Duration(days: 7)));
      case 'monthly':
        final n = DateTime(base.year, base.month + 1, base.day);
        return dateKey(n);
      default:
        return null;
    }
  }

  /// reminderOffset/time 조건이 맞으면 새로 스케줄, 아니면 취소.
  /// 권한이 없으면 한 번 요청한다.
  Future<void> _rescheduleNotification(WidgetRef ref, Todo todo) async {
    final ns = NotificationsService.instance;
    if (todo.completed) {
      unawaited(ns.cancel(todo.id));
      return;
    }
    final settings = ref.read(appSettingsProvider);
    final when = scheduleAtFor(todo, settings);
    if (when == null || when.isBefore(DateTime.now())) {
      unawaited(ns.cancel(todo.id));
      return;
    }
    final granted = await ns.isPermissionGranted();
    if (!granted) {
      final ok = await ns.requestPermission();
      if (!ok) return;
    }
    await ns.scheduleTodo(
      todoId: todo.id,
      title: todo.text,
      body: todo.description.isEmpty ? todo.time : todo.description,
      when: when,
      priority: todo.priority,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
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
        title: Text(l.appTitle),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () => ref.read(selectedDateProvider.notifier).resetToToday(),
              child: Text(l.today),
            ),
          IconButton(
            tooltip: l.search,
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SearchScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: l.settings,
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
              error: (err, _) => Center(child: Text(l.errorPrefix(err.toString()))),
              data: (todos) {
                final filtered = todos.where((t) => t.date == selected).toList()
                  ..sort(_compareTodos);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      isToday ? l.noTodosToday : l.noTodosOnDate,
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
                    final subDone = t.subtasks.where((s) => s.completed).length;
                    final subTotal = t.subtasks.length;
                    final subtitleParts = <String>[
                      if (t.time.isNotEmpty) t.time,
                      if (subTotal > 0)
                        l.subtaskProgress(subDone, subTotal),
                      if (t.recurrence != 'none')
                        _recurrenceShort(l, t.recurrence),
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
                        unawaited(NotificationsService.instance.cancel(t.id));
                        unawaited(AnalyticsService.instance.logTodoDelete());
                      },
                      child: ListTile(
                        onTap: () => _openEditor(context, ref, initial: t),
                        leading: GestureDetector(
                          onTap: () {
                            repo.toggleComplete(t);
                            if (!t.completed) {
                              unawaited(NotificationsService.instance.cancel(t.id));
                              unawaited(AnalyticsService.instance.logTodoComplete(
                                priority: t.priority,
                              ));
                              unawaited(_spawnNextOccurrence(ref, t));
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

  String _recurrenceShort(AppLocalizations l, String r) {
    switch (r) {
      case 'daily':
        return '↻ ${l.recurrenceDaily}';
      case 'weekly':
        return '↻ ${l.recurrenceWeekly}';
      case 'monthly':
        return '↻ ${l.recurrenceMonthly}';
      default:
        return '';
    }
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
