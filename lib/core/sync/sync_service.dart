import 'dart:convert';

import '../../features/tasks/models/task.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import 'sync_operation.dart';

class SyncService {
  SyncService({
    AppDatabase? database,
    ApiClient? apiClient,
  })  : _database = database ?? AppDatabase.instance,
        _apiClient = apiClient ?? ApiClient();

  final AppDatabase _database;
  final ApiClient _apiClient;

  Future<void> queueTaskUpdate(Task task) async {
    final pendingTask = task.copyWith(
      syncStatus: 'pending',
    );

    await _database.updateTask(pendingTask);

    final operation = SyncOperation(
      id: null,
      operationType: 'update',
      entityType: 'task',
      entityId: task.id,
      payload: jsonEncode(pendingTask.toMap()),
      retryCount: 0,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _database.addSyncOperation(operation);
  }

  Future<void> queueTaskCreate(Task task) async {
    final pendingTask = task.copyWith(
      syncStatus: 'pending',
    );

    await _database.insertTask(pendingTask);

    final operation = SyncOperation(
      id: null,
      operationType: 'create',
      entityType: 'task',
      entityId: task.id,
      payload: jsonEncode(pendingTask.toMap()),
      retryCount: 0,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _database.addSyncOperation(operation);
  }

  Future<List<SyncOperation>> getPendingOperations() {
    return _database.getPendingSyncOperations();
  }

  Future<void> syncPendingOperations() async {
    final operations = await _database.getPendingSyncOperations();

    for (final operation in operations) {
      try {
        final task = Task.fromJsonString(operation.payload);

        if (operation.operationType == 'update') {
          await _apiClient.updateTask(task);
        } else if (operation.operationType == 'create') {
          await _apiClient.createTask(task);
        }

        await clearOperation(operation);
      } catch (_) {
        await markOperationFailed(operation);
      }
    }
  }

  Future<void> clearOperation(SyncOperation operation) async {
    if (operation.id == null) {
      return;
    }

    await _database.removeSyncOperation(operation.id!);
    await _database.markTaskSynced(operation.entityId);
  }

  Future<void> markOperationFailed(
      SyncOperation operation,
      ) async {
    if (operation.id == null) {
      return;
    }

    await _database.increaseSyncRetryCount(operation.id!);
    await _database.markTaskSyncFailed(operation.entityId);
  }

  void dispose() {
    _apiClient.dispose();
  }
}