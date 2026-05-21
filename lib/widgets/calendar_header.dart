import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 주/월 토글 가능한 캘린더 헤더.
/// selectedDate ↔ HomeScreen의 [selectedDateProvider] 동기화는 호출 측이 담당.
/// 일정이 있는 날에는 마커 dot 표시.
class CalendarHeader extends StatefulWidget {
  const CalendarHeader({
    super.key,
    required this.selected,
    required this.todos,
    required this.onSelect,
  });

  /// 현재 선택된 날짜 (YYYY-MM-DD)
  final String selected;
  final List<Todo> todos;
  final ValueChanged<String> onSelect;

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  CalendarFormat _format = CalendarFormat.week;
  late DateTime _focused;

  @override
  void initState() {
    super.initState();
    _focused = parseDateKey(widget.selected);
  }

  @override
  void didUpdateWidget(CalendarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _focused = parseDateKey(widget.selected);
    }
  }

  List<Todo> _eventsFor(DateTime day) {
    final key = dateKey(day);
    return widget.todos.where((t) => t.date == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDay = parseDateKey(widget.selected);

    return TableCalendar<Todo>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: _focused,
      currentDay: DateTime.now(),
      calendarFormat: _format,
      availableCalendarFormats: const {
        CalendarFormat.month: '월',
        CalendarFormat.twoWeeks: '2주',
        CalendarFormat.week: '주',
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
      eventLoader: _eventsFor,
      onDaySelected: (sel, focused) {
        setState(() => _focused = focused);
        widget.onSelect(dateKey(sel));
      },
      onPageChanged: (focused) => _focused = focused,
      onFormatChanged: (fmt) => setState(() => _format = fmt),
      headerStyle: HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
        titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
        formatButtonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        formatButtonTextStyle: theme.textTheme.labelMedium ?? const TextStyle(),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: theme.colorScheme.primary),
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
    );
  }
}
