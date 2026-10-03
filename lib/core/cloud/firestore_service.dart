import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/comments/models/comment.dart';
import '../../features/tasks/models/task.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(
      String userId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _commentsCollection(
      String userId,
      String taskId,
      ) {
    return _tasksCollection(userId)
        .doc(taskId)
        .collection('comments');
  }

  Future<void> saveTask({
    required String userId,
    required Task task,
  }) async {
    await _tasksCollection(userId)
        .doc(task.id)
        .set({
      'id': task.id,
      'projectId': task.projectId,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'priority': task.priority,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Task>> getTasks({
    required String userId,
    required String projectId,
  }) async {
    final snapshot = await _tasksCollection(userId)
        .where('projectId', isEqualTo: projectId)
        .get();

    return snapshot.docs.map((document) {
      final data = document.data();

      return Task(
        id: data['id'] as String,
        projectId: data['projectId'] as String,
        title: data['title'] as String,
        description: data['description'] as String? ?? '',
        status: data['status'] as String? ?? 'To Do',
        priority: data['priority'] as String? ?? 'Medium',
      );
    }).toList();
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _tasksCollection(userId)
        .doc(taskId)
        .delete();
  }

  Future<void> saveComment({
    required String userId,
    required Comment comment,
  }) async {
    await _commentsCollection(userId, comment.taskId)
        .doc(comment.id)
        .set({
      'id': comment.id,
      'taskId': comment.taskId,
      'text': comment.text,
      'createdAt': Timestamp.fromDate(comment.createdAt),
    });
  }

  Future<List<Comment>> getComments({
    required String userId,
    required String taskId,
  }) async {
    final snapshot = await _commentsCollection(userId, taskId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((document) {
      final data = document.data();
      final timestamp = data['createdAt'] as Timestamp?;

      return Comment(
        id: data['id'] as String,
        taskId: data['taskId'] as String,
        text: data['text'] as String,
        createdAt: timestamp?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> deleteComment({
    required String userId,
    required Comment comment,
  }) async {
    await _commentsCollection(userId, comment.taskId)
        .doc(comment.id)
        .delete();
  }
}