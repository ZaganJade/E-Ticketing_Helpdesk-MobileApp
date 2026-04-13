import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_button.dart';

class AppModal {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    AppButtonVariant confirmVariant = AppButtonVariant.destructive,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          AppButton(
            label: cancelText,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: confirmText,
            variant: confirmVariant,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          AppButton(
            label: buttonText,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    double? maxHeight,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => Container(
        constraints: maxHeight != null
            ? BoxConstraints(maxHeight: maxHeight)
            : null,
        padding: const EdgeInsets.all(AppSpacing.default_),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.default_),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  static Future<void> showLoading({
    required BuildContext context,
    String? message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.cardRadius,
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppSpacing.default_),
              Text(
                message ?? 'Memuat...',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title!, style: AppTextStyles.subtitle),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.default_),
        ],
        Flexible(child: child),
      ],
    );
  }
}
