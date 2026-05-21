import 'package:flutter/material.dart';

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
  late String _date;
  late String _time;
  late String _priority;

  static const _priorities = ['low', 'medium', 'high', 'urgent'];
  static const _priorityLabel = {
    'low': '낮음',
    'medium': '보통',
    'high': '높음',
    'urgent': '긴급',
  };

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _textCtrl = TextEditingController(text: i?.text ?? '');
    _descCtrl = TextEditingController(text: i?.description ?? '');
    _tagsCtrl = TextEditingController(text: (i?.tags ?? const <String>[]).join(', '));
    _date = i?.date ?? widget.defaultDate;
    _time = i?.time ?? '';
    _priority = i?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

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
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? '할 일 편집' : '할 일 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textCtrl,
              autofocus: !isEdit,
              decoration: const InputDecoration(
                labelText: '내용',
                hintText: '예: 운동 30분',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
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
                    label: Text(_time.isEmpty ? '종일' : _time),
                  ),
                ),
                if (_time.isNotEmpty)
                  IconButton(
                    tooltip: '시간 지우기',
                    onPressed: _clearTime,
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('우선순위', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final p in _priorities)
                  ChoiceChip(
                    label: Text(_priorityLabel[p]!),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: '태그 (쉼표 구분)',
                hintText: '예: 운동, 건강',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? '저장' : '추가'),
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
  });

  final String text;
  final String description;
  final String date;
  final String time;
  final List<String> tags;
  final String priority;
}
