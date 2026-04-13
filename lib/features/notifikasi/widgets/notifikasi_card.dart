import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/notifikasi_model.dart';

class NotifikasiCard extends StatelessWidget {
  final NotifikasiModel notifikasi;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotifikasiCard({
    super.key,
    required this.notifikasi,
    this.onTap,
    this.onDismiss,
  });

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notifikasi.getIconConfig();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notifikasi.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.default_),
        decoration: BoxDecoration(
          color: AppColors.statusDiproses.withOpacity(0.1),
          borderRadius: AppBorderRadius.cardRadius,
        ),
        child: Icon(
          Icons.check_circle_outline,
          color: AppColors.statusDiproses,
        ),
      ),
      child: AppCard(
        onTap: onTap,
        backgroundColor: notifikasi.sudahDibaca
            ? null
            : (isDark
                ? AppColors.statusDiproses.withOpacity(0.05)
                : AppColors.statusDiproses.withOpacity(0.03)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.default_),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notifikasi.judul,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: notifikasi.sudahDibaca
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notifikasi.sudahDibaca)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusDiproses,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notifikasi.pesan,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _getRelativeTime(notifikasi.dibuatPada),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
