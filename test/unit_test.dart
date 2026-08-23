import 'package:flutter_test/flutter_test.dart';
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
      // Test invalid email formatting helper
      bool isValidEmail(String email) => email.contains('@') && email.trim().isNotEmpty;
      
      expect(isValidEmail('testemail'), isFalse);
      expect(isValidEmail('test@email.com'), isTrue);
      expect(isValidEmail(' '), isFalse);
    });
  });

  group('Unit Tests - Task Filtering & Models', () {
    test('TaskModel JSON serialization & copyWith', () {
      final task = TaskModel(
        id: 'task_001',
        projectId: 'proj_1001',
        title: 'Review specifications',
        description: 'Check detail specifications',
        status: 'todo',
        priority: 'high',
        dueDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2025, 12, 1),
      );

      final copy = task.copyWith(status: 'done');
      expect(copy.status, 'done');
      expect(copy.id, task.id);
      expect(copy.projectId, task.projectId);
      expect(copy.priority, 'high');
    });

    test('Task list filtering logic simulation', () {
      final tasks = [
        TaskModel(
          id: '1',
          projectId: 'p1',
          title: 'Task 1',
          description: '',
          status: 'todo',
          priority: 'high',
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '2',
          projectId: 'p1',
          title: 'Task 2',
          description: '',
          status: 'in_progress',
          priority: 'medium',
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '3',
          projectId: 'p1',
          title: 'Task 3',
          description: '',
          status: 'done',
          priority: 'high',
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      // Filter by status == 'todo'
      final todoTasks = tasks.where((t) => t.status == 'todo').toList();
      expect(todoTasks.length, 1);
      expect(todoTasks.first.id, '1');

      // Filter by priority == 'high'
      final highPriority = tasks.where((t) => t.priority == 'high').toList();
      expect(highPriority.length, 2);
    });
  });
}
