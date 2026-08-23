import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/presentation/cubit/task_state.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import '../../../tasks/presentation/screens/task_form_screen.dart';
import '../../../tasks/presentation/screens/task_list_screen.dart';
import '../../data/models/project_model.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCubit>(
      create: (context) => TaskCubit(context.read<TaskRepository>())
        ..loadTasks(widget.project.id),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.project.name),
            ),
            body: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                final isStale = state is TaskSuccess && state.isStale;
                return Column(
                  children: [
                    if (isStale)
                      Container(
                        width: double.infinity,
                        color: AppColors.warning.withValues(alpha: 0.15),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off, color: AppColors.warning, size: 16),
                            SizedBox(width: 8.w),
                            const Text(
                              'Stale Data (Offline Mode)',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context.read<TaskCubit>().loadTasks(widget.project.id),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Project description
                              Text(
                                widget.project.description.isNotEmpty
                                    ? widget.project.description
                                    : LocaleKeys.project_no_description.tr(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              SizedBox(height: 24.h),

                              // Task counts header
                              Text(
                                LocaleKeys.project_task_summary.tr(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 12.h),

                              // Task counts cards
                              Row(
                                children: [
                                  Expanded(child: _buildCountCard('Todo', _countStatus(state, TaskStatus.todo), AppColors.statusTodo)),
                                  SizedBox(width: 8.w),
                                  Expanded(child: _buildCountCard('Active', _countStatus(state, TaskStatus.inProgress), AppColors.statusInProgress)),
                                  SizedBox(width: 8.w),
                                  Expanded(child: _buildCountCard('Review', _countStatus(state, TaskStatus.review), AppColors.statusReview)),
                                  SizedBox(width: 8.w),
                                  Expanded(child: _buildCountCard('Done', _countStatus(state, TaskStatus.done), AppColors.statusDone)),
                                ],
                              ),
                              SizedBox(height: 28.h),

                              // Task List header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.project_tasks_list_header.tr(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.filter_list, color: AppColors.primary),
                                        onPressed: () {
                                          final authState = context.read<AuthCubit>().state as AuthAuthenticated;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (innerContext) => MultiBlocProvider(
                                                providers: [
                                                  BlocProvider.value(value: context.read<TaskCubit>()),
                                                  RepositoryProvider.value(value: context.read<TaskRepository>()),
                                                ],
                                                child: TaskListScreen(
                                                  projectId: widget.project.id,
                                                  userRole: authState.user.role ?? '',
                                                  orgId: authState.user.orgId ?? '',
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (innerContext) => BlocProvider.value(
                                                value: context.read<TaskCubit>(),
                                                child: TaskFormScreen(projectId: widget.project.id),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Tasks list view
                              _buildTasksList(state),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  int _countStatus(TaskState state, TaskStatus status) {
    if (state is TaskSuccess) {
      return state.tasks.where((t) => t.status == status).length;
    }
    return 0;
  }

  Widget _buildTasksList(TaskState state) {
    if (state is TaskLoading) {
      return const SizedBox(
        height: 240,
        child: TaskListSkeleton(count: 3),
      );
    }
    if (state is TaskEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(LocaleKeys.empty_tasks.tr()),
      );
    }
    if (state is TaskError) {
      return Container(
        padding: EdgeInsets.all(16.r),
        color: AppColors.error.withValues(alpha: 0.1),
        child: Text(
          state.message,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }
    if (state is TaskSuccess) {
      final tasks = state.tasks;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            child: ListTile(
              onTap: () {
                final authState = context.read<AuthCubit>().state as AuthAuthenticated;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => BlocProvider.value(
                      value: context.read<TaskCubit>(),
                      child: TaskDetailScreen(
                        task: task,
                        userRole: authState.user.role ?? '',
                      ),
                    ),
                  ),
                );
              },
              title: Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Due: ${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12.sp),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: task.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  task.status.label.toUpperCase(),
                  style: TextStyle(
                    color: task.status.color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildCountCard(String title, int count, Color color) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

