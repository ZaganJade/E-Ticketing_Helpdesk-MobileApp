import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';

final _logger = Logger();

/// Login page with email/password form
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        authRepository: getIt<AuthRepository>()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    _logger.i('[LoginPage] State changed: isSuccess=${state.isSuccess}, user=${state.user?.id}');
    if (state.isSuccess && state.user != null) {
      // Update auth cubit and navigate
      _logger.i('[LoginPage] Login success, calling updateUser and navigating to /dashboard');
      context.read<AuthCubit>().updateUser(state.user!);
      context.go('/dashboard');
    } else if (state.isError && state.errorMessage != null) {
      // Show error toast
      AppToast.error(context, state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: _onLoginStateChanged,
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.confirmation_number,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Title
                  Text(
                    'Selamat Datang',
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Silakan login untuk melanjutkan',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Email Input
                  AppInput(
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    controller: _emailController,
                    type: AppInputType.email,
                    isRequired: true,
                    onChanged: (value) {
                      context.read<LoginCubit>().emailChanged(value);
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  if (state.email.isNotEmpty && !state.isEmailValid) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Format email tidak valid',
                      style: AppTextStyles.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  // Password Input
                  AppPasswordInput(
                    label: 'Password',
                    hint: 'Masukkan password Anda',
                    controller: _passwordController,
                    isRequired: true,
                    onChanged: (value) {
                      context.read<LoginCubit>().passwordChanged(value);
                    },
                    enabled: !state.isLoading,
                  ),
                  if (state.password.isNotEmpty && !state.isPasswordValid) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Password minimal 8 karakter',
                      style: AppTextStyles.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  // Forgot Password Link (optional)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        AppToast.info(context, 'Fitur ini akan segera hadir');
                      },
                      child: Text(
                        'Lupa password?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Login Button
                  AppButton(
                    label: 'Login',
                    size: AppButtonSize.large,
                    isLoading: state.isLoading,
                    isDisabled: !state.isFormValid || state.isLoading,
                    onPressed: () {
                      context.read<LoginCubit>().login();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: Text(
                          'Daftar',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
