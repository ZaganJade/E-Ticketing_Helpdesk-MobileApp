import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum TiketStatus {
  terbuka,
  diproses,
  selesai,
}

class StatusBadge extends StatelessWidget {
  final TiketStatus status;
  final bool showIcon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppSpacing.md : AppSpacing.sm,
        vertical: isLarge ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppBorderRadius.badgeRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: isLarge ? 16 : 12,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: isLarge
                ? AppTextStyles.subtitle.copyWith(color: color)
                : AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusConfig() {
    switch (status) {
      case TiketStatus.terbuka:
        return (
          'Terbuka',
          AppColors.statusTerbuka,
          Icons.access_time,
        );
      case TiketStatus.diproses:
        return (
          'Diproses',
          AppColors.statusDiproses,
          Icons.sync,
        );
      case TiketStatus.selesai:
        return (
          'Selesai',
          AppColors.statusSelesai,
          Icons.check_circle,
        );
    }
  }
}

class StatusBadgeFromString extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool isLarge;

  const StatusBadgeFromString({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final tiketStatus = _parseStatus(status);
    return StatusBadge(
      status: tiketStatus,
      showIcon: showIcon,
      isLarge: isLarge,
    );
  }

  TiketStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return TiketStatus.terbuka;
      case 'DIPROSES':
        return TiketStatus.diproses;
      case 'SELESAI':
        return TiketStatus.selesai;
      default:
        return TiketStatus.terbuka;
    }
  }
}
