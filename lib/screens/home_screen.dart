import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/achievements_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/todos_provider.dart';
import '../services/home_widget_service.dart';
import '../services/notifications_service.dart';
import '../services/todo_actions.dart';
import '../theme.dart';
import '../widgets/brio_components.dart';
import '../widgets/todo_editor_sheet.dart';
import 'search_screen.dart';

/// 새 홈 화면 — Hero 카드 + 14일 캘린더 리본 + Brio 할 일 리스트.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onTagToHome});

  /// 다른 탭에서 호출되었을 때 홈 탭으로 점프하기 위한 콜백.
  final void Function(int tabIndex)? onTagToHome;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};

  late final TodoActions _actions = TodoActions(ref);

  Future<void> _openEditor(Todo? initial) async {
    await openTodoEditorSheet(
      context,
      ref: ref,
      initial: initial,
      defaultDate: ref.read(selectedDateProvider),
    );
  }

  Future<void> _syncOngoingNotification(List<Todo> todos) async {
    final s = ref.read(appSettingsProvider);
    if (!s.statusBarOngoingEnabled) {
      await NotificationsService.instance.cancelOngoing();
      return;
    }
    final todayKey = dateKey(DateTime.now());
    final active = todos.where((t) => t.date == todayKey && !t.completed).toList()
      ..sort((a, b) {
        final at = a.time.isEmpty ? '99:99' : a.time;
        final bt = b.time.isEmpty ? '99:99' : b.time;
        return at.compareTo(bt);
      });
    await NotificationsService.instance.showOngoing(
      activeCount: active.length,
      firstLine: active.isEmpty ? '' : active.first.text,
    );
  }

  int _compare(Todo a, Todo b) {
    if (a.completed != b.completed) return a.completed ? 1 : -1;
    final at = a.time.isEmpty ? '99:99' : a.time;
    final bt = b.time.isEmpty ? '99:99' : b.time;
    final tc = at.compareTo(bt);
    if (tc != 0) return tc;
    final ap = _priorityOrder[a.priority] ?? 2;
    final bp = _priorityOrder[b.priority] ?? 2;
    return ap.compareTo(bp);
  }

  int _calculateStreak(List<Todo> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayHas = <String, bool>{};
    for (final t in todos) {
      if (t.completed) dayHas[t.date] = true;
    }
    int streak = 0;
    for (var i = 0; i < 400; i++) {
      final d = today.subtract(Duration(days: i));
      if (dayHas[dateKey(d)] == true) {
        streak += 1;
      } else if (i == 0) {
        break;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final todosAsync = ref.watch(todosStreamProvider);
    final selected = ref.watch(selectedDateProvider);

    // 새 todo 데이터가 도착할 때마다 업적/위젯/상태바 알림 트리거.
    ref.listen(todosStreamProvider, (_, next) {
      final list = next.asData?.value;
      if (list != null) {
        ref.read(achievementsProvider.notifier).checkAgainst(list);
        HomeWidgetService.instance.updateFromTodos(list);
        _syncOngoingNotification(list);
      }
    });

    final allTodos = todosAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Todo>[],
    );
    final today = dateKey(DateTime.now());
    final isToday = selected == today;
    final dateTodos = allTodos.where((t) => t.date == selected).toList()
      ..sort(_compare);
    final completed = dateTodos.where((t) => t.completed).length;
    final progress = dateTodos.isEmpty ? 0.0 : completed / dateTodos.length;
    final streak = _calculateStreak(allTodos);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () =>
                  ref.read(selectedDateProvider.notifier).resetToToday(),
              child: Text(
                l.today,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          IconButton(
            tooltip: l.search,
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
          children: [
            // Hero 컨텍스트 카드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _HeroCard(
                todoCount: dateTodos.length,
                completedCount: completed,
                progress: progress,
                streak: streak,
              ),
            ),
            const SizedBox(height: 16),
            // 캘린더 리본 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    '캘린더 타임라인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            BrioCalendarRibbon(
              selectedDate: selected,
              todos: allTodos,
              onSelect: (d) =>
                  ref.read(selectedDateProvider.notifier).set(d),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                _selectedLabel(selected),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            // 할 일 리스트
            if (dateTodos.isEmpty)
              BrioEmptyState(
                title: isToday ? l.noTodosToday : l.noTodosOnDate,
                subtitle: '+ 버튼으로 활기찬 하루를 계획해 보세요!',
                icon: Icon(
                  Icons.beach_access,
                  size: 54,
                  color: cs.primary.withValues(alpha: 0.35),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final t in dateTodos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(t.id),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: cs.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete,
                                color: cs.onErrorContainer),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _actions.delete(t),
                          child: BrioTodoTile(
                            todo: t,
                            onToggle: () => _actions.toggle(t),
                            onTap: () => _openEditor(t),
                            onSubtaskToggle: (idx) =>
                                _actions.toggleSubtask(t, idx),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _selectedLabel(String key) {
    final d = parseDateKey(key);
    const wd = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${d.year}년 ${d.month}월 ${d.day}일 (${wd[(d.weekday - 1) % 7]}) 계획';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.todoCount,
    required this.completedCount,
    required this.progress,
    required this.streak,
  });

  final int todoCount;
  final int completedCount;
  final double progress;
  final int streak;

  String _quote() {
    if (todoCount == 0) return '오늘 예정된 계획이 없어요. 활기차게 시작해보실까요? 🌱';
    if (progress == 1) return '와 대단합니다! 오늘의 계획을 완벽하게 마무리하셨어요! 🎉';
    if (progress > 0.6) return '대부분 완료했어요! 마지막 불꽃을 태워볼까요? 🔥';
    if (progress > 0) return '한 걸음 뗐습니다. 차근차근 해내보아요! 💪';
    return '시작이 반입니다! 오늘 $todoCount개의 임무가 대기 중이에요. 🚀';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctx = context;
    return BrioCard(
      backgroundColor: cs.primaryContainer,
      borderless: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 맥락',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.primary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Do it with brio!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrioColors.warningContainerOf(ctx),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: BrioColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak일 연속',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: BrioColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _quote(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onPrimaryContainer.withValues(alpha: 0.9),
            ),
          ),
          if (todoCount > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          cs.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          BrioColors.success),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).round()}%  $completedCount/$todoCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
