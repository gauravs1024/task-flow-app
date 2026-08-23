import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final int taskCount;
  final String status;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      taskCount: json['task_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'description': description,
      'task_count': taskCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? orgId,
    String? name,
    String? description,
    int? taskCount,
    String? status,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      description: description ?? this.description,
      taskCount: taskCount ?? this.taskCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, orgId, name, description, taskCount, status, createdAt];
}
