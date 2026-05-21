import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subtask.dart';
import '../models/todo.dart';
import 'auth_provider.dart';

// ─────────────────────────── 날짜 헬퍼 + selectedDate ───────────────────────────

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return DateTime.now();
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return DateTime.now();
  return DateTime(y, m, d);
}

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

// ─────────────────────────── SharedPreferences ───────────────────────────

/// main()에서 미리 받은 인스턴스를 override로 넣음.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('main()에서 override 필요'),
);

// ─────────────────────────── Repository 인터페이스 ───────────────────────────

abstract class TodosRepository {
  Stream<List<Todo>> watch();

  Future<String> add({
    required String text,
    required String date,
    String description = '',
    String time = '',
    List<String> tags = const [],
    String priority = 'medium',
    int reminderOffset = -1,
    List<Subtask> subtasks = const [],
    String recurrence = 'none',
    String recurrenceEnd = '',
  });

  Future<void> update(Todo todo);
  Future<void> toggleComplete(Todo todo);
  Future<void> delete(String id);

  /// 마이그레이션용 — 한 번에 여러 건 추가.
  Future<void> bulkAdd(Iterable<Todo> todos);

  /// 마이그레이션용 — 현재 보관 중인 todos 한 번 스냅샷.
  Future<List<Todo>> snapshot();

  /// 마이그레이션 후 로컬을 비울 때 사용.
  Future<void> clearAll();
}

// ─────────────────────────── Firestore 구현 ───────────────────────────

class FirestoreTodosRepository implements TodosRepository {
  FirestoreTodosRepository(this._uid);
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('todos');

  Query<Map<String, dynamic>> get _q => _col.where('uid', isEqualTo: _uid);

  @override
  Stream<List<Todo>> watch() => _q
      .snapshots()
      .map((snap) => snap.docs.map(Todo.fromFirestore).toList());

  @override
  Future<String> add({
    required String text,
    required String date,
    String description = '',
    String time = '',
    List<String> tags = const [],
    String priority = 'medium',
    int reminderOffset = -1,
    List<Subtask> subtasks = const [],
    String recurrence = 'none',
    String recurrenceEnd = '',
  }) async {
    final doc = await _col.add({
      'uid': _uid,
      'text': text,
      'description': description,
      'date': date,
      'time': time,
      'tags': tags,
      'priority': priority,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'reminderOffset': reminderOffset,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'recurrence': recurrence,
      'recurrenceEnd': recurrenceEnd,
    });
    return doc.id;
  }

  @override
  Future<void> update(Todo todo) async {
    await _col.doc(todo.id).update({
      'text': todo.text,
      'description': todo.description,
      'date': todo.date,
      'time': todo.time,
      'tags': todo.tags,
      'priority': todo.priority,
      'reminderOffset': todo.reminderOffset,
      'subtasks': todo.subtasks.map((s) => s.toJson()).toList(),
      'recurrence': todo.recurrence,
      'recurrenceEnd': todo.recurrenceEnd,
    });
  }

  @override
  Future<void> toggleComplete(Todo todo) async {
    await _col.doc(todo.id).update({'completed': !todo.completed});
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<void> bulkAdd(Iterable<Todo> todos) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final t in todos) {
      batch.set(_col.doc(), {
        'uid': _uid,
        'text': t.text,
        'description': t.description,
        'date': t.date,
        'time': t.time,
        'tags': t.tags,
        'priority': t.priority,
        'completed': t.completed,
        'createdAt': t.createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(t.createdAt!),
      });
    }
    await batch.commit();
  }

  @override
  Future<List<Todo>> snapshot() async {
    final snap = await _q.get();
    return snap.docs.map(Todo.fromFirestore).toList();
  }

  @override
  Future<void> clearAll() async {
    // 클라우드는 의도적으로 비우지 않음 — 마이그레이션 후 로컬만 clearAll 대상.
  }
}

// ─────────────────────────── Local 구현 ───────────────────────────

class LocalTodosRepository implements TodosRepository {
  LocalTodosRepository(this._prefs) {
    _cache = _load();
  }

  static const _storageKey = 'todos.local.v1';
  final SharedPreferences _prefs;
  late List<Todo> _cache;
  final _controller = StreamController<List<Todo>>.broadcast();

  List<Todo> _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <Todo>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((j) => Todo.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Todo>[];
    }
  }

  Future<void> _flush() async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(_cache.map((t) => t.toJson()).toList()),
    );
    _controller.add(List.unmodifiable(_cache));
  }

  String _newId() {
    return 'local-${DateTime.now().microsecondsSinceEpoch}-${_cache.length}';
  }

  @override
  Stream<List<Todo>> watch() async* {
    yield List.unmodifiable(_cache);
    yield* _controller.stream;
  }

  @override
  Future<String> add({
    required String text,
    required String date,
    String description = '',
    String time = '',
    List<String> tags = const [],
    String priority = 'medium',
    int reminderOffset = -1,
    List<Subtask> subtasks = const [],
    String recurrence = 'none',
    String recurrenceEnd = '',
  }) async {
    final id = _newId();
    _cache = [
      ..._cache,
      Todo(
        id: id,
        uid: 'local',
        text: text,
        description: description,
        date: date,
        time: time,
        tags: tags,
        priority: priority,
        createdAt: DateTime.now(),
        reminderOffset: reminderOffset,
        subtasks: subtasks,
        recurrence: recurrence,
        recurrenceEnd: recurrenceEnd,
      ),
    ];
    await _flush();
    return id;
  }

  @override
  Future<void> update(Todo todo) async {
    _cache = _cache.map((t) => t.id == todo.id ? todo : t).toList();
    await _flush();
  }

  @override
  Future<void> toggleComplete(Todo todo) async {
    _cache = _cache
        .map((t) => t.id == todo.id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    await _flush();
  }

  @override
  Future<void> delete(String id) async {
    _cache = _cache.where((t) => t.id != id).toList();
    await _flush();
  }

  @override
  Future<void> bulkAdd(Iterable<Todo> todos) async {
    _cache = [..._cache, ...todos];
    await _flush();
  }

  @override
  Future<List<Todo>> snapshot() async => List.unmodifiable(_cache);

  @override
  Future<void> clearAll() async {
    _cache = <Todo>[];
    await _flush();
  }
}

// ─────────────────────────── 분기 프로바이더 ───────────────────────────

/// 로그인 안 됨 → LocalTodosRepository
/// 로그인 됨(익명 포함) → FirestoreTodosRepository(uid)
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return LocalTodosRepository(ref.watch(sharedPreferencesProvider));
  }
  return FirestoreTodosRepository(uid);
});

final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(todosRepositoryProvider).watch();
});
