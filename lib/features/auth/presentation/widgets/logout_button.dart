import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_modal.dart';
import '../cubit/auth_cubit.dart';

/// Logout button with confirmation dialog
class LogoutButton extends StatelessWidget {
  final AppButtonVariant variant;
  final AppButtonSize size;
  final String? label;

  const LogoutButton({
    super.key,
    this.variant = AppButtonVariant.destructive,
    this.size = AppButtonSize.medium,
    this.label,
  });

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await AppModal.showConfirmation(
      context: context,
      title: 'Konfirmasi Logout',
      message: 'Yakin ingin keluar dari aplikasi?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      // Perform logout
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label ?? 'Logout',
      variant: variant,
      size: size,
      icon: Icons.logout,
      onPressed: () => _handleLogout(context),
    );
  }
}

/// Icon-only logout button for AppBar
class LogoutIconButton extends StatelessWidget {
  const LogoutIconButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppModal.showConfirmation(
      context: context,
      title: 'Konfirmasi Logout',
      message: 'Yakin ingin keluar dari aplikasi?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => _handleLogout(context),
      tooltip: 'Logout',
    );
  }
}
