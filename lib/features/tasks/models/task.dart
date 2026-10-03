import 'dart:convert';

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.syncStatus = 'synced',
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String syncStatus;

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? syncStatus,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'sync_status': syncStatus,
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id']! as String,
      projectId: map['project_id']! as String,
      title: map['title']! as String,
      description: map['description']! as String,
      status: map['status']! as String,
      priority: map['priority']! as String,
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }

  factory Task.fromJsonString(String value) {
    final map = jsonDecode(value) as Map<String, dynamic>;

    return Task.fromMap(map);
  }
}