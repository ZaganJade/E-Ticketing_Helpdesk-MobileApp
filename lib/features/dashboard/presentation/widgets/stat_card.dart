import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tiket_status_stats.dart';

/// Main stat card for total tickets
class StatCard extends StatelessWidget {
  final int total;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.total,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isLoading
          ? _buildSkeleton()
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Tiket',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        total.toString(),
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mini stat card for status breakdown
class MiniStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isLoading;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: isLoading
          ? _buildSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  count.toString(),
                  style: AppTextStyles.title.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Row of mini stat cards for status breakdown
class StatusStatsRow extends StatelessWidget {
  final TiketStatusStats stats;
  final bool isLoading;

  const StatusStatsRow({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            label: 'Terbuka',
            count: stats.terbuka,
            color: AppColors.statusTerbuka,
            icon: Icons.pending,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MiniStatCard(
            label: 'Diproses',
            count: stats.diproses,
            color: AppColors.statusDiproses,
            icon: Icons.sync,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MiniStatCard(
            label: 'Selesai',
            count: stats.selesai,
            color: AppColors.statusSelesai,
            icon: Icons.check_circle,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
