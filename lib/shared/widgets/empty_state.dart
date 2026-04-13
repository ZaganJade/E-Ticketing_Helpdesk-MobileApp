import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                variant: AppButtonVariant.outline,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
