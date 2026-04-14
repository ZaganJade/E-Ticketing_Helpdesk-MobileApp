import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// Unsaved Changes Dialog - Redesigned with shadcn_ui
/// A dialog for confirming unsaved changes following AGENTS.md guidelines
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
    return ShadDialog.alert(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ShadcnTheme.statusInProgress.withValues(alpha: 0.2),
                  ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: ShadcnTheme.statusInProgress,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      description: Text(message),
      actions: [
        ShadButton.outline(
          onPressed: onCancel,
          child: Text(cancelText),
        ),
        ShadButton.destructive(
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Mixin for handling unsaved changes in forms
/// Usage: class _MyPageState extends State with UnsavedChangesHandler
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

    final result = await showShadDialog<bool>(
      context: context,
      builder: (context) => UnsavedChangesDialog(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    return result ?? false;
  }

  Widget buildUnsavedChangesWrapper({required Widget child, required BuildContext context}) {
    final navigator = Navigator.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldPop = await onWillPop();
          if (shouldPop && mounted) {
            navigator.pop(result);
          }
        }
      },
      child: child,
    );
  }
}

/// Widget wrapper for form dengan unsaved changes detection
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

    final result = await showShadDialog<bool>(
      context: context,
      builder: (context) => UnsavedChangesDialog(
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
    final navigator = Navigator.of(context);

    return PopScope(
      canPop: !widget.hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && widget.hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            navigator.pop(result);
          }
        }
      },
      child: widget.child,
    );
  }
}

/// Confirm Dialog - Generic confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return ShadDialog.alert(
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isDestructive
                            ? ShadcnTheme.destructive
                            : ShadcnTheme.accent)
                        .withValues(alpha: 0.2),
                    (isDestructive
                            ? ShadcnTheme.destructive
                            : ShadcnTheme.accent)
                        .withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? ShadcnTheme.destructive : ShadcnTheme.accent,
                size: isTablet ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      description: Text(message),
      actions: [
        ShadButton.outline(
          onPressed: onCancel,
          child: Text(cancelText),
        ),
        isDestructive
            ? ShadButton.destructive(
                onPressed: onConfirm,
                child: Text(confirmText),
              )
            : ShadButton(
                onPressed: onConfirm,
                child: Text(confirmText),
              ),
      ],
    );
  }
}
