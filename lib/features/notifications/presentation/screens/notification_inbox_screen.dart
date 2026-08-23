import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import '../../../../core/data/mock_data_source.dart';
import '../cubit/notification_cubit.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  late String _currentUserId;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    _currentUserId = authState.user.id;
    _userRole = authState.user.role ?? '';
    context.read<NotificationCubit>().loadNotifications(_currentUserId);
  }

  void _handleNotificationTap(String notifId, String taskId, bool read) async {
    final notificationCubit = context.read<NotificationCubit>();
    final taskRepository = context.read<TaskRepository>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 1. Mark as read
    if (!read) {
      await notificationCubit.markAsRead(notifId, _currentUserId);
    }

    // 2. Fetch and navigate to task

    // Let's read from MockDataSource directly:
    final matchTaskMap = MockDataSource().tasks.firstWhere(
          (t) => t['id'] == taskId,
          orElse: () => {},
        );

    if (matchTaskMap.isNotEmpty) {
      final task = TaskModel.fromJson(matchTaskMap);
      navigator.push(
        MaterialPageRoute(
          builder: (itemContext) => MultiBlocProvider(
            providers: [
              BlocProvider<TaskCubit>(
                create: (context) => TaskCubit(taskRepository)..loadTasks(task.projectId),
              ),
            ],
            child: TaskDetailScreen(task: task, userRole: _userRole),
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open task. It may have been deleted.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const NotificationListSkeleton();
          }
          if (state is NotificationError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: AppColors.error)),
            );
          }
          if (state is NotificationSuccess) {
            final list = state.notifications;
            if (list.isEmpty) {
              return const Center(child: Text('Your inbox is empty'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(_currentUserId),
              child: ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final notif = list[index];
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
                  final textPrimaryCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
                  final textSecondaryCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

                  return Card(
                    elevation: 0,
                    color: notif.read
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: notif.read
                            ? borderCol.withValues(alpha: 0.5)
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => _handleNotificationTap(notif.id, notif.taskId, notif.read),
                      title: Text(
                        notif.message,
                        style: TextStyle(
                          fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                          color: notif.read ? textSecondaryCol : textPrimaryCol,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '${notif.createdAt.year}-${notif.createdAt.month.toString().padLeft(2, '0')}-${notif.createdAt.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textSecondaryCol,
                          ),
                        ),
                      ),
                      trailing: notif.read
                          ? null
                          : Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
