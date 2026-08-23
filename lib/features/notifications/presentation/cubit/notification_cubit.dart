import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  const NotificationSuccess(this.notifications);
  @override
  List<Object?> get props => [notifications];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> loadNotifications(String userId) async {
    emit(NotificationLoading());
    try {
      final notifs = await _repository.getNotifications(userId);
      emit(NotificationSuccess(notifs));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String notifId, String userId) async {
    try {
      await _repository.markAsRead(notifId);
      final notifs = await _repository.getNotifications(userId);
      emit(NotificationSuccess(notifs));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
