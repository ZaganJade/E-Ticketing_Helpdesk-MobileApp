import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// Empty State - Redesigned with shadcn_ui
/// A reusable component for displaying empty states
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  factory EmptyState.tickets({String? actionLabel, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.confirmation_number_outlined,
      title: 'Belum ada tiket',
      subtitle: 'Tiket yang Anda buat akan muncul di sini',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyState.notifications({String? actionLabel, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'Belum ada notifikasi',
      subtitle: 'Notifikasi akan muncul saat ada pembaruan tiket',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyState.search({String? actionLabel, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search,
      title: 'Tidak ada hasil',
      subtitle: 'Coba gunakan kata kunci lain',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyState.comments({String? actionLabel, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Belum ada komentar',
      subtitle: 'Jadilah yang pertama memberikan komentar',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyState.attachments({String? actionLabel, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.attach_file,
      title: 'Belum ada lampiran',
      subtitle: 'File yang dilampirkan akan muncul di sini',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final color = iconColor ?? ShadcnTheme.accent;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: isTablet ? 56 : 48,
                color: color,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isTablet ? 24 : 20),
              ShadButton.outline(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
