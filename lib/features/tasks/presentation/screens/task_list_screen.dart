import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String projectId;
  final String userRole;
  final String orgId;

  const TaskListScreen({
    super.key,
    required this.projectId,
    required this.userRole,
    required this.orgId,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Filter states
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  String? _selectedAssigneeId;
  DateTimeRange? _selectedDateRange;

  List<Map<String, dynamic>> _orgMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadOrgMembers();
    context.read<TaskCubit>().loadTasks(widget.projectId);
  }

  void _loadOrgMembers() async {
    try {
      final repository = context.read<TaskRepository>();
      final members = await repository.getOrganizationMembers(widget.orgId);
      if (mounted) {
        setState(() {
          _orgMembers = members;
          _isLoadingMembers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }
      if (_selectedAssigneeId != null && task.assigneeId != _selectedAssigneeId) {
        return false;
      }
      if (_selectedDateRange != null) {
        final due = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        if (due.isBefore(start) || due.isAfter(end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedAssigneeId = null;
      _selectedDateRange = null;
    });
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );
    if (range != null) {
      setState(() {
        _selectedDateRange = range;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == 'org_admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.project_tasks_list_header.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: _resetFilters,
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => BlocProvider.value(
                      value: context.read<TaskCubit>(),
                      child: TaskFormScreen(projectId: widget.projectId),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // Filters Panel Header
          _buildFilterPanel(),
          
          // Tasks List Content
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const TaskListSkeleton();
                }
                if (state is TaskError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }
                if (state is TaskSuccess) {
                  final filteredTasks = _getFilteredTasks(state.tasks);
                  
                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Text(
                          LocaleKeys.task_no_matching_filters.tr(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<TaskCubit>().loadTasks(widget.projectId),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (innerContext) => BlocProvider.value(
                                    value: context.read<TaskCubit>(),
                                    child: TaskDetailScreen(
                                      task: task,
                                      userRole: widget.userRole,
                                    ),
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              task.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'Due: ${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
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
                                SizedBox(height: 4.h),
                                Text(
                                  task.priority.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: task.priority.color,
                                  ),
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<TaskStatus?>(
                  decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.zero),
                  initialValue: _selectedStatus,
                  items: [
                    const DropdownMenuItem<TaskStatus?>(value: null, child: Text('All')),
                    ...TaskStatus.values.map((s) => DropdownMenuItem<TaskStatus?>(
                      value: s,
                      child: Text(s.label),
                    )),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedStatus = val);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              // Priority Filter
              Expanded(
                child: DropdownButtonFormField<TaskPriority?>(
                  decoration: const InputDecoration(labelText: 'Priority', contentPadding: EdgeInsets.zero),
                  initialValue: _selectedPriority,
                  items: [
                    const DropdownMenuItem<TaskPriority?>(value: null, child: Text('All')),
                    ...TaskPriority.values.map((p) => DropdownMenuItem<TaskPriority?>(
                      value: p,
                      child: Text(p.label),
                    )),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedPriority = val);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Assignee Filter
              Expanded(
                child: DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(labelText: 'Assignee', contentPadding: EdgeInsets.zero),
                  initialValue: _selectedAssigneeId,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All')),
                    ..._orgMembers.map((m) {
                      return DropdownMenuItem<String?>(
                        value: m['id'] as String,
                        child: Text(m['name'] as String? ?? ''),
                      );
                    }),
                  ],
                  onChanged: _isLoadingMembers
                      ? null
                      : (val) {
                          setState(() => _selectedAssigneeId = val);
                        },
                ),
              ),
              SizedBox(width: 12.w),
              // Date Range Picker
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date Range',
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _selectedDateRange == null
                          ? 'Select Range'
                          : '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

