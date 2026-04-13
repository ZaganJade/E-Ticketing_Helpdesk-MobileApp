import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Quick actions section for dashboard
class QuickActions extends StatelessWidget {
  final VoidCallback? onBuatTiket;
  final VoidCallback? onLihatSemuaTiket;

  const QuickActions({
    super.key,
    this.onBuatTiket,
    this.onLihatSemuaTiket,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: AppSpacing.default_),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add,
                label: 'Buat Tiket',
                color: AppColors.primary,
                onTap: onBuatTiket,
              ),
            ),
            const SizedBox(width: AppSpacing.default_),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.list,
                label: 'Lihat Semua',
                color: AppColors.secondary,
                onTap: onLihatSemuaTiket,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppBorderRadius.cardRadius,
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating action button for creating ticket
class BuatTiketFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const BuatTiketFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Buat Tiket'),
      backgroundColor: AppColors.primary,
    );
  }
}
