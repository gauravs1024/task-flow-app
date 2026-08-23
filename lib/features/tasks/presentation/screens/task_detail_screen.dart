import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../cubit/comment_cubit.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String userRole; // From parent

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.userRole,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;
  late String _userOrgId;
  late String _currentUserId;
  bool _isLoadingMembers = true;
  List<Map<String, dynamic>> _orgMembers = [];
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;

    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    _userOrgId = authState.user.orgId ?? '';
    _currentUserId = authState.user.id;

    _loadMembers();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final repo = context.read<TaskRepository>();
      final members = await repo.getOrganizationMembers(_userOrgId);
      setState(() {
        _orgMembers = members;
        _isLoadingMembers = false;
      });
    } catch (_) {
      setState(() => _isLoadingMembers = false);
    }
  }

  Map<String, dynamic>? _getAssigneeDetails() {
    if (_task.assigneeId == null) return null;
    return _orgMembers
            .firstWhere((m) => m['id'] == _task.assigneeId, orElse: () => {})
            .isEmpty
        ? null
        : _orgMembers.firstWhere((m) => m['id'] == _task.assigneeId);
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    final updatedTask = _task.copyWith(status: newStatus);
    final success = await context.read<TaskCubit>().updateTask(
      updatedTask,
      _userOrgId,
    );
    if (success) {
      setState(() {
        _task = updatedTask;
      });
    }
  }

  Future<void> _updatePriority(TaskPriority newPriority) async {
    final updatedTask = _task.copyWith(priority: newPriority);
    final success = await context.read<TaskCubit>().updateTask(
      updatedTask,
      _userOrgId,
    );
    if (success) {
      setState(() {
        _task = updatedTask;
      });
    }
  }

  Future<void> _updateAssignee(String? newAssigneeId) async {
    final updatedTask = _task.copyWith(assigneeId: newAssigneeId);
    final success = await context.read<TaskCubit>().updateTask(
      updatedTask,
      _userOrgId,
    );
    if (success) {
      setState(() {
        _task = updatedTask;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.task_confirm_delete_title.tr()),
          content: Text('${LocaleKeys.task_confirm_delete_task_msg.tr()} ("${_task.title}")'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(LocaleKeys.task_cancel_btn.tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final taskCubit = context.read<TaskCubit>();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final success = await taskCubit.deleteTask(
                  _task.id,
                  _task.projectId,
                );
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(
                LocaleKeys.task_delete_btn.tr(),
                style: const TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignee = _getAssigneeDetails();

    return BlocProvider<CommentCubit>(
      create: (context) =>
          CommentCubit(context.read<TaskRepository>())..loadComments(_task.id),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final taskCubit = context.read<TaskCubit>();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (itemContext) => BlocProvider.value(
                          value: taskCubit,
                          child: TaskFormScreen(
                            projectId: _task.projectId,
                            task: _task,
                          ),
                        ),
                      ),
                    );
                    // Refresh screen state locally by checking current state
                    if (taskCubit.state is TaskSuccess) {
                      final tasks = (taskCubit.state as TaskSuccess).tasks;
                      final refreshedTask = tasks.firstWhere(
                        (t) => t.id == _task.id,
                        orElse: () => _task,
                      );
                      setState(() {
                        _task = refreshedTask;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<CommentCubit>().loadComments(_task.id);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title & Description
                            Text(
                              _task.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _task.description.isNotEmpty
                                  ? _task.description
                                  : 'No description provided.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
                            ),
                            const Divider(height: 32),

                            // Details Panel
                            _buildInfoRow(
                              'Due Date',
                              '${_task.dueDate.year}-${_task.dueDate.month.toString().padLeft(2, '0')}-${_task.dueDate.day.toString().padLeft(2, '0')}',
                            ),
                            SizedBox(height: 16.h),

                            // Status Dropdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 14.sp),
                                ),
                                DropdownButton<TaskStatus>(
                                  value: _task.status,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) _updateStatus(val);
                                  },
                                  items: TaskStatus.values
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.label),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Priority Dropdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Priority',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 14.sp),
                                ),
                                DropdownButton<TaskPriority>(
                                  value: _task.priority,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) _updatePriority(val);
                                  },
                                  items: TaskPriority.values
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(p.label),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Assignee Dropdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Assignee',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 14.sp),
                                ),
                                _isLoadingMembers
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : DropdownButton<String?>(
                                        value: _task.assigneeId,
                                        underline: const SizedBox(),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.primary,
                                        ),
                                        onChanged: (val) {
                                          _updateAssignee(val);
                                        },
                                        items: [
                                          const DropdownMenuItem<String?>(
                                            value: null,
                                            child: Text('Unassigned'),
                                          ),
                                          ..._orgMembers.map((m) {
                                            return DropdownMenuItem<String?>(
                                              value: m['id'] as String,
                                              child: Text(m['name'] as String),
                                            );
                                          }),
                                        ],
                                      ),
                              ],
                            ),

                            // Assignee avatar card
                            if (assignee != null) ...[
                              SizedBox(height: 12.h),
                              Card(
                                elevation: 0,
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      assignee['avatar_url'] as String? ?? '',
                                    ),
                                  ),
                                  title: Text(
                                    assignee['name'] as String? ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    assignee['email'] as String? ?? '',
                                  ),
                                ),
                              ),
                            ],

                            const Divider(height: 48),

                            // Comments Section
                            Text(
                              LocaleKeys.task_comments_header.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 16.h),

                            BlocBuilder<CommentCubit, CommentState>(
                              builder: (context, state) {
                                if (state is CommentLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (state is CommentError) {
                                  return Text(
                                    state.message,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
                                  );
                                }
                                if (state is CommentSuccess) {
                                  final comments = state.comments;
                                  if (comments.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.h,
                                      ),
                                      child: const Text(
                                        'No comments yet. Start the conversation!',
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: comments.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12.h),
                                    itemBuilder: (context, index) {
                                      final comment = comments[index];
                                      // Resolve author details
                                      final author = _orgMembers.firstWhere(
                                        (m) => m['id'] == comment.authorId,
                                        orElse: () => {},
                                      );
                                      final authorName =
                                          author['name'] as String? ??
                                          'Anonymous';
                                      final authorAvatar =
                                          author['avatar_url'] as String? ?? '';

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 18.r,
                                            backgroundImage:
                                                authorAvatar.isNotEmpty
                                                ? NetworkImage(authorAvatar)
                                                : null,
                                            child: authorAvatar.isEmpty
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(12.r),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? AppColors.cardBgDark
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    authorName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    comment.body,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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

                    // Add comment input box
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _commentController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.task_add_comment_hint.tr(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primary,
                            ),
                            onPressed: () async {
                              if (_commentController.text.trim().isNotEmpty) {
                                final text = _commentController.text;
                                _commentController.clear();
                                FocusScope.of(context).unfocus();
                                await context.read<CommentCubit>().addComment(
                                  _task.id,
                                  _currentUserId,
                                  text,
                                );
                              }
                            },
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
