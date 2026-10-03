import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/comments/models/comment.dart';
import '../../features/tasks/models/task.dart';
import '../sync/sync_operation.dart';
import '../../features/attachments/models/attachment.dart';


class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'workflow.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            project_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'synced'
          )
        ''');

        await database.execute('''
          CREATE TABLE comments (
            id TEXT PRIMARY KEY,
            task_id TEXT NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation_type TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            retry_count INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'pending',
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE attachments (
            id TEXT PRIMARY KEY,
            task_id TEXT NOT NULL,
            file_name TEXT NOT NULL,
            file_path TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('''
            CREATE TABLE comments (
              id TEXT PRIMARY KEY,
              task_id TEXT NOT NULL,
              text TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          await database.execute('''
            ALTER TABLE tasks
            ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'
          ''');

          await database.execute('''
            CREATE TABLE sync_queue (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              operation_type TEXT NOT NULL,
              entity_type TEXT NOT NULL,
              entity_id TEXT NOT NULL,
              payload TEXT NOT NULL,
              retry_count INTEGER NOT NULL DEFAULT 0,
              status TEXT NOT NULL DEFAULT 'pending',
              created_at TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 4) {
          await database.execute('''
            CREATE TABLE attachments (
              id TEXT PRIMARY KEY,
              task_id TEXT NOT NULL,
              file_name TEXT NOT NULL,
              file_path TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
                }
      },
    );
  }

  Future<void> insertTask(Task task) async {
    final database = await this.database;

    await database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasksByProject(String projectId) async {
    final database = await this.database;

    final rows = await database.query(
      'tasks',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'rowid DESC',
    );

    return rows.map(Task.fromMap).toList();
  }

  Future<void> updateTask(Task task) async {
    final database = await this.database;

    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final database = await this.database;

    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );

    await database.delete(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> replaceTasksForProject(
      String projectId,
      List<Task> tasks,
      ) async {
    final database = await this.database;

    await database.transaction((transaction) async {
      await transaction.delete(
        'tasks',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );

      for (final task in tasks) {
        await transaction.insert(
          'tasks',
          task.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertComment(Comment comment) async {
    final database = await this.database;

    await database.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comment>> getCommentsByTask(String taskId) async {
    final database = await this.database;

    final rows = await database.query(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );

    return rows.map(Comment.fromMap).toList();
  }

  Future<void> deleteComment(String commentId) async {
    final database = await this.database;

    await database.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  Future<void> addSyncOperation(SyncOperation operation) async {
    final database = await this.database;

    await database.insert(
      'sync_queue',
      operation.toMap(),
    );
  }

  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final database = await this.database;

    final rows = await database.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    return rows.map(SyncOperation.fromMap).toList();
  }

  Future<void> markTaskPending(String taskId) async {
    final database = await this.database;

    await database.update(
      'tasks',
      {'sync_status': 'pending'},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> markTaskSynced(String taskId) async {
    final database = await this.database;

    await database.update(
      'tasks',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> markTaskSyncFailed(String taskId) async {
    final database = await this.database;

    await database.update(
      'tasks',
      {'sync_status': 'failed'},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> removeSyncOperation(int operationId) async {
    final database = await this.database;

    await database.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> increaseSyncRetryCount(int operationId) async {
    final database = await this.database;

    await database.rawUpdate(
      '''
      UPDATE sync_queue
      SET retry_count = retry_count + 1,
          status = 'failed'
      WHERE id = ?
      ''',
      [operationId],
    );
  }

  Future<void> insertAttachment(Attachment attachment) async {
    final database = await this.database;

    await database.insert(
      'attachments',
      attachment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Attachment>> getAttachmentsByTask(String taskId) async {
    final database = await this.database;

    final rows = await database.query(
      'attachments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );

    return rows.map(Attachment.fromMap).toList();
  }

  Future<void> deleteAttachment(String attachmentId) async {
    final database = await this.database;

    await database.delete(
      'attachments',
      where: 'id = ?',
      whereArgs: [attachmentId],
    );
  }
}