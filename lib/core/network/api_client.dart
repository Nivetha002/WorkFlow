import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/tasks/models/task.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  Future<List<Task>> fetchTasks({
    required String projectId,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/todos'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch tasks: ${response.statusCode}',
      );
    }

    final decodedData = jsonDecode(response.body);

    if (decodedData is! List) {
      throw Exception('Invalid task response');
    }

    return decodedData.take(10).map((item) {
      final data = item as Map<String, dynamic>;
      final isCompleted = data['completed'] == true;

      return Task(
        id: 'api-${data['id']}',
        projectId: projectId,
        title: data['title'] as String,
        description: 'Task loaded from remote API.',
        status: isCompleted ? 'Done' : 'To Do',
        priority: 'Medium',
      );
    }).toList();
  }

  Future<void> updateTask(Task task) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/todos/${task.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': task.id,
        'title': task.title,
        'completed': task.status == 'Done',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update task: ${response.statusCode}',
      );
    }
  }

  Future<void> createTask(Task task) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/todos'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': task.title,
        'completed': task.status == 'Done',
        'userId': 1,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to create task: ${response.statusCode}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}