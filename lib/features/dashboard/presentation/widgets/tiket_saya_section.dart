import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Section for tickets assigned to current helpdesk
class TiketSayaSection extends StatelessWidget {
  final List<Tiket> tiketList;
  final Function(Tiket)? onTapTiket;
  final bool isLoading;

  const TiketSayaSection({
    super.key,
    required this.tiketList,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tiketList.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiket Saya',
              style: AppTextStyles.title,
            ),
            if (tiketList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusDiproses.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tiketList.length} tiket',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusDiproses,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.default_),
        if (isLoading)
          _buildSkeletonList()
        else
          _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return Column(
      children: tiketList.take(5).map((tiket) {
        return _TiketSayaCard(
          tiket: tiket,
          onTap: onTapTiket != null
              ? () => onTapTiket!(tiket)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(2, (index) {
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
}

class _TiketSayaCard extends StatelessWidget {
  final Tiket tiket;
  final VoidCallback? onTap;

  const _TiketSayaCard({
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
                'Pembuat: ${tiket.namaPembuat}',
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
