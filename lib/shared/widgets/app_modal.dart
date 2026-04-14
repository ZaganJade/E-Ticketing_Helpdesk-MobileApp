import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// App Modal - Redesigned to use shadcn_ui ShadDialog
/// A reusable modal component for showing dialogs and bottom sheets
class AppModal {
  /// Show confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(title),
        description: Text(message),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Batal'),
          ),
          isDestructive
              ? ShadButton.destructive(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmText ?? 'Konfirmasi'),
                )
              : ShadButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmText ?? 'Konfirmasi'),
                ),
        ],
      ),
    );
  }

  /// Show info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(title),
        description: Text(message),
        actions: [
          ShadButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: isDark ? ShadcnTheme.darkCard : ShadcnTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }

  /// Show custom dialog
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    return showShadDialog<T>(
      context: context,
      builder: (context) => ShadDialog(
        title: title != null ? Text(title) : null,
        child: child,
      ),
    );
  }
}

/// App Dialog - A simple dialog component
class AppDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: title != null ? Text(title!) : null,
      description: description != null ? Text(description!) : null,
      actions: actions ?? [],
      child: content,
    );
  }
}

/// App Alert Dialog - Alert style dialog
class AppAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      title: Text(title),
      description: Text(description),
      actions: [
        if (onCancel != null)
          ShadButton.outline(
            onPressed: onCancel,
            child: Text(cancelText ?? 'Batal'),
          ),
        if (isDestructive)
          ShadButton.destructive(
            onPressed: onConfirm,
            child: Text(confirmText ?? 'Konfirmasi'),
          )
        else
          ShadButton(
            onPressed: onConfirm,
            child: Text(confirmText ?? 'Konfirmasi'),
          ),
      ],
    );
  }
}
