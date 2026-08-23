import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/project_model.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';
import 'project_detail_screen.dart';
import 'settings_debug_drawer.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/screens/notification_inbox_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late String _orgId;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    _orgId = authState.user.orgId ?? '';
    _userRole = authState.user.role ?? '';
    final userId = authState.user.id;
    context.read<ProjectCubit>().loadProjects(_orgId);
    context.read<NotificationCubit>().loadNotifications(userId);
  }

  void _showProjectForm({ProjectModel? project}) {
    final nameController = TextEditingController(text: project?.name);
    final descController = TextEditingController(text: project?.description);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            top: 24.h,
            left: 24.w,
            right: 24.w,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  project == null ? 'Create New Project' : 'Edit Project',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'Enter project name',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Project name is required' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final projectCubit = context.read<ProjectCubit>();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      Navigator.pop(modalContext);
                      
                      final success = project == null
                          ? await projectCubit.createProject(
                                orgId: _orgId,
                                name: nameController.text,
                                description: descController.text,
                                userRole: _userRole,
                              )
                          : await projectCubit.editProject(
                                orgId: _orgId,
                                projectId: project.id,
                                name: nameController.text,
                                description: descController.text,
                                userRole: _userRole,
                              );
                      if (success && mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              project == null ? 'Project created successfully' : 'Project updated successfully',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(project == null ? 'Create' : 'Save Changes'),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.task_confirm_delete_title.tr()),
          content: Text('${LocaleKeys.project_confirm_delete_project_msg.tr()} (${project.name})'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(LocaleKeys.task_cancel_btn.tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await context.read<ProjectCubit>().deleteProject(
                      orgId: _orgId,
                      projectId: project.id,
                      userRole: _userRole,
                    );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(LocaleKeys.task_delete_btn.tr(), style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'org_admin';

    return Scaffold(
      drawer: SettingsDebugDrawer(orgId: _orgId),
      appBar: AppBar(
        title: Text(LocaleKeys.home_name.tr()),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationSuccess) {
                unreadCount = state.notifications.where((n) => !n.read).length;
              }
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (innerContext) => BlocProvider.value(
                        value: context.read<NotificationCubit>(),
                        child: const NotificationInboxScreen(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showProjectForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocConsumer<ProjectCubit, ProjectState>(
        listener: (context, state) {
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  LocaleKeys.empty_projects.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                ),
              ),
            );
          }

          if (state is ProjectSuccess) {
            final projects = state.projects;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isStale)
                  Container(
                    width: double.infinity,
                    color: AppColors.warning.withValues(alpha: 0.15),
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: AppColors.warning, size: 16),
                        SizedBox(width: 8.w),
                        Text(
                          LocaleKeys.offline_stale_data.tr(),
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Text(
                    'Projects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ProjectCubit>().loadProjects(_orgId),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(project: project),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          project.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      if (isAdmin) ...[
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showProjectForm(project: project);
                                            } else if (value == 'delete') {
                                              _confirmDelete(project);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit Project'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete Project', style: TextStyle(color: AppColors.error)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    project.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.list_alt,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            '${project.taskCount} Tasks',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: project.status == 'active'
                                              ? AppColors.success.withValues(alpha: 0.1)
                                              : AppColors.textSecondaryLight.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          project.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: project.status == 'active'
                                                ? AppColors.success
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          // Fallback UI or initial
          return const Center(child: Text('Please log in again'));
        },
      ),
    );
  }
}
