import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Section for open tickets that need to be handled (helpdesk only)
class TiketTerbukaSection extends StatelessWidget {
  final List<Tiket> tiketList;
  final Function(String)? onAmbilTiket;
  final bool isLoading;

  const TiketTerbukaSection({
    super.key,
    required this.tiketList,
    this.onAmbilTiket,
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
              'Tiket Terbuka',
              style: AppTextStyles.title,
            ),
            if (tiketList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusTerbuka.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tiketList.length} tiket',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusTerbuka,
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
        return _TiketTerbukaCard(
          tiket: tiket,
          onAmbil: onAmbilTiket != null
              ? () => onAmbilTiket!(tiket.id)
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
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppBorderRadius.buttonRadius,
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

class _TiketTerbukaCard extends StatelessWidget {
  final Tiket tiket;
  final VoidCallback? onAmbil;

  const _TiketTerbukaCard({
    required this.tiket,
    this.onAmbil,
  });

  @override
  Widget build(BuildContext context) {
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
              StatusBadgeFromString(
                status: tiket.status.name,
              ),
              const Spacer(),
              AppButton(
                label: 'Ambil',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.small,
                onPressed: onAmbil,
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dibuat: ${_formatDate(tiket.dibuatPada)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
