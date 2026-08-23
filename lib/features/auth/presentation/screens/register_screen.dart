import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../generated/locale_keys.g.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _didTriggerRegister = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _didTriggerRegister = true;
      });
      context.read<AuthCubit>().register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.register_title.tr()),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
              setState(() {
                _didTriggerRegister = false;
              });
            } else if (state is AuthUnauthenticated && _didTriggerRegister) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful! Please log in.'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      LocaleKeys.register_title.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.register_subtitle.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 40.h),

                    // Name Field
                    Text(
                      'Full Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Email Field
                    Text(
                      LocaleKeys.email_label.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.email_hint.tr(),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Password Field
                    Text(
                      LocaleKeys.password_label.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.password_hint.tr(),
                        prefixIcon: const Icon(Icons.lock_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40.h),

                    // Register Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(LocaleKeys.register_btn.tr()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
