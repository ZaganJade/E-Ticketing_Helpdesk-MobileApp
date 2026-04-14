import 'package:flutter/material.dart';
import '../../core/theme/shadcn_theme.dart';

/// Toast Type - Enum for different toast types
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// App Toast - Redesigned with shadcn_ui theme colors
/// A utility class for showing toast messages
class AppToast {
  /// Show custom toast
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final (backgroundColor, icon) = _getToastConfig(type);

    final overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
                    SizedBox(width: isTablet ? 12 : 8),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// Show success toast
  static void success(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.success);
  }

  /// Show error toast
  static void error(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.error);
  }

  /// Show warning toast
  static void warning(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.warning);
  }

  /// Show info toast
  static void info(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.info);
  }

  static (Color, IconData) _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return (ShadcnTheme.statusDone, Icons.check_circle_outline);
      case ToastType.error:
        return (ShadcnTheme.destructive, Icons.error_outline);
      case ToastType.warning:
        return (ShadcnTheme.statusInProgress, Icons.warning_amber_outlined);
      case ToastType.info:
        return (ShadcnTheme.accent, Icons.info_outline);
    }
  }
}

/// App Snackbar - A utility class for showing snackbars
class AppSnackbar {
  /// Show success snackbar
  static void success(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: ShadcnTheme.statusDone,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show error snackbar
  static void error(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: ShadcnTheme.destructive,
      icon: Icons.error_outline,
    );
  }

  /// Show warning snackbar
  static void warning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: ShadcnTheme.statusInProgress,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show info snackbar
  static void info(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: ShadcnTheme.accent,
      icon: Icons.info_outline,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(isTablet ? 16 : 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
