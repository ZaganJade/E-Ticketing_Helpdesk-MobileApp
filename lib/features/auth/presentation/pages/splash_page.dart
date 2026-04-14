import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../cubit/auth_cubit.dart';

final _logger = Logger();

/// Splash screen with animation and auto-login check - Redesigned with shadcn_ui
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
      _logger.i('[SplashPage] Navigating to /dashboard');
      context.go('/dashboard');
    } else {
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: ShadTheme.of(context).colorScheme.background,
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
                // App Logo with gradient
                Container(
                  width: isTablet ? 140 : 120,
                  height: isTablet ? 140 : 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ShadcnTheme.accent.withValues(alpha: 0.8),
                        ShadcnTheme.accent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: ShadcnTheme.accent.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.confirmation_number_rounded,
                    size: isTablet ? 72 : 64,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),
                // App Name
                Text(
                  'E-Ticketing',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : 28,
                    fontWeight: FontWeight.w800,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Helpdesk',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: isTablet ? 48 : 40),
                // Loading indicator with accent color
                SizedBox(
                  width: isTablet ? 28 : 24,
                  height: isTablet ? 28 : 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
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
