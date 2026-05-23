import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/subtask.dart';
import '../models/todo.dart';
import '../providers/achievements_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/todos_provider.dart';
import '../services/analytics_service.dart';
import '../services/calendar_sync_service.dart';
import '../services/notifications_service.dart';
import '../theme.dart';

/// Todo의 알림 발송 시각 계산. HomeScreen의 동일 함수에서 이관.
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
  final tp = todo.time.split(':');
  if (tp.length < 2) return null;
  final hh = int.tryParse(tp[0]);
  final mm = int.tryParse(tp[1]);
  if (hh == null || mm == null) return null;
  return DateTime(y, m, d, hh, mm).subtract(Duration(minutes: todo.reminderOffset));
}

/// 새 BottomSheet 형식의 Todo 에디터. 신규/편집 통합.
/// 저장/업데이트 + 알림 재예약 + 캘린더 동기화 + 업적 체크까지 한 곳에서.
Future<void> openTodoEditorSheet(
  BuildContext context, {
  required WidgetRef ref,
  Todo? initial,
  String? defaultDate,
}) async {
  final String date = defaultDate ?? ref.read(selectedDateProvider);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TodoEditorSheet(initial: initial, defaultDate: date),
  );
}

class _TodoEditorSheet extends ConsumerStatefulWidget {
  const _TodoEditorSheet({this.initial, required this.defaultDate});
  final Todo? initial;
  final String defaultDate;

  @override
  ConsumerState<_TodoEditorSheet> createState() => _TodoEditorSheetState();
}

class _TodoEditorSheetState extends ConsumerState<_TodoEditorSheet> {
  late final TextEditingController _textCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _subInputCtrl;
  late String _date;
  late String _time;
  late String _priority;
  late int _reminderOffset;
  late List<Subtask> _subtasks;
  late String _recurrence;
  late String _recurrenceEnd;

