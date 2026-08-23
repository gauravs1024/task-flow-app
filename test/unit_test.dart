import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow_app/core/enums/app_enums.dart';
import 'package:task_flow_app/features/auth/data/models/auth_token_model.dart';
import 'package:task_flow_app/features/auth/data/models/user_model.dart';
import 'package:task_flow_app/features/tasks/data/models/task_model.dart';

void main() {
  group('Unit Tests - Validation & Auth Logic', () {
    test('UserModel JSON Parsing', () {
      final json = {
        'id': 'user_001',
        'name': 'Ava Thompson',
        'email': 'ava.admin@nimbusdigital.test',
        'avatar_url': 'https://i.pravatar.cc/150?img=1'
      };

      final user = UserModel.fromJson(json, orgId: 'org_a1b2c3', role: 'org_admin');

      expect(user.id, 'user_001');
      expect(user.name, 'Ava Thompson');
      expect(user.email, 'ava.admin@nimbusdigital.test');
      expect(user.orgId, 'org_a1b2c3');
      expect(user.role, 'org_admin');
    });

    test('AuthTokenModel Lifespan Expiry Check', () {
      final base = DateTime.now();

      final tokens = AuthTokenModel(
        accessToken: 'mock_access',
        refreshToken: 'mock_refresh',
        accessTokenExpiry: base.subtract(const Duration(seconds: 1)),
        refreshTokenExpiry: base.add(const Duration(hours: 1)),
      );

      expect(tokens.isAccessTokenExpired, isTrue);
      expect(tokens.isRefreshTokenExpired, isFalse);
    });

    test('Validation logic constraints', () {
      bool isValidEmail(String email) => email.contains('@') && email.trim().isNotEmpty;

      expect(isValidEmail('testemail'), isFalse);
      expect(isValidEmail('test@email.com'), isTrue);
      expect(isValidEmail(' '), isFalse);
    });
  });

  group('Unit Tests - Enum Parsing', () {
    test('TaskStatus.fromJson returns correct enum values', () {
      expect(TaskStatus.fromJson('todo'), TaskStatus.todo);
      expect(TaskStatus.fromJson('in_progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromJson('review'), TaskStatus.review);
      expect(TaskStatus.fromJson('done'), TaskStatus.done);
      expect(TaskStatus.fromJson(null), TaskStatus.todo); // default
    });

    test('TaskStatus.toJson returns correct JSON strings', () {
      expect(TaskStatus.todo.toJson(), 'todo');
      expect(TaskStatus.inProgress.toJson(), 'in_progress');
      expect(TaskStatus.review.toJson(), 'review');
      expect(TaskStatus.done.toJson(), 'done');
    });

    test('TaskPriority.fromJson returns correct enum values', () {
      expect(TaskPriority.fromJson('low'), TaskPriority.low);
      expect(TaskPriority.fromJson('medium'), TaskPriority.medium);
      expect(TaskPriority.fromJson('high'), TaskPriority.high);
      expect(TaskPriority.fromJson('urgent'), TaskPriority.urgent);
      expect(TaskPriority.fromJson(null), TaskPriority.medium); // default
    });

    test('AppThemeMode.fromString and toFlutterThemeMode', () {
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
      expect(AppThemeMode.fromString('unknown'), AppThemeMode.system);
    });
  });

  group('Unit Tests - Task Filtering & Models', () {
    test('TaskModel construction and copyWith with enums', () {
      final task = TaskModel(
        id: 'task_001',
        projectId: 'proj_1001',
        title: 'Review specifications',
        description: 'Check detail specifications',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        assigneeId: 'user_001',
        dueDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2025, 12, 1),
      );

      // Status change should preserve assigneeId
      final statusCopy = task.copyWith(status: TaskStatus.done);
      expect(statusCopy.status, TaskStatus.done);
      expect(statusCopy.id, task.id);
      expect(statusCopy.projectId, task.projectId);
      expect(statusCopy.priority, TaskPriority.high);
      expect(statusCopy.assigneeId, 'user_001');

      // Priority change should preserve assigneeId
      final priorityCopy = task.copyWith(priority: TaskPriority.urgent);
      expect(priorityCopy.priority, TaskPriority.urgent);
      expect(priorityCopy.status, TaskStatus.todo);
      expect(priorityCopy.assigneeId, 'user_001');

      // Assignee change should update assigneeId
      final reassignCopy = task.copyWith(assigneeId: 'user_002');
      expect(reassignCopy.assigneeId, 'user_002');

      // Explicit unassign should set assigneeId to null
      final unassignCopy = task.copyWith(assigneeId: null);
      expect(unassignCopy.assigneeId, isNull);
    });

    test('TaskModel JSON round-trip', () {
      final task = TaskModel(
        id: 'task_002',
        projectId: 'proj_1001',
        title: 'Deploy service',
        description: '',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        dueDate: DateTime(2026, 3, 15),
        createdAt: DateTime(2026, 1, 1),
      );

      final json = task.toJson();
      expect(json['status'], 'in_progress');
      expect(json['priority'], 'urgent');

      final restored = TaskModel.fromJson(json);
      expect(restored.status, TaskStatus.inProgress);
      expect(restored.priority, TaskPriority.urgent);
    });

    test('Task list filtering by enum status and priority', () {
      final tasks = [
        TaskModel(
          id: '1',
          projectId: 'p1',
          title: 'Task 1',
          description: '',
          status: TaskStatus.todo,
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '2',
          projectId: 'p1',
          title: 'Task 2',
          description: '',
          status: TaskStatus.inProgress,
          priority: TaskPriority.medium,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '3',
          projectId: 'p1',
          title: 'Task 3',
          description: '',
          status: TaskStatus.done,
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      // Filter by status
      final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
      expect(todoTasks.length, 1);
      expect(todoTasks.first.id, '1');

      // Filter by priority
      final highPriority = tasks.where((t) => t.priority == TaskPriority.high).toList();
      expect(highPriority.length, 2);
    });
  });
}
