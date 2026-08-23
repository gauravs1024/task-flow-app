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
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

class TaskFlowApp extends StatelessWidget {
  final SharedPreferences prefs;

  const TaskFlowApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(prefs),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
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
                        return InitialPlaceholder(user: authState.user);
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

class InitialPlaceholder extends StatelessWidget {
  final dynamic user;
  const InitialPlaceholder({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_medium),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            SizedBox(height: 16.h),
            Text(
              'Hello, ${user.name}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              'Email: ${user.email}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 4.h),
            Text(
              'Role: ${user.role} | Org: ${user.orgId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                // Test token expiry refresh mechanism
                context.read<AuthCubit>().simulateTokenExpiry();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Simulated token expiry triggered! Checking console / console refresh.'),
                  ),
                );
              },
              child: const Text('Simulate Token Expiry (Refresh)'),
            ),
          ],
        ),
      ),
    );
  }
}
