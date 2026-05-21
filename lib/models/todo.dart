import 'package:cloud_firestore/cloud_firestore.dart';

import 'subtask.dart';

/// 단일 할 일.
/// 기존 Capacitor 버전 Firestore 스키마와 호환되도록 필드명 동일하게 맞춤.
class Todo {
  final String id;
  final String uid;
  final String text;
  final String description;

  /// YYYY-MM-DD
  final String date;

  /// HH:MM, 종일이면 빈 문자열
  final String time;

  final List<String> tags;
  final String priority; // 'low' | 'medium' | 'high' | 'urgent'
  final bool completed;
  final DateTime? createdAt;

  /// 마감 시간 N분 전에 알림 (분 단위).
  /// -1 = 알림 끔, 0 = 정각, 10/30/60 등.
  final int reminderOffset;

  /// 하위 체크리스트.
  final List<Subtask> subtasks;

  /// 반복 일정. 'none' | 'daily' | 'weekly' | 'monthly'
  final String recurrence;

  /// 반복 종료일 (YYYY-MM-DD). 빈 문자열이면 무기한.
  final String recurrenceEnd;

  const Todo({
    required this.id,
    required this.uid,
    required this.text,
    this.description = '',
    required this.date,
    this.time = '',
    this.tags = const [],
    this.priority = 'medium',
    this.completed = false,
    this.createdAt,
    this.reminderOffset = -1,
    this.subtasks = const [],
    this.recurrence = 'none',
    this.recurrenceEnd = '',
  });

  factory Todo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final createdAtRaw = d['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
    }

    final subsRaw = d['subtasks'];
    final subs = subsRaw is List
        ? subsRaw
            .whereType<Map<String, dynamic>>()
            .map(Subtask.fromJson)
            .toList()
        : <Subtask>[];

    return Todo(
      id: doc.id,
      uid: (d['uid'] ?? '') as String,
      text: (d['text'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      date: (d['date'] ?? '') as String,
      time: (d['time'] ?? '') as String,
      tags: List<String>.from(d['tags'] ?? const []),
      priority: (d['priority'] ?? 'medium') as String,
      completed: (d['completed'] ?? false) as bool,
      createdAt: createdAt,
      reminderOffset: (d['reminderOffset'] is int)
          ? d['reminderOffset'] as int
          : -1,
      subtasks: subs,
      recurrence: (d['recurrence'] ?? 'none') as String,
      recurrenceEnd: (d['recurrenceEnd'] ?? '') as String,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'text': text,
        'description': description,
        'date': date,
        'time': time,
        'tags': tags,
        'priority': priority,
        'completed': completed,
        'reminderOffset': reminderOffset,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'recurrence': recurrence,
        'recurrenceEnd': recurrenceEnd,
        // createdAt은 신규 생성 시 serverTimestamp()로 세팅하므로 여기 포함 X
      };

  /// 로컬(SharedPreferences) 저장용 JSON. id/createdAt 포함.
  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'text': text,
        'description': description,
        'date': date,
        'time': time,
        'tags': tags,
        'priority': priority,
        'completed': completed,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'reminderOffset': reminderOffset,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'recurrence': recurrence,
        'recurrenceEnd': recurrenceEnd,
      };

  factory Todo.fromJson(Map<String, dynamic> j) {
    final subsRaw = j['subtasks'];
    final subs = subsRaw is List
        ? subsRaw
            .whereType<Map<String, dynamic>>()
            .map(Subtask.fromJson)
            .toList()
        : <Subtask>[];
    return Todo(
      id: (j['id'] ?? '') as String,
      uid: (j['uid'] ?? '') as String,
      text: (j['text'] ?? '') as String,
      description: (j['description'] ?? '') as String,
      date: (j['date'] ?? '') as String,
      time: (j['time'] ?? '') as String,
      tags: List<String>.from((j['tags'] as List?) ?? const []),
      priority: (j['priority'] ?? 'medium') as String,
      completed: (j['completed'] ?? false) as bool,
      createdAt: j['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int)
          : null,
      reminderOffset:
          (j['reminderOffset'] is int) ? j['reminderOffset'] as int : -1,
      subtasks: subs,
      recurrence: (j['recurrence'] ?? 'none') as String,
      recurrenceEnd: (j['recurrenceEnd'] ?? '') as String,
    );
  }

  Todo copyWith({
    String? text,
    String? description,
    String? date,
    String? time,
    List<String>? tags,
    String? priority,
    bool? completed,
    int? reminderOffset,
    List<Subtask>? subtasks,
    String? recurrence,
    String? recurrenceEnd,
  }) =>
      Todo(
        id: id,
        uid: uid,
        text: text ?? this.text,
        description: description ?? this.description,
        date: date ?? this.date,
        time: time ?? this.time,
        tags: tags ?? this.tags,
        priority: priority ?? this.priority,
        completed: completed ?? this.completed,
        createdAt: createdAt,
        reminderOffset: reminderOffset ?? this.reminderOffset,
        subtasks: subtasks ?? this.subtasks,
        recurrence: recurrence ?? this.recurrence,
        recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      );
}
