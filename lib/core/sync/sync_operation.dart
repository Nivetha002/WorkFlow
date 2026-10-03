class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.retryCount,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String operationType;
  final String entityType;
  final String entityId;
  final String payload;
  final int retryCount;
  final String status;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'operation_type': operationType,
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
      'retry_count': retryCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SyncOperation.fromMap(Map<String, Object?> map) {
    return SyncOperation(
      id: map['id'] as int?,
      operationType: map['operation_type']! as String,
      entityType: map['entity_type']! as String,
      entityId: map['entity_id']! as String,
      payload: map['payload']! as String,
      retryCount: map['retry_count']! as int,
      status: map['status']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}