import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_modal.dart';
import '../cubit/auth_cubit.dart';

/// Widget that handles session timeout and token refresh
/// Should be placed near the root of the app (above MaterialApp)
class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;

  /// Timeout duration after which session is considered inactive
  /// Default is 30 minutes
  final Duration inactivityTimeout;

  /// Interval to check for token refresh
  /// Default is every 5 minutes
  final Duration tokenRefreshInterval;

  const SessionTimeoutHandler({
    super.key,
    required this.child,
    this.inactivityTimeout = const Duration(minutes: 30),
    this.tokenRefreshInterval = const Duration(minutes: 5),
  });

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler>
    with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  Timer? _refreshTimer;
  DateTime? _lastActivity;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimers();
    _lastActivity = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground, check if session expired
        _checkInactivityTimeout();
        _startTimers();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App went to background, stop timers
        _stopTimers();
        break;
      case AppLifecycleState.detached:
        _stopTimers();
        break;
    }
  }

  void _startTimers() {
    // Inactivity timer - check every minute
    _inactivityTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkInactivityTimeout();
    });

    // Token refresh timer
    _refreshTimer = Timer.periodic(widget.tokenRefreshInterval, (_) {
      _refreshToken();
    });
  }

  void _stopTimers() {
    _inactivityTimer?.cancel();
    _refreshTimer?.cancel();
  }

  void _checkInactivityTimeout() {
    if (_lastActivity == null) return;

    final inactiveDuration = DateTime.now().difference(_lastActivity!);
    if (inactiveDuration > widget.inactivityTimeout) {
      _showSessionExpiredDialog();
    }
  }

  void _refreshToken() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      await context.read<AuthCubit>().refreshSession();
    }
  }

  void _showSessionExpiredDialog() async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    _stopTimers();

    // Perform logout
    await context.read<AuthCubit>().logout();

    if (mounted) {
      await AppModal.showInfo(
        context: context,
        title: 'Sesi Berakhir',
        message:
            'Sesi Anda telah berakhir karena tidak aktif selama 30 menit. Silakan login kembali.',
        buttonText: 'OK',
      );

      // Navigate to login page
      if (mounted) {
        context.go('/login');
      }
    }

    _isDialogShowing = false;
  }

  void _onUserActivity() {
    _lastActivity = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      child: widget.child,
    );
  }
}
