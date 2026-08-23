import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/presentation/cubit/task_state.dart';
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
            body: RefreshIndicator(
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
                          : 'No description provided.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    SizedBox(height: 24.h),

                    // Task counts header
                    Text(
                      'Task Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 12.h),

                    // Task counts cards
                    BlocBuilder<TaskCubit, TaskState>(
                      builder: (context, state) {
                        int todo = 0, progress = 0, review = 0, done = 0;

                        if (state is TaskSuccess) {
                          for (final t in state.tasks) {
                            if (t.status == 'todo') todo++;
                            if (t.status == 'in_progress') progress++;
                            if (t.status == 'review') review++;
                            if (t.status == 'done') done++;
                          }
                        }

                        return Row(
                          children: [
                            Expanded(child: _buildCountCard('Todo', todo, AppColors.statusTodo)),
                            SizedBox(width: 8.w),
                            Expanded(child: _buildCountCard('Active', progress, AppColors.statusInProgress)),
                            SizedBox(width: 8.w),
                            Expanded(child: _buildCountCard('Review', review, AppColors.statusReview)),
                            SizedBox(width: 8.w),
                            Expanded(child: _buildCountCard('Done', done, AppColors.statusDone)),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 28.h),

                    // Task List header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tasks List',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        // Add task button
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: () {
                            // Will be implemented in Phase 5: Task screen navigation
                            _showPlaceholderSnackBar(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Tasks list view
                    BlocBuilder<TaskCubit, TaskState>(
                      builder: (context, state) {
                        if (state is TaskLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state is TaskEmpty) {
                          return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: const Text('No tasks found for this project.'),
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
                                    _showPlaceholderSnackBar(context);
                                  },
                                  title: Text(
                                    task.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Due: ${task.dueDate.year}-${task.dueDate.month}-${task.dueDate.day}',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(task.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      task.status.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(task.status),
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
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return AppColors.statusTodo;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'review':
        return AppColors.statusReview;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  void _showPlaceholderSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task actions and details will be fully activated in Phase 5!'),
      ),
    );
  }
}
