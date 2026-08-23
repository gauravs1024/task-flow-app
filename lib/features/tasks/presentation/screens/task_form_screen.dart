import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../cubit/task_cubit.dart';

class TaskFormScreen extends StatefulWidget {
  final String projectId;
  final TaskModel? task; // Null for creation

  const TaskFormScreen({super.key, required this.projectId, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _status = 'todo';
  String _priority = 'medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _assigneeId;

  List<Map<String, dynamic>> _orgMembers = [];
  bool _isLoadingMembers = true;
  late String _userOrgId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    _userOrgId = authState.user.orgId ?? '';

    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _status = t.status;
      _priority = t.priority;
      _dueDate = t.dueDate;
      _assigneeId = t.assigneeId;
    }

    _loadMembers();
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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final taskCubit = context.read<TaskCubit>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final task = TaskModel(
        id: widget.task?.id ?? '',
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descController.text,
        status: _status,
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );

      final success = widget.task == null
          ? await taskCubit.createTask(task, _userOrgId)
          : await taskCubit.updateTask(task, _userOrgId);

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(widget.task == null ? 'Task created successfully' : 'Task updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to save task. Ensure input is valid.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.task == null ? 'Create Task' : 'Edit Task';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: SafeArea(
        child: _isLoadingMembers
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Task Title',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter task title',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Title is required' : null,
                      ),
                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter task description',
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Status & Priority
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                                ),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _status,
                                  items: const [
                                    DropdownMenuItem(value: 'todo', child: Text('Todo')),
                                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                    DropdownMenuItem(value: 'review', child: Text('Review')),
                                    DropdownMenuItem(value: 'done', child: Text('Done')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _status = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                                ),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _priority,
                                  items: const [
                                    DropdownMenuItem(value: 'low', child: Text('Low')),
                                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                    DropdownMenuItem(value: 'high', child: Text('High')),
                                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _priority = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Due Date Selection
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: _selectDueDate,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Assignee Selector
                      Text(
                        'Assignee',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String?>(
                        initialValue: _assigneeId,
                        hint: const Text('Unassigned'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Unassigned'),
                          ),
                          ..._orgMembers.map((member) {
                            final name = member['name'] as String;
                            final id = member['id'] as String;
                            return DropdownMenuItem<String?>(
                              value: id,
                              child: Text(name),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _assigneeId = val);
                        },
                      ),
                      SizedBox(height: 40.h),

                      // Save Button
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save Task'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
