import '../../../../core/data/mock_data_source.dart';
import '../models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects(String orgId);
  Future<ProjectModel> createProject({
    required String orgId,
    required String name,
    required String description,
    required String userRole,
  });
  Future<ProjectModel> editProject({
    required String projectId,
    required String name,
    required String description,
    required String userRole,
  });
  Future<void> deleteProject({
    required String projectId,
    required String userRole,
  });
}

class ProjectRepositoryImpl implements ProjectRepository {
  final MockDataSource _dataSource = MockDataSource();

  @override
  Future<List<ProjectModel>> getProjects(String orgId) async {
    // 1. Simulate network latency/errors
    await _dataSource.simulateNetwork();

    // 2. Fetch projects scoped to this organization ID
    final orgProjects = _dataSource.projects
        .where((proj) => proj['org_id'] == orgId)
        .map((proj) => ProjectModel.fromJson(proj))
        .toList();

    return orgProjects;
  }

  @override
  Future<ProjectModel> createProject({
    required String orgId,
    required String name,
    required String description,
    required String userRole,
  }) async {
    await _dataSource.simulateNetwork();

    // Validate role (Only admin should create projects)
    if (userRole != 'org_admin') {
      throw ValidationException('Unauthorized: Only organization admins can create projects');
    }

    if (name.trim().isEmpty) {
      throw ValidationException('Project name cannot be empty');
    }

    final newProjectId = 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final newProjectMap = {
      'id': newProjectId,
      'org_id': orgId,
      'name': name.trim(),
      'description': description.trim(),
      'task_count': 0,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    };

    _dataSource.projects.add(newProjectMap);
    return ProjectModel.fromJson(newProjectMap);
  }

  @override
  Future<ProjectModel> editProject({
    required String projectId,
    required String name,
    required String description,
    required String userRole,
  }) async {
    await _dataSource.simulateNetwork();

    // Validate role
    if (userRole != 'org_admin') {
      throw ValidationException('Unauthorized: Only organization admins can edit projects');
    }

    if (name.trim().isEmpty) {
      throw ValidationException('Project name cannot be empty');
    }

    final index = _dataSource.projects.indexWhere((proj) => proj['id'] == projectId);
    if (index == -1) {
      throw NotFoundException('Project not found');
    }

    final existing = _dataSource.projects[index];
    final updatedProjectMap = {
      ...existing,
      'name': name.trim(),
      'description': description.trim(),
    };

    _dataSource.projects[index] = updatedProjectMap;
    return ProjectModel.fromJson(updatedProjectMap);
  }

  @override
  Future<void> deleteProject({
    required String projectId,
    required String userRole,
  }) async {
    await _dataSource.simulateNetwork();

    // Enforce role-based block inside data/repo layer (Task 03 - Authorization)
    if (userRole != 'org_admin') {
      throw ValidationException('Unauthorized: Only organization admins can delete projects');
    }

    final index = _dataSource.projects.indexWhere((proj) => proj['id'] == projectId);
    if (index == -1) {
      throw NotFoundException('Project not found');
    }

    _dataSource.projects.removeAt(index);

    // Clean up related tasks and comments (simulating cascade delete)
    final projectTasks = _dataSource.tasks.where((t) => t['project_id'] == projectId).map((t) => t['id'] as String).toList();
    _dataSource.tasks.removeWhere((t) => t['project_id'] == projectId);
    _dataSource.comments.removeWhere((c) => projectTasks.contains(c['task_id']));
  }
}
