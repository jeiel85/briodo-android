import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import 'auth_provider.dart';

/// YYYY-MM-DD 문자열 변환. Firestore 스키마와 동일.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// YYYY-MM-DD → DateTime. 파싱 실패 시 오늘 반환.
DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return DateTime.now();
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return DateTime.now();
  return DateTime(y, m, d);
}

/// 홈에서 표시 중인 날짜. 다른 화면도 같은 값을 공유.
/// Riverpod 3에서 StateProvider가 사라져 Notifier로 직접 작성.
class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() => dateKey(DateTime.now());

  void set(String date) => state = date;

  void shiftDays(int days) {
    final cur = parseDateKey(state);
    state = dateKey(cur.add(Duration(days: days)));
  }

  void resetToToday() => state = dateKey(DateTime.now());
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, String>(SelectedDateNotifier.new);

/// 현재 로그인된 사용자의 todos 스트림.
/// uid가 바뀌면 자동으로 새 스트림으로 갈아탐.
/// 정렬/필터는 호출 측에서.
final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream<List<Todo>>.empty();
  }

  return FirebaseFirestore.instance
      .collection('todos')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs.map(Todo.fromFirestore).toList());
});

/// todos CRUD 진입점. screens에서 직접 호출.
class TodosRepository {
  TodosRepository(this._uid);
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('todos');

  Future<void> add({
    required String text,
    required String date,
    String description = '',
    String time = '',
    List<String> tags = const [],
    String priority = 'medium',
  }) async {
    await _col.add({
      'uid': _uid,
      'text': text,
      'description': description,
      'date': date,
      'time': time,
      'tags': tags,
      'priority': priority,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// completed/createdAt은 보존, 나머지 편집 가능 필드만 갱신.
  Future<void> update(Todo todo) async {
    await _col.doc(todo.id).update({
      'text': todo.text,
      'description': todo.description,
      'date': todo.date,
      'time': todo.time,
      'tags': todo.tags,
      'priority': todo.priority,
    });
  }

  Future<void> toggleComplete(Todo todo) async {
    await _col.doc(todo.id).update({'completed': !todo.completed});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}

final todosRepositoryProvider = Provider<TodosRepository?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  return TodosRepository(uid);
});
