import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/mock_data_source.dart';
import '../../../../core/utils/logger.dart';
import '../models/comment_model.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasksForProject(String projectId);
  Future<TaskModel> createTask(TaskModel task, String userOrgId);
  Future<TaskModel> updateTask(TaskModel task, String userOrgId);
  Future<void> deleteTask(String taskId);
  
  // Comments
  Future<List<CommentModel>> getComments(String taskId);
  Future<CommentModel> addComment({
    required String taskId,
    required String authorId,
    required String body,
  });

  // Organization members query
  Future<List<Map<String, dynamic>>> getOrganizationMembers(String orgId);
  Future<Map<String, dynamic>?> getUserDetails(String userId);
}

class TaskRepositoryImpl implements TaskRepository {
  final MockDataSource _dataSource = MockDataSource();
  final SharedPreferences _prefs;

  TaskRepositoryImpl(this._prefs);

  @override
  Future<List<TaskModel>> getTasksForProject(String projectId) async {
    AppLogger.info('TaskRepositoryImpl.getTasksForProject called for projectId: $projectId');
    try {
      await _dataSource.simulateNetwork();

      final projectTasks = _dataSource.tasks
          .where((t) => t['project_id'] == projectId)
          .map((t) => TaskModel.fromJson(t))
          .toList();

      // Cache tasks locally
      final jsonStr = json.encode(projectTasks.map((t) => t.toJson()).toList());
      await _prefs.setString('tasks_cache_$projectId', jsonStr);

      return projectTasks;
    } on OfflineException {
      // Offline fallback: load from local cache
      final cachedStr = _prefs.getString('tasks_cache_$projectId');
      if (cachedStr != null) {
        final decoded = json.decode(cachedStr) as List;
        return decoded.map((t) => TaskModel.fromJson(t as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task, String userOrgId) async {
    AppLogger.info('TaskRepositoryImpl.createTask called for projectId: ${task.projectId}, title: ${task.title}');
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
    AppLogger.info('TaskRepositoryImpl.updateTask called for taskId: ${task.id}, title: ${task.title}');
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
    AppLogger.warning('TaskRepositoryImpl.deleteTask called for taskId: $taskId');
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

  @override
  Future<List<CommentModel>> getComments(String taskId) async {
    AppLogger.info('TaskRepositoryImpl.getComments called for taskId: $taskId');
    try {
      await _dataSource.simulateNetwork();

      final taskComments = _dataSource.comments
          .where((c) => c['task_id'] == taskId)
          .map((c) => CommentModel.fromJson(c))
          .toList();

      // Sort by created date ascending
      taskComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Cache comments locally
      final jsonStr = json.encode(taskComments.map((c) => c.toJson()).toList());
      await _prefs.setString('comments_cache_$taskId', jsonStr);

      return taskComments;
    } on OfflineException {
      // Offline fallback: load comments from local cache
      final cachedStr = _prefs.getString('comments_cache_$taskId');
      if (cachedStr != null) {
        final decoded = json.decode(cachedStr) as List;
        final list = decoded.map((c) => CommentModel.fromJson(c as Map<String, dynamic>)).toList();
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return list;
      }
      rethrow;
    }
  }

  @override
  Future<CommentModel> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) async {
    AppLogger.info('TaskRepositoryImpl.addComment called for taskId: $taskId, authorId: $authorId');
    await _dataSource.simulateNetwork();

    if (body.trim().isEmpty) {
      throw ValidationException('Comment body cannot be empty');
    }

    final newCommentMap = {
      'id': 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      'task_id': taskId,
      'author_id': authorId,
      'body': body.trim(),
      'created_at': DateTime.now().toIso8601String(),
    };

    _dataSource.comments.add(newCommentMap);
    return CommentModel.fromJson(newCommentMap);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizationMembers(String orgId) async {
    await _dataSource.simulateNetwork();

    final memberUserIds = _dataSource.orgMembers
        .where((m) => m['org_id'] == orgId)
        .map((m) => m['user_id'] as String)
        .toList();

    final members = _dataSource.users
        .where((u) => memberUserIds.contains(u['id']))
        .toList();

    return members;
  }

  @override
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final user = _dataSource.users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );
    return user.isEmpty ? null : user;
  }
}
