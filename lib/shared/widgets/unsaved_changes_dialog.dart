import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// Dialog for unsaved changes confirmation
class UnsavedChangesDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const UnsavedChangesDialog({
    super.key,
    this.title = 'Perubahan Belum Disimpan',
    this.message = 'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
    this.confirmText = 'Keluar',
    this.cancelText = 'Lanjutkan Edit',
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.title,
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTextStyles.body,
      ),
      actions: [
        AppButton(
          label: cancelText,
          variant: AppButtonVariant.ghost,
          onPressed: onCancel,
        ),
        AppButton(
          label: confirmText,
          variant: AppButtonVariant.destructive,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

/// Mixin for handling unsaved changes in forms
/// Usage: class _MyPageState extends State<MyPage> with UnsavedChangesHandler
mixin UnsavedChangesHandler<T extends StatefulWidget> on State<T> {
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markAsChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void markAsSaved() {
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  Future<bool> onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UnsavedChangesDialog(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    return result ?? false;
  }

  Widget buildUnsavedChangesWrapper({required Widget child}) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: child,
    );
  }
}

/// Widget wrapper untuk form dengan unsaved changes detection
class UnsavedChangesWrapper extends StatefulWidget {
  final Widget child;
  final bool hasChanges;
  final VoidCallback? onDiscard;

  const UnsavedChangesWrapper({
    super.key,
    required this.child,
    required this.hasChanges,
    this.onDiscard,
  });

  @override
  State<UnsavedChangesWrapper> createState() => _UnsavedChangesWrapperState();
}

class _UnsavedChangesWrapperState extends State<UnsavedChangesWrapper> {
  Future<bool> _onWillPop() async {
    if (!widget.hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UnsavedChangesDialog(
        onConfirm: () {
          widget.onDiscard?.call();
          Navigator.of(context).pop(true);
        },
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
