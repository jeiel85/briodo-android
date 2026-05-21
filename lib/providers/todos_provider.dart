import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import 'auth_provider.dart';

/// 현재 로그인된 사용자의 todos 스트림.
/// uid가 바뀌면 자동으로 새 스트림으로 갈아탐.
/// 정렬은 클라이언트에서 별도로 하거나 Firestore orderBy 추가.
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
/// 패턴 예시 — 다른 mutation도 여기 추가하면 됨.
class TodosRepository {
  TodosRepository(this._uid);
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('todos');

  Future<void> add({
    required String text,
    required String date,
    String time = '',
    List<String> tags = const [],
    String priority = 'medium',
  }) async {
    await _col.add({
      'uid': _uid,
      'text': text,
      'description': '',
      'date': date,
      'time': time,
      'tags': tags,
      'priority': priority,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
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
