import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';

final _logger = Logger();

/// Splash screen with animation and auto-login check
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration _minimumDisplayDuration = Duration(milliseconds: 1500);
  static const Duration _animationDuration = Duration(milliseconds: 800);

  DateTime? _startTime;
  bool _authCheckComplete = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward().then((_) {
      setState(() {
        _animationComplete = true;
      });
      _attemptNavigation();
    });
  }

  void _checkAuthStatus() {
    // Trigger auth check
    context.read<AuthCubit>().checkAuthStatus();
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    _logger.i('[SplashPage] Auth state changed: $state');
    if (state is Authenticated || state is Unauthenticated) {
      setState(() {
        _authCheckComplete = true;
      });
      _attemptNavigation();
    }
  }

  void _attemptNavigation() {
    if (!_authCheckComplete || !_animationComplete) return;

    // Calculate remaining time to meet minimum display duration
    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _minimumDisplayDuration - elapsed;

    if (remaining.isNegative) {
      _navigateBasedOnAuth();
    } else {
      Timer(remaining, _navigateBasedOnAuth);
    }
  }

  void _navigateBasedOnAuth() {
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    _logger.i('[SplashPage] Navigating based on auth state: $authState');

    if (authState is Authenticated) {
      // Navigate to Dashboard
      _logger.i('[SplashPage] Navigating to /dashboard');
      context.go('/dashboard');
    } else {
      // Navigate to Login
      _logger.i('[SplashPage] Navigating to /login');
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    size: 64,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // App Name
                Text(
                  'E-Ticketing',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Helpdesk',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Loading indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
