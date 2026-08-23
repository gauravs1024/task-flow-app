import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/data/mock_data_source.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/project_cubit.dart';

class SettingsDebugDrawer extends StatefulWidget {
  final String orgId;

  const SettingsDebugDrawer({super.key, required this.orgId});

  @override
  State<SettingsDebugDrawer> createState() => _SettingsDebugDrawerState();
}

class _SettingsDebugDrawerState extends State<SettingsDebugDrawer> {
  final MockDataSource _dataSource = MockDataSource();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    if (authState is! AuthAuthenticated) {
      return const SizedBox();
    }

    final user = authState.user;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            accountName: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'ROLE: ${user.role?.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawer Body Scrollable
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Theme Toggle
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                ),
                const Divider(),

                // Simulation Category
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    'DEVELOPER TESTING PANEL',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                // Offline Mode Toggle
                ListTile(
                  leading: Icon(
                    _dataSource.isOffline ? Icons.cloud_off : Icons.cloud_queue,
                    color: _dataSource.isOffline
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  title: const Text('Simulate Offline Mode'),
                  subtitle: const Text('Serve cached local data fallback'),
                  trailing: Switch(
                    value: _dataSource.isOffline,
                    activeThumbColor: AppColors.warning,
                    onChanged: (val) {
                      setState(() {
                        _dataSource.isOffline = val;
                      });
                      context.read<ProjectCubit>().loadProjects(widget.orgId);
                    },
                  ),
                ),

                // Error Injections
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Simulate 404 (Not Found)'),
                  trailing: Switch(
                    value: _dataSource.injectNotFoundError,
                    onChanged: (val) {
                      setState(() {
                        _dataSource.injectNotFoundError = val;
                        if (val) {
                          _dataSource.injectTimeoutError = false;
                          _dataSource.injectValidationError = false;
                        }
                      });
                    },
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Simulate Timeout (504)'),
                  trailing: Switch(
                    value: _dataSource.injectTimeoutError,
                    onChanged: (val) {
                      setState(() {
                        _dataSource.injectTimeoutError = val;
                        if (val) {
                          _dataSource.injectNotFoundError = false;
                          _dataSource.injectValidationError = false;
                        }
                      });
                    },
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.gpp_bad_outlined),
                  title: const Text('Simulate Validation Error'),
                  trailing: Switch(
                    value: _dataSource.injectValidationError,
                    onChanged: (val) {
                      setState(() {
                        _dataSource.injectValidationError = val;
                        if (val) {
                          _dataSource.injectNotFoundError = false;
                          _dataSource.injectTimeoutError = false;
                        }
                      });
                    },
                  ),
                ),

                const Divider(),

                // Expiry simulation triggers
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                      foregroundColor: AppColors.accent,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    icon: const Icon(Icons.lock_clock),
                    label: const Text('Simulate Token Expiry'),
                    onPressed: () {
                      context.read<AuthCubit>().simulateTokenExpiry();
                      Navigator.pop(context); // Close drawer
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Access Token Expired! Triggering silent refresh...',
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Mock Data'),
                    onPressed: () {
                      _dataSource.resetData();
                      context.read<ProjectCubit>().loadProjects(widget.orgId);
                      Navigator.pop(context); // Close drawer
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'In-memory mock data reset to initial values',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Drawer Footer Logout
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
