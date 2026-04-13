import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class AppToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {},
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static void success(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, iconColor, icon) = _getToastConfig();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.default_),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.default_,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppBorderRadius.buttonRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        color: iconColor,
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
    );
  }

  (Color, Color, IconData) _getToastConfig() {
    switch (type) {
      case ToastType.success:
        return (
          AppColors.statusSelesai.withOpacity(0.1),
          AppColors.statusSelesai,
          Icons.check_circle,
        );
      case ToastType.error:
        return (
          AppColors.error.withOpacity(0.1),
          AppColors.error,
          Icons.error,
        );
      case ToastType.warning:
        return (
          AppColors.statusTerbuka.withOpacity(0.1),
          AppColors.statusTerbuka,
          Icons.warning,
        );
      case ToastType.info:
        return (
          AppColors.statusDiproses.withOpacity(0.1),
          AppColors.statusDiproses,
          Icons.info,
        );
    }
  }
}

class AppSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (backgroundColor, foregroundColor, icon) = _getSnackbarConfig(type, isDark);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: foregroundColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.buttonRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.default_),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: foregroundColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.info);
  }

  static (Color, Color, IconData) _getSnackbarConfig(ToastType type, bool isDark) {
    switch (type) {
      case ToastType.success:
        return (
          isDark ? AppColors.statusSelesai.withOpacity(0.2) : AppColors.statusSelesai.withOpacity(0.1),
          AppColors.statusSelesai,
          Icons.check_circle,
        );
      case ToastType.error:
        return (
          isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
          AppColors.error,
          Icons.error,
        );
      case ToastType.warning:
        return (
          isDark ? AppColors.statusTerbuka.withOpacity(0.2) : AppColors.statusTerbuka.withOpacity(0.1),
          AppColors.statusTerbuka,
          Icons.warning,
        );
      case ToastType.info:
        return (
          isDark ? AppColors.statusDiproses.withOpacity(0.2) : AppColors.statusDiproses.withOpacity(0.1),
          AppColors.statusDiproses,
          Icons.info,
        );
    }
  }
}
