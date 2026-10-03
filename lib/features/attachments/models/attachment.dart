class Attachment {
  const Attachment({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String fileName;
  final String filePath;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'file_name': fileName,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, Object?> map) {
    return Attachment(
      id: map['id']! as String,
      taskId: map['task_id']! as String,
      fileName: map['file_name']! as String,
      filePath: map['file_path']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}