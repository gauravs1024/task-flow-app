import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock_data_source.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;
  List<TaskModel> _cachedTasks = [];

  TaskCubit(this._taskRepository) : super(TaskInitial());

  Future<void> loadTasks(String projectId) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getTasksForProject(projectId);
      _cachedTasks = tasks;
      if (tasks.isEmpty) {
        emit(TaskEmpty());
      } else {
        emit(TaskSuccess(tasks, isStale: MockDataSource().isOffline));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<bool> createTask(TaskModel task, String userOrgId) async {
    try {
      await _taskRepository.createTask(task, userOrgId);
      await loadTasks(task.projectId);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      _restoreCache();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task, String userOrgId) async {
    try {
      await _taskRepository.updateTask(task, userOrgId);
      await loadTasks(task.projectId);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      _restoreCache();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId, String projectId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      await loadTasks(projectId);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      _restoreCache();
      return false;
    }
  }

  void _restoreCache() {
    if (_cachedTasks.isEmpty) {
      emit(TaskEmpty());
    } else {
      emit(TaskSuccess(_cachedTasks));
    }
  }
}
