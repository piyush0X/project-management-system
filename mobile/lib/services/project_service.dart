import 'dart:convert';

import '../models/project_model.dart';
import 'api_service.dart';

class ProjectService {
  // Decode and validate server response
  static Map<String, dynamic> decodeResponse(dynamic response) {
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message'] ?? 'Request failed',
      );
    }

    if (body is Map<String, dynamic>) {
      return body;
    }

    throw Exception('Invalid server response');
  }

  // Get all projects
  static Future<List<Project>> getProjects({
    String? token,
  }) async {
    final response = await ApiService.get(
      '/projects',
      token: token,
    );

    final json = decodeResponse(response);

    final data = json['data'];

    if (data is List) {
      return data
          .map(
            (project) => Project.fromJson(
              Map<String, dynamic>.from(project),
            ),
          )
          .toList();
    }

    if (data is Map && data['projects'] is List) {
      return (data['projects'] as List)
          .map(
            (project) => Project.fromJson(
              Map<String, dynamic>.from(project),
            ),
          )
          .toList();
    }

    return [];
  }

  // Get one project
  static Future<Project> getProject(
    int projectId, {
    String? token,
  }) async {
    final response = await ApiService.get(
      '/projects/$projectId',
      token: token,
    );

    final json = decodeResponse(response);

    final data = json['data'];

    if (data is Map && data['project'] != null) {
      return Project.fromJson(
        Map<String, dynamic>.from(data['project']),
      );
    }

    if (data is Map) {
      return Project.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Project data not found');
  }

  // Create project
  static Future<Project> createProject({
    required String name,
    String? description,
    required String status,
    String? startDate,
    String? endDate,
    String? token,
  }) async {
    final response = await ApiService.post(
      '/projects',
      body: {
        'name': name,
        'description': description,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      },
      token: token,
    );

    final json = decodeResponse(response);

    final data = json['data'];

    if (data is Map && data['project'] != null) {
      return Project.fromJson(
        Map<String, dynamic>.from(data['project']),
      );
    }

    if (data is Map) {
      return Project.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Created project data not found');
  }

  // Update project
  static Future<Project> updateProject({
    required int projectId,
    required String name,
    String? description,
    required String status,
    String? startDate,
    String? endDate,
    String? token,
  }) async {
    final response = await ApiService.put(
      '/projects/$projectId',
      body: {
        'name': name,
        'description': description,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      },
      token: token,
    );

    final json = decodeResponse(response);

    final data = json['data'];

    if (data is Map && data['project'] != null) {
      return Project.fromJson(
        Map<String, dynamic>.from(data['project']),
      );
    }

    if (data is Map) {
      return Project.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Updated project data not found');
  }

  // Delete project
  static Future<void> deleteProject(
    int projectId, {
    String? token,
  }) async {
    final response = await ApiService.delete(
      '/projects/$projectId',
      token: token,
    );

    decodeResponse(response);
  }
}