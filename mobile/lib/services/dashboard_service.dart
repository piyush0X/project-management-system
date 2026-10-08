import 'dart:convert';

import 'api_service.dart';

class DashboardStats {
  final int totalProjects;
  final int completedProjects;
  final int inProgressProjects;
  final int notStartedProjects;

  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;

  DashboardStats({
    required this.totalProjects,
    required this.completedProjects,
    required this.inProgressProjects,
    required this.notStartedProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
  });

  factory DashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardStats(
      // -----------------------------
      // PROJECTS
      // -----------------------------

      totalProjects: _toInt(
        json['total_projects'],
      ),

      completedProjects: _toInt(
        json['completed_projects'],
      ),

      inProgressProjects: _toInt(
        json['in_progress_projects'],
      ),

      notStartedProjects: _toInt(
        json['not_started_projects'],
      ),

      // -----------------------------
      // TASKS
      // -----------------------------

      totalTasks: _toInt(
        json['total_tasks'],
      ),

      completedTasks: _toInt(
        json['completed_tasks'],
      ),

      inProgressTasks: _toInt(
        json['in_progress_tasks'],
      ),

      pendingTasks: _toInt(
        json['pending_tasks'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}

class DashboardService {
  static Future<DashboardStats> getStats({
    String? token,
  }) async {
    final response = await ApiService.get(
      '/dashboard',
      token: token,
    );

    final body = jsonDecode(response.body);

    // -----------------------------
    // API ERROR
    // -----------------------------

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        body['message'] ??
            'Failed to load dashboard',
      );
    }

    // -----------------------------
    // DASHBOARD DATA
    // -----------------------------

    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return DashboardStats.fromJson(data);
    }

    if (data is Map) {
      return DashboardStats.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      'Invalid dashboard response',
    );
  }
}