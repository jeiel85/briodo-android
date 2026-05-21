import 'package:cloud_firestore/cloud_firestore.dart';

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
        // createdAt은 신규 생성 시 serverTimestamp()로 세팅하므로 여기 포함 X
      };

  Todo copyWith({
    String? text,
    String? description,
    String? date,
    String? time,
    List<String>? tags,
    String? priority,
    bool? completed,
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
      );
}
