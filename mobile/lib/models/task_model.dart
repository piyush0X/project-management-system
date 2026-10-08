class Task {
  final int id;
  final int projectId;
  final int userId;
  final String name;
  final String? description;
  final String priority;
  final String status;
  final String? dueDate;
  final String? createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.name,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: _toInt(json['id']),
      projectId: _toInt(json['project_id']),
      userId: _toInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      dueDate: json['due_date']?.toString(),
      createdAt: json['created_at']?.toString(),
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
      final parsed = int.tryParse(value.trim());

      if (parsed != null) {
        return parsed;
      }
    }

    throw Exception(
      'Invalid task ID value: $value',
    );
  }
}