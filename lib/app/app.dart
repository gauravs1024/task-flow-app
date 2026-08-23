import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/projects/data/repositories/project_repository.dart';
import '../features/projects/presentation/cubit/project_cubit.dart';
import '../features/projects/presentation/screens/project_list_screen.dart';
import '../features/tasks/data/repositories/task_repository.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

class TaskFlowApp extends StatelessWidget {
  final SharedPreferences prefs;

  const TaskFlowApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<ProjectRepository>(
          create: (context) => ProjectRepositoryImpl(),
        ),
        RepositoryProvider<TaskRepository>(
          create: (context) => TaskRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(prefs),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<ProjectCubit>(
            create: (context) => ProjectCubit(context.read<ProjectRepository>()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  title: 'TaskFlow',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthAuthenticated) {
                        return const ProjectListScreen();
                      } else if (authState is AuthUnauthenticated) {
                        return const LoginScreen();
                      } else {
                        return const SplashScreen();
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
