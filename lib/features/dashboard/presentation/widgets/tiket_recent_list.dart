import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// List of recent tickets for dashboard
class TiketRecentList extends StatelessWidget {
  final List<Tiket> tiketList;
  final VoidCallback? onViewAll;
  final Function(Tiket)? onTapTiket;
  final bool isLoading;

  const TiketRecentList({
    super.key,
    required this.tiketList,
    this.onViewAll,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiket Terbaru',
              style: AppTextStyles.title,
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.default_),

        // List
        if (isLoading)
          _buildSkeletonList()
        else if (tiketList.isEmpty)
          _buildEmptyState()
        else
          _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return Column(
      children: tiketList.take(5).map((tiket) {
        return _TiketCardMini(
          tiket: tiket,
          onTap: onTapTiket != null ? () => onTapTiket!(tiket) : null,
        );
      }).toList(),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.default_),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.cardRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppBorderRadius.badgeRadius,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.default_),
            Text(
              'Belum ada tiket',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tiket yang Anda buat akan muncul di sini',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini ticket card for dashboard list
class _TiketCardMini extends StatelessWidget {
  final Tiket tiket;
  final VoidCallback? onTap;

  const _TiketCardMini({
    required this.tiket,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.default_),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadgeFromString(
                  status: tiket.status.name,
                ),
                const Spacer(),
                Text(
                  _formatDate(tiket.dibuatPada),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tiket.judul,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (tiket.namaPembuat != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Oleh: ${tiket.namaPembuat}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}h lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}j lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m lalu';
    } else {
      return 'Baru';
    }
  }
}
