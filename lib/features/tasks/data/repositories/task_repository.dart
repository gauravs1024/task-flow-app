import '../../../../core/data/mock_data_source.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasksForProject(String projectId);
  Future<TaskModel> createTask(TaskModel task, String userOrgId);
  Future<TaskModel> updateTask(TaskModel task, String userOrgId);
  Future<void> deleteTask(String taskId);
}

class TaskRepositoryImpl implements TaskRepository {
  final MockDataSource _dataSource = MockDataSource();

  @override
  Future<List<TaskModel>> getTasksForProject(String projectId) async {
    await _dataSource.simulateNetwork();

    final projectTasks = _dataSource.tasks
        .where((t) => t['project_id'] == projectId)
        .map((t) => TaskModel.fromJson(t))
        .toList();

    return projectTasks;
  }

  @override
  Future<TaskModel> createTask(TaskModel task, String userOrgId) async {
    await _dataSource.simulateNetwork();

    if (task.title.trim().isEmpty) {
      throw ValidationException('Task title cannot be empty');
    }

    // Task 05 - Validate assignee belongs to the current organization in the BLoC/Repository layer
    if (task.assigneeId != null) {
      final isMember = _dataSource.orgMembers.any(
        (m) => m['org_id'] == userOrgId && m['user_id'] == task.assigneeId,
      );
      if (!isMember) {
        throw ValidationException('Unauthorized: Assigned user is not a member of this organization');
      }
    }

    final newTaskId = 'task_${DateTime.now().millisecondsSinceEpoch}';
    final newTaskMap = {
      ...task.toJson(),
      'id': newTaskId,
      'created_at': DateTime.now().toIso8601String(),
    };

    _dataSource.tasks.add(newTaskMap);

    // Increment task_count on project in-memory
    final projIndex = _dataSource.projects.indexWhere((p) => p['id'] == task.projectId);
    if (projIndex != -1) {
      final currentCount = _dataSource.projects[projIndex]['task_count'] as int? ?? 0;
      _dataSource.projects[projIndex]['task_count'] = currentCount + 1;
    }

    return TaskModel.fromJson(newTaskMap);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task, String userOrgId) async {
    await _dataSource.simulateNetwork();

    if (task.title.trim().isEmpty) {
      throw ValidationException('Task title cannot be empty');
    }

    // Task 05 - Validate assignee belongs to the current organization
    if (task.assigneeId != null) {
      final isMember = _dataSource.orgMembers.any(
        (m) => m['org_id'] == userOrgId && m['user_id'] == task.assigneeId,
      );
      if (!isMember) {
        throw ValidationException('Unauthorized: Assigned user is not a member of this organization');
      }
    }

    final index = _dataSource.tasks.indexWhere((t) => t['id'] == task.id);
    if (index == -1) {
      throw NotFoundException('Task not found');
    }

    final updatedTaskMap = task.toJson();
    _dataSource.tasks[index] = updatedTaskMap;

    return TaskModel.fromJson(updatedTaskMap);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _dataSource.simulateNetwork();

    final index = _dataSource.tasks.indexWhere((t) => t['id'] == taskId);
    if (index == -1) {
      throw NotFoundException('Task not found');
    }

    final projectId = _dataSource.tasks[index]['project_id'] as String;
    _dataSource.tasks.removeAt(index);

    // Decrement task_count on project in-memory
    final projIndex = _dataSource.projects.indexWhere((p) => p['id'] == projectId);
    if (projIndex != -1) {
      final currentCount = _dataSource.projects[projIndex]['task_count'] as int? ?? 0;
      if (currentCount > 0) {
        _dataSource.projects[projIndex]['task_count'] = currentCount - 1;
      }
    }

    // Clean up comments for this task
    _dataSource.comments.removeWhere((c) => c['task_id'] == taskId);
  }
}
