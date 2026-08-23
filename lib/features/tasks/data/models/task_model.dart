import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assigneeId;
  final DateTime dueDate;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    required this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      assigneeId: json['assignee_id'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (assigneeId != null) 'assignee_id': assigneeId,
      'due_date': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId, // Note: can pass null explicitly
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, projectId, title, description, status, priority, assigneeId, dueDate, createdAt];
}
