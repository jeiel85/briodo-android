import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/subtask.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 신규 생성 또는 기존 편집에 모두 쓰는 풀 다이얼로그.
/// 호출 측에서 결과(TodoEditorResult?)를 받아 Repository.add / update로 분기.
///
/// initial == null → 신규, defaultDate를 시작 날짜로
/// initial != null → 편집, 모든 필드를 todo에서 끌어옴
class TodoEditorDialog extends StatefulWidget {
  const TodoEditorDialog({
    super.key,
    this.initial,
    required this.defaultDate,
  });

  final Todo? initial;
  final String defaultDate;

  @override
  State<TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends State<TodoEditorDialog> {
  late final TextEditingController _textCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _subtaskInputCtrl;
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

  String _priorityLabel(AppLocalizations l, String p) {
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

  String _reminderLabel(AppLocalizations l, int o) {
    switch (o) {
      case 0:
        return l.reminderAtTime;
      case 10:
        return l.reminder10min;
      case 30:
        return l.reminder30min;
      case 60:
        return l.reminder1hour;
      case -1:
      default:
        return l.reminderNone;
    }
  }

  String _recurrenceLabel(AppLocalizations l, String r) {
    switch (r) {
      case 'daily':
        return l.recurrenceDaily;
      case 'weekly':
        return l.recurrenceWeekly;
      case 'monthly':
        return l.recurrenceMonthly;
      case 'none':
      default:
        return l.recurrenceNone;
    }
  }

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _textCtrl = TextEditingController(text: i?.text ?? '');
    _descCtrl = TextEditingController(text: i?.description ?? '');
    _tagsCtrl = TextEditingController(text: (i?.tags ?? const <String>[]).join(', '));
    _subtaskInputCtrl = TextEditingController();
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
    _subtaskInputCtrl.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final t = _subtaskInputCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _subtasks = [
        ..._subtasks,
        Subtask(
          id: 'sub-${DateTime.now().microsecondsSinceEpoch}-${_subtasks.length}',
          text: t,
        ),
      ];
      _subtaskInputCtrl.clear();
    });
  }

  void _toggleSubtask(String id) {
    setState(() {
      _subtasks = _subtasks
          .map((s) => s.id == id ? s.copyWith(completed: !s.completed) : s)
          .toList();
    });
  }

  void _removeSubtask(String id) {
    setState(() {
      _subtasks = _subtasks.where((s) => s.id != id).toList();
    });
  }

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
    if (picked != null) {
      setState(() => _recurrenceEnd = dateKey(picked));
    }
  }

  void _clearRecurrenceEnd() => setState(() => _recurrenceEnd = '');

  Future<void> _pickDate() async {
    final initial = parseDateKey(_date);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = dateKey(picked));
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay initial;
    if (_time.isEmpty) {
      initial = TimeOfDay.now();
    } else {
      final parts = _time.split(':');
      initial = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      );
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _clearTime() => setState(() => _time = '');

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    Navigator.of(context).pop(TodoEditorResult(
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? l.editTodo : l.addTodo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textCtrl,
              autofocus: !isEdit,
              decoration: InputDecoration(
                labelText: l.fieldText,
                hintText: l.fieldTextHint,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l.fieldNote,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_date),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(_time.isEmpty ? l.fieldAllDay : _time),
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
            const SizedBox(height: 12),
            Text(l.fieldPriority, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final p in _priorities)
                  ChoiceChip(
                    label: Text(_priorityLabel(l, p)),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.fieldReminder, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final o in _reminderOffsets)
                  ChoiceChip(
                    label: Text(_reminderLabel(l, o)),
                    selected: _reminderOffset == o,
                    onSelected: (_) => setState(() => _reminderOffset = o),
                  ),
              ],
            ),
            if (_reminderOffset >= 0 && _time.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.noTimeNoReminderHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(l.fieldRecurrence, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final r in _recurrences)
                  ChoiceChip(
                    label: Text(_recurrenceLabel(l, r)),
                    selected: _recurrence == r,
                    onSelected: (_) => setState(() => _recurrence = r),
                  ),
              ],
            ),
            if (_recurrence != 'none')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickRecurrenceEnd,
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          _recurrenceEnd.isEmpty
                              ? l.recurrenceEndNone
                              : '${l.recurrenceEnd}: $_recurrenceEnd',
                        ),
                      ),
                    ),
                    if (_recurrenceEnd.isNotEmpty)
                      IconButton(
                        onPressed: _clearRecurrenceEnd,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(l.fieldSubtasks, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            for (final s in _subtasks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: s.completed,
                      onChanged: (_) => _toggleSubtask(s.id),
                    ),
                    Expanded(
                      child: Text(
                        s.text,
                        style: s.completed
                            ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.outline,
                              )
                            : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeSubtask(s.id),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskInputCtrl,
                    decoration: InputDecoration(
                      hintText: l.subtaskHint,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                IconButton(
                  tooltip: l.addSubtask,
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsCtrl,
              decoration: InputDecoration(
                labelText: l.fieldTags,
                hintText: l.fieldTagsHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? l.actionSave : l.actionAdd),
        ),
      ],
    );
  }
}

/// 다이얼로그 결과. 호출 측이 add/update 분기.
class TodoEditorResult {
  const TodoEditorResult({
    required this.text,
    required this.description,
    required this.date,
    required this.time,
    required this.tags,
    required this.priority,
    required this.reminderOffset,
    required this.subtasks,
    required this.recurrence,
    required this.recurrenceEnd,
  });

  final String text;
  final String description;
  final String date;
  final String time;
  final List<String> tags;
  final String priority;
  final int reminderOffset;
  final List<Subtask> subtasks;
  final String recurrence;
  final String recurrenceEnd;
}
