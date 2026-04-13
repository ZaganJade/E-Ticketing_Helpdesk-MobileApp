import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/register_cubit.dart';

/// Register page with nama, email, password form
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
        authRepository: getIt<AuthRepository>()),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterStateChanged(BuildContext context, RegisterState state) {
    if (state.isSuccess && state.user != null) {
      // Show success toast
      AppToast.success(context, 'Akun berhasil dibuat!');
      // Update auth cubit and navigate
      context.read<AuthCubit>().updateUser(state.user!);
      context.go('/dashboard');
    } else if (state.isError && state.errorMessage != null) {
      // Show error toast
      AppToast.error(context, state.errorMessage!);
    }
  }

  Widget _buildPasswordStrengthIndicator(RegisterState state) {
    if (state.password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: state.passwordStrength,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(state.passwordStrengthColor),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              state.passwordStrengthLabel,
              style: AppTextStyles.caption.copyWith(
                color: Color(state.passwordStrengthColor),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: _onRegisterStateChanged,
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Buat Akun Baru',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Isi data di bawah untuk mendaftar',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Nama Input
                  AppInput(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap Anda',
                    controller: _namaController,
                    type: AppInputType.text,
                    isRequired: true,
                    onChanged: (value) {
                      context.read<RegisterCubit>().namaChanged(value);
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !state.isLoading,
                  ),
                  if (state.nama.isNotEmpty && !state.isNamaValid) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nama minimal 2 karakter',
                      style: AppTextStyles.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  // Email Input
                  AppInput(
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    controller: _emailController,
                    type: AppInputType.email,
                    isRequired: true,
                    onChanged: (value) {
                      context.read<RegisterCubit>().emailChanged(value);
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !state.isLoading,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppPasswordInput(
                        label: 'Password',
                        hint: 'Minimal 8 karakter',
                        controller: _passwordController,
                        isRequired: true,
                        onChanged: (value) {
                          context.read<RegisterCubit>().passwordChanged(value);
                        },
                        enabled: !state.isLoading,
                      ),
                      _buildPasswordStrengthIndicator(state),
                      if (state.password.isNotEmpty && !state.isPasswordValid) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Password minimal 8 karakter',
                          style: AppTextStyles.error,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Confirm Password Input
                  AppPasswordInput(
                    label: 'Konfirmasi Password',
                    hint: 'Masukkan ulang password',
                    controller: _confirmPasswordController,
                    isRequired: true,
                    onChanged: (value) {
                      context.read<RegisterCubit>().confirmPasswordChanged(value);
                    },
                    enabled: !state.isLoading,
                  ),
                  if (state.confirmPassword.isNotEmpty &&
                      !state.isConfirmPasswordMatch) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Konfirmasi password tidak cocok',
                      style: AppTextStyles.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  // Register Button
                  AppButton(
                    label: 'Daftar',
                    size: AppButtonSize.large,
                    isLoading: state.isLoading,
                    isDisabled: !state.isFormValid || state.isLoading,
                    onPressed: () {
                      context.read<RegisterCubit>().register();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Login',
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
