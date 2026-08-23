import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/models/project_model.dart';
import 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository _projectRepository;
  List<ProjectModel> _cachedProjects = [];

  ProjectCubit(this._projectRepository) : super(ProjectInitial());

  Future<void> loadProjects(String orgId) async {
    emit(ProjectLoading());
    try {
      final projects = await _projectRepository.getProjects(orgId);
      _cachedProjects = projects;
      if (projects.isEmpty) {
        emit(ProjectEmpty());
      } else {
        emit(ProjectSuccess(projects));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<bool> createProject({
    required String orgId,
    required String name,
    required String description,
    required String userRole,
  }) async {
    try {
      await _projectRepository.createProject(
        orgId: orgId,
        name: name,
        description: description,
        userRole: userRole,
      );
      await loadProjects(orgId);
      return true;
    } catch (e) {
      emit(ProjectError(e.toString()));
      if (_cachedProjects.isEmpty) {
        emit(ProjectEmpty());
      } else {
        emit(ProjectSuccess(_cachedProjects));
      }
      return false;
    }
  }

  Future<bool> editProject({
    required String orgId,
    required String projectId,
    required String name,
    required String description,
    required String userRole,
  }) async {
    try {
      await _projectRepository.editProject(
        projectId: projectId,
        name: name,
        description: description,
        userRole: userRole,
      );
      await loadProjects(orgId);
      return true;
    } catch (e) {
      emit(ProjectError(e.toString()));
      if (_cachedProjects.isEmpty) {
        emit(ProjectEmpty());
      } else {
        emit(ProjectSuccess(_cachedProjects));
      }
      return false;
    }
  }

  Future<bool> deleteProject({
    required String orgId,
    required String projectId,
    required String userRole,
  }) async {
    try {
      await _projectRepository.deleteProject(
        projectId: projectId,
        userRole: userRole,
      );
      await loadProjects(orgId);
      return true;
    } catch (e) {
      emit(ProjectError(e.toString()));
      if (_cachedProjects.isEmpty) {
        emit(ProjectEmpty());
      } else {
        emit(ProjectSuccess(_cachedProjects));
      }
      return false;
    }
  }
}
