import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:task_flow_app/features/auth/presentation/screens/login_screen.dart';
import 'package:task_flow_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_flow_app/features/auth/data/repositories/auth_repository.dart';
import 'package:task_flow_app/features/auth/data/models/user_model.dart';
import 'package:task_flow_app/features/auth/data/models/auth_token_model.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    return const UserModel(
      id: 'user_001',
      name: 'Ava Thompson',
      email: 'ava.admin@nimbusdigital.test',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      orgId: 'org_a1b2c3',
      role: 'org_admin',
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {}

  @override
  Future<AuthTokenModel?> getStoredTokens() async => null;

  @override
  Future<UserModel?> getStoredUser() async => null;

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> checkSession() async => null;

  @override
  Future<void> forceTokenExpiry() async {}

  @override
  Future<List<Map<String, dynamic>>> getTestCredentials() async {
    return [
      {
        'email': 'ava.admin@nimbusdigital.test',
        'password': 'Password123!',
        'org_id': 'org_a1b2c3',
        'role': 'org_admin'
      }
    ];
  }
}

class MockAssetLoader extends AssetLoader {
  const MockAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "home_name": "TaskFlow",
      "login": "Login",
      "email": "Email",
      "password": "Password",
      "validation_email": "Invalid email",
      "validation_password": "Invalid password",
    };
  }
}

void main() {
  testWidgets('LoginScreen renders email, password and action buttons', (WidgetTester tester) async {
    // 1. Initialize SharedPreferences and EasyLocalization in the test environment
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    final mockRepository = MockAuthRepository();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const MockAssetLoader(),
        child: Builder(
          builder: (context) {
            return RepositoryProvider<AuthRepository>.value(
              value: mockRepository,
              child: BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(mockRepository),
                child: ScreenUtilInit(
                  designSize: const Size(375, 812),
                  builder: (context, child) {
                    return MaterialApp(
                      locale: context.locale,
                      supportedLocales: context.supportedLocales,
                      localizationsDelegates: context.localizationDelegates,
                      home: const Scaffold(
                        body: LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        ),
      ),
    );

    // Let assets load and localizations initialize
    await tester.pumpAndSettle();

    // Verify fields exist
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email + Password input fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Submit button
  });
}
