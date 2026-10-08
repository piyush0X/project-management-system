import 'dart:convert';

import '../models/task_model.dart';
import 'api_service.dart';

class TaskService {
  static Map<String, dynamic> decodeResponse(
    dynamic response,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        body['message'] ?? 'Request failed',
      );
    }

    if (body is Map<String, dynamic>) {
      return body;
    }

    throw Exception(
      'Invalid server response',
    );
  }

  // GET TASKS FOR A PROJECT
  static Future<List<Task>> getTasks(
    int projectId, {
    String? token,
  }) async {
    final response = await ApiService.get(
      '/projects/$projectId/tasks',
      token: token,
    );

    final decoded = decodeResponse(response);

    final data = decoded['data'];

    if (data is List) {
      return data
          .map(
            (task) => Task.fromJson(
              Map<String, dynamic>.from(task),
            ),
          )
          .toList();
    }

    if (data is Map &&
        data['tasks'] is List) {
      return (data['tasks'] as List)
          .map(
            (task) => Task.fromJson(
              Map<String, dynamic>.from(task),
            ),
          )
          .toList();
    }

    return [];
  }

  // GET SINGLE TASK
  static Future<Task> getTask(
    int taskId, {
    String? token,
  }) async {
    final response = await ApiService.get(
      '/tasks/$taskId',
      token: token,
    );

    final decoded = decodeResponse(response);

    final data = decoded['data'];

    if (data is Map &&
        data['task'] != null) {
      return Task.fromJson(
        Map<String, dynamic>.from(data['task']),
      );
    }

    if (data is Map &&
        data['id'] != null) {
      return Task.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      'Task data not found',
    );
  }

  // CREATE TASK
  static Future<Task> createTask({
    required int projectId,
    required String name,
    String? description,
    required String priority,
    required String status,
    String? dueDate,
    String? token,
  }) async {
    final response = await ApiService.post(
      '/projects/$projectId/tasks',
      body: {
        'name': name,
        'description': description,
        'priority': priority,
        'status': status,
        'due_date': dueDate,
      },
      token: token,
    );

    print(
      'CREATE TASK STATUS: ${response.statusCode}',
    );

    print(
      'CREATE TASK RESPONSE: ${response.body}',
    );

    final decoded = decodeResponse(response);

    final data = decoded['data'];

    // Expected response:
    // {
    //   "message": "...",
    //   "data": {
    //     "task": {...}
    //   }
    // }
    if (data is Map &&
        data['task'] is Map) {
      return Task.fromJson(
        Map<String, dynamic>.from(
          data['task'],
        ),
      );
    }

    // Also support:
    // {
    //   "message": "...",
    //   "data": {...task fields...}
    // }
    if (data is Map &&
        data['id'] != null) {
      return Task.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      'Created task data not found',
    );
  }

  // UPDATE TASK
  static Future<Task> updateTask({
    required int taskId,
    required String name,
    String? description,
    required String priority,
    required String status,
    String? dueDate,
    String? token,
  }) async {
    final response = await ApiService.put(
      '/tasks/$taskId',
      body: {
        'name': name,
        'description': description,
        'priority': priority,
        'status': status,
        'due_date': dueDate,
      },
      token: token,
    );

    final decoded = decodeResponse(response);

    final data = decoded['data'];

    if (data is Map &&
        data['task'] is Map) {
      return Task.fromJson(
        Map<String, dynamic>.from(
          data['task'],
        ),
      );
    }

    if (data is Map &&
        data['id'] != null) {
      return Task.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      'Updated task data not found',
    );
  }

  // DELETE TASK
  static Future<void> deleteTask(
    int taskId, {
    String? token,
  }) async {
    final response = await ApiService.delete(
      '/tasks/$taskId',
      token: token,
    );

    decodeResponse(response);
  }
}