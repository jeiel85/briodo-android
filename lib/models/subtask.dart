/// 할 일에 딸린 하위 체크리스트 항목.
class Subtask {
  const Subtask({
    required this.id,
    required this.text,
    this.completed = false,
  });

  final String id;
  final String text;
  final bool completed;

  Subtask copyWith({String? text, bool? completed}) => Subtask(
        id: id,
        text: text ?? this.text,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'completed': completed,
      };

  factory Subtask.fromJson(Map<String, dynamic> j) => Subtask(
        id: (j['id'] ?? '') as String,
        text: (j['text'] ?? '') as String,
        completed: (j['completed'] ?? false) as bool,
      );
}
