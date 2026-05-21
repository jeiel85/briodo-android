import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../providers/todos_provider.dart';
import '../widgets/calendar_header.dart';
import '../widgets/todo_editor_dialog.dart';

/// 로그인 없이 캘린더/편집 UI를 보여주는 데모.
/// 디버그 빌드/웹 미리보기 용. Firestore 의존 없음 — 모든 상태는 메모리.
class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late String _selected;
  late List<Todo> _todos;
  int _idSeed = 0;

  static const _priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = dateKey(now);
    final tomorrow = dateKey(now.add(const Duration(days: 1)));
    _todos = [
      _mk(text: '운동 30분', date: _selected, time: '07:00', priority: 'high', tags: ['건강']),
      _mk(text: '디자인 리뷰 미팅', date: _selected, time: '14:00', priority: 'urgent', tags: ['업무']),
      _mk(text: '저녁 장보기', date: _selected, priority: 'medium', tags: ['생활']),
      _mk(text: '책 30분 읽기', date: _selected, priority: 'low', tags: ['취미'], completed: true),
      _mk(text: '치과 예약', date: tomorrow, time: '11:30', priority: 'high'),
      _mk(text: '주간 회고', date: tomorrow, priority: 'medium', tags: ['업무', '회고']),
    ];
  }

  Todo _mk({
    required String text,
    required String date,
    String time = '',
    String priority = 'medium',
    List<String> tags = const [],
    bool completed = false,
    String description = '',
  }) {
    _idSeed += 1;
    return Todo(
      id: 'demo-${_idSeed.toString().padLeft(4, '0')}',
      uid: 'demo-user',
      text: text,
      description: description,
      date: date,
      time: time,
      tags: tags,
      priority: priority,
      completed: completed,
      createdAt: DateTime.now(),
    );
  }

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

  void _toggle(Todo t) {
    setState(() {
      _todos = _todos
          .map((x) => x.id == t.id ? x.copyWith(completed: !x.completed) : x)
          .toList();
    });
  }

  void _delete(String id) {
    setState(() => _todos = _todos.where((t) => t.id != id).toList());
  }

  Future<void> _openEditor({Todo? initial}) async {
    final result = await showDialog<TodoEditorResult>(
      context: context,
      builder: (_) => TodoEditorDialog(
        initial: initial,
        defaultDate: _selected,
      ),
    );
    if (result == null) return;
    setState(() {
      if (initial == null) {
        _todos = [
          ..._todos,
          _mk(
            text: result.text,
            description: result.description,
            date: result.date,
            time: result.time,
            tags: result.tags,
            priority: result.priority,
          ),
        ];
      } else {
        _todos = _todos
            .map((t) => t.id == initial.id
                ? t.copyWith(
                    text: result.text,
                    description: result.description,
                    date: result.date,
                    time: result.time,
                    tags: result.tags,
                    priority: result.priority,
                  )
                : t)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = dateKey(DateTime.now());
    final isToday = _selected == today;
    final filtered = _todos.where((t) => t.date == _selected).toList()
      ..sort(_compare);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrioDo (데모)'),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () => setState(() => _selected = today),
              child: const Text('오늘'),
            ),
        ],
      ),
      body: Column(
        children: [
          CalendarHeader(
            selected: _selected,
            todos: _todos,
            onSelect: (date) => setState(() => _selected = date),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      isToday ? '오늘 할 일이 없어요\n+ 버튼으로 추가하세요' : '이 날짜에 할 일이 없어요',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
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
                          child: Icon(Icons.delete,
                              color: theme.colorScheme.onErrorContainer),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _delete(t.id),
                        child: ListTile(
                          onTap: () => _openEditor(initial: t),
                          leading: GestureDetector(
                            onTap: () => _toggle(t),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.completed
                                    ? color.withValues(alpha: 0.7)
                                    : Colors.transparent,
                                border: Border.all(color: color, width: 2),
                              ),
                              child: t.completed
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
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
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
