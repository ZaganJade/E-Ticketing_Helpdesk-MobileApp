import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tiket_status_stats.dart';

/// Progress bar visualization for status proportion
class StatusProgressIndicator extends StatelessWidget {
  final TiketStatusStats stats;
  final bool isLoading;

  const StatusProgressIndicator({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    if (stats.total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.default_),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Belum ada data tiket',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Status',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (stats.terbuka > 0)
                  Expanded(
                    flex: stats.terbuka,
                    child: Container(
                      height: 16,
                      color: AppColors.statusTerbuka,
                    ),
                  ),
                if (stats.diproses > 0)
                  Expanded(
                    flex: stats.diproses,
                    child: Container(
                      height: 16,
                      color: AppColors.statusDiproses,
                    ),
                  ),
                if (stats.selesai > 0)
                  Expanded(
                    flex: stats.selesai,
                    child: Container(
                      height: 16,
                      color: AppColors.statusSelesai,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.default_),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                'Terbuka',
                AppColors.statusTerbuka,
                stats.terbuka,
                stats.terbukaPercentage,
              ),
              _buildLegendItem(
                'Diproses',
                AppColors.statusDiproses,
                stats.diproses,
                stats.diprosesPercentage,
              ),
              _buildLegendItem(
                'Selesai',
                AppColors.statusSelesai,
                stats.selesai,
                stats.selesaiPercentage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    int count,
    double percentage,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${(percentage * 100).toInt()}%',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '($count)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: AppSpacing.default_),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              return Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.shimmerBase,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 30,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
