import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import '../providers/achievements_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/todos_provider.dart';
import 'analytics_service.dart';
import 'calendar_sync_service.dart';
import 'notifications_service.dart';

/// Todo의 토글/삭제 같은 변경에 따라붙는 부가 효과(알림 취소, 반복 occurrence 생성,
/// analytics, 캘린더 동기화, 업적 체크)를 한 곳에서 관리한다.
///
/// 모든 화면(HomeScreen / AllViewScreen / SearchScreen)이 같은 동작을 따라가도록
/// 여기로 위임한다.
class TodoActions {
  TodoActions(this.ref);
  final WidgetRef ref;

  /// 체크박스 토글. completeMode 가 'delete' 면 완료 시 즉시 삭제 처리.
  Future<void> toggle(Todo t) async {
    final repo = ref.read(todosRepositoryProvider);
    final completeMode = ref.read(appSettingsProvider).completeMode;

    if (completeMode == 'delete' && !t.completed) {
      await repo.delete(t.id);
      unawaited(NotificationsService.instance.cancel(t.id));
      unawaited(AnalyticsService.instance
          .logTodoComplete(priority: t.priority));
      unawaited(_spawnNextOccurrence(t));
      _syncDelete(t.id);
      return;
    }

    await repo.toggleComplete(t);
    if (!t.completed) {
      // 막 완료된 케이스
      unawaited(NotificationsService.instance.cancel(t.id));
      unawaited(AnalyticsService.instance
          .logTodoComplete(priority: t.priority));
      unawaited(_spawnNextOccurrence(t));
    }
  }

  /// 한 줄 삭제. 알림/캘린더/analytics 전부 정리.
  Future<void> delete(Todo t) async {
    await ref.read(todosRepositoryProvider).delete(t.id);
    unawaited(NotificationsService.instance.cancel(t.id));
    unawaited(AnalyticsService.instance.logTodoDelete());
    _syncDelete(t.id);
  }

  /// 서브태스크 한 개 토글 후 todo 업데이트.
  Future<void> toggleSubtask(Todo t, int idx) async {
    final repo = ref.read(todosRepositoryProvider);
    final updated = [
      for (var i = 0; i < t.subtasks.length; i++)
        if (i == idx)
          t.subtasks[i].copyWith(completed: !t.subtasks[i].completed)
        else
          t.subtasks[i],
    ];
    await repo.update(t.copyWith(subtasks: updated));
    unawaited(ref
        .read(achievementsProvider.notifier)
        .checkAgainst(ref.read(todosStreamProvider).asData?.value ??
            const <Todo>[]));
  }

  void _syncDelete(String id) {
    if (ref.read(appSettingsProvider).calendarSyncEnabled) {
      unawaited(CalendarSyncService.instance.deleteTodo(id));
    }
  }

  /// 반복 일정 완료 시 다음 occurrence 자동 생성.
  Future<void> _spawnNextOccurrence(Todo t) async {
    if (t.recurrence == 'none') return;
    final repo = ref.read(todosRepositoryProvider);
    final next = _nextOccurrenceDate(t.date, t.recurrence);
    if (next == null) return;
    if (t.recurrenceEnd.isNotEmpty &&
        next.compareTo(t.recurrenceEnd) > 0) {
      return;
    }
    await repo.add(
      text: t.text,
      description: t.description,
      date: next,
      time: t.time,
      tags: t.tags,
      priority: t.priority,
      reminderOffset: t.reminderOffset,
      subtasks:
          t.subtasks.map((s) => s.copyWith(completed: false)).toList(),
      recurrence: t.recurrence,
      recurrenceEnd: t.recurrenceEnd,
    );
  }

  String? _nextOccurrenceDate(String date, String recurrence) {
    final base = parseDateKey(date);
    switch (recurrence) {
      case 'daily':
        return dateKey(base.add(const Duration(days: 1)));
      case 'weekly':
        return dateKey(base.add(const Duration(days: 7)));
      case 'monthly':
        return dateKey(DateTime(base.year, base.month + 1, base.day));
      default:
        return null;
    }
  }
}
