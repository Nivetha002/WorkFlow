class Comment {
  const Comment({
    required this.id,
    required this.taskId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String text;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, Object?> map) {
    return Comment(
      id: map['id']! as String,
      taskId: map['task_id']! as String,
      text: map['text']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}