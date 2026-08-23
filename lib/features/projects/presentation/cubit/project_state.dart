import 'package:equatable/equatable.dart';
import '../../data/models/project_model.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectSuccess extends ProjectState {
  final List<ProjectModel> projects;
  final bool isStale;
  
  const ProjectSuccess(this.projects, {this.isStale = false});

  @override
  List<Object?> get props => [projects, isStale];
}

class ProjectEmpty extends ProjectState {}

class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
