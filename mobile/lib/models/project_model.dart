class Project {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? createdAt;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      status: json['status'] ?? 'Not Started',
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'],
    );
  }
}