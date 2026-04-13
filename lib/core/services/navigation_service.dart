import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Enum untuk app state
enum AppState {
  foreground,
  background,
  terminated,
}

/// Service untuk mengelola navigasi global dari background/notification
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static AppState _currentState = AppState.foreground;

  static AppState get currentState => _currentState;

  /// Set current app state
  static void setAppState(AppState state) {
    _currentState = state;
  }

  /// Navigate to route (dari mana saja termasuk background)
  static void navigateTo(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push(route);
    }
  }

  /// Navigate and remove previous routes
  static void navigateAndReplace(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(route);
    }
  }

  /// Get GoRouter instance
  static GoRouter? get router {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return GoRouter.of(context);
    }
    return null;
  }
}
