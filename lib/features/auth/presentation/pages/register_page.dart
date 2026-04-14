import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/register_cubit.dart';

/// Register page with nama, email, password form - Redesigned with shadcn_ui
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
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Berhasil!'),
          description: const Text('Akun berhasil dibuat!'),
        ),
      );
      context.read<AuthCubit>().updateUser(state.user!);
      context.go('/dashboard');
    } else if (state.isError && state.errorMessage != null) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Registrasi Gagal'),
          description: Text(state.errorMessage!),
        ),
      );
    }
  }

  Widget _buildPasswordStrengthIndicator(RegisterState state, bool isTablet) {
    if (state.password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.passwordStrength,
                  backgroundColor: isTablet
                      ? ShadcnTheme.darkBorder
                      : ShadcnTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(state.passwordStrengthColor),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              state.passwordStrengthLabel,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
      ),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: _onRegisterStateChanged,
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with gradient icon
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ShadcnTheme.accent.withValues(alpha: 0.2),
                              ShadcnTheme.accent.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: ShadcnTheme.accent,
                          size: isTablet ? 26 : 22,
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.w700,
                                color: ShadTheme.of(context).colorScheme.foreground,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Isi data di bawah untuk mendaftar',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 14,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  // Registration Card
                  ShadCard(
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nama Input
                        ShadInput(
                          placeholder: const Text('Nama Lengkap'),
                          controller: _namaController,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => context.read<RegisterCubit>().namaChanged(value),
                          enabled: !state.isLoading,
                          leading: Icon(
                            Icons.person_outline_rounded,
                            size: isTablet ? 20 : 18,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        if (state.nama.isNotEmpty && !state.isNamaValid) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Nama minimal 2 karakter',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: ShadcnTheme.statusOpen,
                            ),
                          ),
                        ],
                        SizedBox(height: isTablet ? 20 : 16),

                        // Email Input
                        ShadInput(
                          placeholder: const Text('Email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => context.read<RegisterCubit>().emailChanged(value),
                          enabled: !state.isLoading,
                          leading: Icon(
                            Icons.email_outlined,
                            size: isTablet ? 20 : 18,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        if (state.email.isNotEmpty && !state.isEmailValid) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Format email tidak valid',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: ShadcnTheme.statusOpen,
                            ),
                          ),
                        ],
                        SizedBox(height: isTablet ? 20 : 16),

                        // Password Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShadInput(
                              placeholder: const Text('Password (min. 8 karakter)'),
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => context.read<RegisterCubit>().passwordChanged(value),
                              enabled: !state.isLoading,
                              leading: Icon(
                                Icons.lock_outline_rounded,
                                size: isTablet ? 20 : 18,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                            _buildPasswordStrengthIndicator(state, isTablet),
                            if (state.password.isNotEmpty && !state.isPasswordValid) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Password minimal 8 karakter',
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  color: ShadcnTheme.statusOpen,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: isTablet ? 20 : 16),

                        // Confirm Password Input
                        ShadInput(
                          placeholder: const Text('Konfirmasi Password'),
                          controller: _confirmPasswordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) => context.read<RegisterCubit>().confirmPasswordChanged(value),
                          enabled: !state.isLoading,
                          leading: Icon(
                            Icons.lock_outline_rounded,
                            size: isTablet ? 20 : 18,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        if (state.confirmPassword.isNotEmpty &&
                            !state.isConfirmPasswordMatch) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Konfirmasi password tidak cocok',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: ShadcnTheme.statusOpen,
                            ),
                          ),
                        ],
                        SizedBox(height: isTablet ? 28 : 24),

                        // Register Button
                        ShadButton(
                          size: isTablet ? ShadButtonSize.lg : null,
                          backgroundColor: ShadcnTheme.accent,
                          onPressed: (!state.isFormValid || state.isLoading)
                              ? null
                              : () => context.read<RegisterCubit>().register(),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 24 : 20),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: ShadcnTheme.accent,
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
