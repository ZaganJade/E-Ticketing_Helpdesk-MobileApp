import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/tiket_model.dart';

class TiketCard extends StatelessWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCard({
    super.key,
    required this.tiket,
    this.onTap,
  });

  TiketStatus _getStatusFromString(String status) {
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

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} bulan yang lalu';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari yang lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                status: _getStatusFromString(tiket.status),
              ),
              const Spacer(),
              Text(
                _getRelativeTime(tiket.dibuatPada),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tiket.judul,
            style: AppTextStyles.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tiket.deskripsi,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.default_),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                tiket.pembuatNama ?? 'Unknown',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (tiket.penanggungJawabNama != null) ...[
                const SizedBox(width: AppSpacing.default_),
                Icon(
                  Icons.support_agent,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  tiket.penanggungJawabNama!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class TiketCardMini extends StatelessWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCardMini({
    super.key,
    required this.tiket,
    this.onTap,
  });

  TiketStatus _getStatusFromString(String status) {
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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.default_),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(tiket.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.default_),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tiket.judul,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                StatusBadge(
                  status: _getStatusFromString(tiket.status),
                  showIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return AppColors.statusTerbuka;
      case 'DIPROSES':
        return AppColors.statusDiproses;
      case 'SELESAI':
        return AppColors.statusSelesai;
      default:
        return AppColors.textTertiary;
    }
  }
}