  static const _priorities = ['low', 'medium', 'high', 'urgent'];
  static const _reminderOffsets = [-1, 0, 10, 30, 60];
  static const _recurrences = ['none', 'daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _textCtrl = TextEditingController(text: i?.text ?? '');
    _descCtrl = TextEditingController(text: i?.description ?? '');
    _tagsCtrl =
        TextEditingController(text: (i?.tags ?? const <String>[]).join(', '));
    _subInputCtrl = TextEditingController();
    _date = i?.date ?? widget.defaultDate;
    _time = i?.time ?? '';
    _priority = i?.priority ?? 'medium';
    _reminderOffset = i?.reminderOffset ?? -1;
    _subtasks = List<Subtask>.from(i?.subtasks ?? const <Subtask>[]);
    _recurrence = i?.recurrence ?? 'none';
    _recurrenceEnd = i?.recurrenceEnd ?? '';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    _subInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDateKey(_date),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = dateKey(picked));
  }

  Future<void> _pickTime() async {
    TimeOfDay initial;
    if (_time.isEmpty) {
      initial = TimeOfDay.now();
    } else {
      final p = _time.split(':');
      initial = TimeOfDay(
        hour: int.tryParse(p[0]) ?? 9,
        minute: p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0,
      );
    }
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _time =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _clearTime() => setState(() => _time = '');

  Future<void> _pickRecurrenceEnd() async {
    final base = _recurrenceEnd.isNotEmpty
        ? parseDateKey(_recurrenceEnd)
        : parseDateKey(_date).add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: parseDateKey(_date),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _recurrenceEnd = dateKey(picked));
  }

  void _addSubtask() {
    final t = _subInputCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _subtasks = [
        ..._subtasks,
        Subtask(
          id: 'sub-${DateTime.now().microsecondsSinceEpoch}-${_subtasks.length}',
          text: t,
        ),
      ];
      _subInputCtrl.clear();
    });
  }

  void _toggleSubtask(int idx) {
    setState(() {
      _subtasks = [
        for (var i = 0; i < _subtasks.length; i++)
          if (i == idx)
            _subtasks[i].copyWith(completed: !_subtasks[i].completed)
          else
            _subtasks[i],
      ];
    });
  }

  void _removeSubtask(int idx) {
    setState(() {
      _subtasks = [
        for (var i = 0; i < _subtasks.length; i++)
          if (i != idx) _subtasks[i],
      ];
    });
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final repo = ref.read(todosRepositoryProvider);
    final isEdit = widget.initial != null;
    Todo resultTodo;
    if (!isEdit) {
      final newId = await repo.add(
        text: text,
        description: _descCtrl.text.trim(),
        date: _date,
        time: _time,
        tags: tags,
        priority: _priority,
        reminderOffset: _reminderOffset,
        subtasks: _subtasks,
        recurrence: _recurrence,
        recurrenceEnd: _recurrence == 'none' ? '' : _recurrenceEnd,
      );
      unawaited(AnalyticsService.instance.logTodoCreate(
        priority: _priority,
        tagCount: tags.length,
      ));
      resultTodo = Todo(
        id: newId,
        uid: '',
        text: text,
        description: _descCtrl.text.trim(),
        date: _date,
        time: _time,
        tags: tags,
        priority: _priority,
        reminderOffset: _reminderOffset,
        subtasks: _subtasks,
        recurrence: _recurrence,
        recurrenceEnd: _recurrence == 'none' ? '' : _recurrenceEnd,
      );
    } else {
      resultTodo = widget.initial!.copyWith(
        text: text,
        description: _descCtrl.text.trim(),
        date: _date,
        time: _time,
        tags: tags,
        priority: _priority,
        reminderOffset: _reminderOffset,
        subtasks: _subtasks,
        recurrence: _recurrence,
        recurrenceEnd: _recurrence == 'none' ? '' : _recurrenceEnd,
      );
      await repo.update(resultTodo);
    }
    await _rescheduleNotification(resultTodo);
    unawaited(_syncToCalendar(resultTodo));
    unawaited(ref.read(achievementsProvider.notifier).checkAgainst(
        ref.read(todosStreamProvider).asData?.value ?? const <Todo>[]));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _rescheduleNotification(Todo todo) async {
    final ns = NotificationsService.instance;
    if (todo.completed) {
      unawaited(ns.cancel(todo.id));
      return;
    }
    final s = ref.read(appSettingsProvider);
    final when = scheduleAtFor(todo, s);
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

  Future<void> _syncToCalendar(Todo todo) async {
    final s = ref.read(appSettingsProvider);
    if (!s.calendarSyncEnabled) return;
    await CalendarSyncService.instance
        .pushTodo(todo, syncNoTimePolicy: s.calendarSyncNoTime);
    unawaited(
        ref.read(achievementsProvider.notifier).setFlag('calendarUsed'));
  }

  String _priLabel(AppLocalizations l, String p) {
    switch (p) {
      case 'low':
        return l.priorityLow;
      case 'high':
        return l.priorityHigh;
      case 'urgent':
        return l.priorityUrgent;
      case 'medium':
      default:
        return l.priorityMedium;
    }
  }

  String _remLabel(AppLocalizations l, int o) {
    switch (o) {
      case 0:
        return l.reminderAtTime;
      case 10:
        return l.reminder10min;
      case 30:
        return l.reminder30min;
      case 60:
        return l.reminder1hour;
      default:
        return l.reminderNone;
    }
  }

  String _recLabel(AppLocalizations l, String r) {
    switch (r) {
      case 'daily':
        return l.recurrenceDaily;
      case 'weekly':
        return l.recurrenceWeekly;
      case 'monthly':
        return l.recurrenceMonthly;
      default:
        return l.recurrenceNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.initial != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? l.editTodo : l.addTodo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textCtrl,
                  autofocus: !isEdit,
                  decoration: InputDecoration(
                    labelText: l.fieldText,
                    hintText: l.fieldTextHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  decoration: InputDecoration(labelText: l.fieldNote),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ChipButton(
                        icon: Icons.calendar_today,
                        label: _date,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChipButton(
                        icon: Icons.access_time,
                        label: _time.isEmpty ? l.fieldAllDay : _time,
                        onTap: _pickTime,
                      ),
                    ),
                    if (_time.isNotEmpty)
                      IconButton(
                        tooltip: l.fieldClearTime,
                        onPressed: _clearTime,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: l.fieldPriority),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < _priorities.length; i++) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _priority = _priorities[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _priority == _priorities[i]
                                  ? cs.primary
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _priLabel(l, _priorities[i]),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _priority == _priorities[i]
                                      ? Colors.white
                                      : cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (i != _priorities.length - 1)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagsCtrl,
                  decoration: InputDecoration(
                    labelText: l.fieldTags,
                    hintText: l.fieldTagsHint,
                    prefixIcon: const Icon(Icons.label_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                _SubtasksPanel(
                  subtasks: _subtasks,
                  inputCtrl: _subInputCtrl,
                  onAdd: _addSubtask,
                  onToggle: _toggleSubtask,
                  onRemove: _removeSubtask,
                  hint: l.subtaskHint,
                  addLabel: l.addSubtask,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(label: l.fieldReminder),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _reminderOffset,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: [
                              for (final o in _reminderOffsets)
                                DropdownMenuItem(
                                  value: o,
                                  child: Text(_remLabel(l, o)),
                                ),
                            ],
                            onChanged: (v) =>
                                setState(() => _reminderOffset = v ?? -1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(label: l.fieldRecurrence),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _recurrence,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: [
                              for (final r in _recurrences)
                                DropdownMenuItem(
                                  value: r,
                                  child: Text(_recLabel(l, r)),
                                ),
                            ],
                            onChanged: (v) =>
                                setState(() => _recurrence = v ?? 'none'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_recurrence != 'none') ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickRecurrenceEnd,
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(_recurrenceEnd.isEmpty
                        ? l.recurrenceEndNone
                        : '${l.recurrenceEnd}: $_recurrenceEnd'),
                  ),
                ],
                if (_reminderOffset >= 0 && _time.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.noTimeNoReminderHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(
                      isEdit
                          ? l.actionSave
                          : '${l.actionAdd}  🚀',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: cs.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: cs.onSecondaryContainer),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtasksPanel extends StatelessWidget {
  const _SubtasksPanel({
    required this.subtasks,
    required this.inputCtrl,
    required this.onAdd,
    required this.onToggle,
    required this.onRemove,
    required this.hint,
    required this.addLabel,
  });

  final List<Subtask> subtasks;
  final TextEditingController inputCtrl;
  final VoidCallback onAdd;
  final void Function(int index) onToggle;
  final void Function(int index) onRemove;
  final String hint;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final completed = subtasks.where((s) => s.completed).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하위 작업 ($completed/${subtasks.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          for (var i = 0; i < subtasks.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onToggle(i),
                    icon: Icon(
                      subtasks[i].completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: subtasks[i].completed
                          ? BrioColors.success
                          : cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtasks[i].text,
                      style: TextStyle(
                        fontSize: 13,
                        decoration: subtasks[i].completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: subtasks[i].completed
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(i),
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: cs.error.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputCtrl,
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(addLabel.contains('Enter') ? '추가' : '추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
