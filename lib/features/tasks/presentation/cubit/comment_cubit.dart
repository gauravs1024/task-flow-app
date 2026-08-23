import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/task_repository.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}
class CommentLoading extends CommentState {}
class CommentSuccess extends CommentState {
  final List<CommentModel> comments;
  const CommentSuccess(this.comments);
  @override
  List<Object?> get props => [comments];
}
class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);
  @override
  List<Object?> get props => [message];
}

class CommentCubit extends Cubit<CommentState> {
  final TaskRepository _taskRepository;

  CommentCubit(this._taskRepository) : super(CommentInitial());

  Future<void> loadComments(String taskId) async {
    emit(CommentLoading());
    try {
      final comments = await _taskRepository.getComments(taskId);
      emit(CommentSuccess(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<bool> addComment(String taskId, String authorId, String body) async {
    try {
      await _taskRepository.addComment(taskId: taskId, authorId: authorId, body: body);
      await loadComments(taskId);
      return true;
    } catch (e) {
      emit(CommentError(e.toString()));
      return false;
    }
  }
}
