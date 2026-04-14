import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';

final _logger = Logger();

/// Login page with email/password form - Redesigned with shadcn_ui
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
      _logger.i('[LoginPage] Login success, calling updateUser and navigating to /dashboard');
      context.read<AuthCubit>().updateUser(state.user!);
      context.go('/dashboard');
    } else if (state.isError && state.errorMessage != null) {
      _showErrorToast(context, state.errorMessage!);
    }
  }

  void _showErrorToast(BuildContext context, String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Login Gagal'),
        description: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: _onLoginStateChanged,
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isTablet ? 48 : 32),
                  // Logo with gradient
                  Center(
                    child: Container(
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 100 : 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShadcnTheme.accent.withValues(alpha: 0.8),
                            ShadcnTheme.accent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: ShadcnTheme.accent.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.confirmation_number_rounded,
                        size: isTablet ? 48 : 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  // Title
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: ShadTheme.of(context).colorScheme.foreground,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan login untuk melanjutkan',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w400,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 40 : 32),

                  // Login Card
                  ShadCard(
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Input
                        _buildEmailInput(context, state, isTablet),
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
                        _buildPasswordInput(context, state, isTablet),
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
                        const SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: ShadButton.ghost(
                            size: ShadButtonSize.sm,
                            onPressed: () {
                              ShadToaster.of(context).show(
                                ShadToast(
                                  title: const Text('Info'),
                                  description: const Text('Fitur ini akan segera hadir'),
                                ),
                              );
                            },
                            child: Text(
                              'Lupa password?',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: ShadcnTheme.accent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Login Button
                        ShadButton(
                          size: isTablet ? ShadButtonSize.lg : null,
                          backgroundColor: ShadcnTheme.accent,
                          onPressed: (!state.isFormValid || state.isLoading)
                              ? null
                              : () => context.read<LoginCubit>().login(),
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
                                  'Login',
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

                  SizedBox(height: isTablet ? 32 : 24),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () => context.push('/register'),
                        child: Text(
                          'Daftar',
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

  Widget _buildEmailInput(BuildContext context, LoginState state, bool isTablet) {
    return ShadInput(
      placeholder: const Text('Masukkan email Anda'),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) => context.read<LoginCubit>().emailChanged(value),
      enabled: !state.isLoading,
      leading: Icon(
        Icons.email_outlined,
        size: isTablet ? 20 : 18,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      ),
    );
  }

  Widget _buildPasswordInput(BuildContext context, LoginState state, bool isTablet) {
    return ShadInput(
      placeholder: const Text('Masukkan password Anda'),
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (value) => context.read<LoginCubit>().passwordChanged(value),
      enabled: !state.isLoading,
      leading: Icon(
        Icons.lock_outline_rounded,
        size: isTablet ? 20 : 18,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      ),
    );
  }
}
