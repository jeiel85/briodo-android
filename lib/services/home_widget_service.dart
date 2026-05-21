import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:home_widget/home_widget.dart';

import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 안드 홈 위젯에 오늘 활성 할 일 개수 + 첫 줄 push.
/// iOS는 별도 위젯 미구현 (안드 우선).
class HomeWidgetService {
  HomeWidgetService._();
  static final instance = HomeWidgetService._();

  static const _kProvider = 'BrioDoWidgetProvider';

  Future<void> updateFromTodos(List<Todo> todos) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final todayKey = dateKey(DateTime.now());
    final today = todos
        .where((t) => t.date == todayKey && !t.completed)
        .toList()
      ..sort((a, b) {
        final at = a.time.isEmpty ? '99:99' : a.time;
        final bt = b.time.isEmpty ? '99:99' : b.time;
        return at.compareTo(bt);
      });

    final activeCount = today.length;
    final firstLine = today.isEmpty ? '' : today.first.text;

    try {
      await HomeWidget.saveWidgetData<int>('widget.activeCount', activeCount);
      await HomeWidget.saveWidgetData<String>('widget.firstLine', firstLine);
      await HomeWidget.updateWidget(
        androidName: _kProvider,
        qualifiedAndroidName: 'app.briodo.$_kProvider',
      );
    } catch (_) {
      // 위젯 미설치 / 권한 X 무시.
    }
  }
}
