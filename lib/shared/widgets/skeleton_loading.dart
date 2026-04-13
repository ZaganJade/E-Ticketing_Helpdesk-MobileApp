import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const SkeletonLoading(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: AppSpacing.default_),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoading(width: double.infinity, height: 16),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonLoading(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.default_),
          const SkeletonLoading(width: double.infinity, height: 14),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLoading(width: double.infinity, height: 14),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLoading(width: 200, height: 14),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.default_),
      itemBuilder: (_, __) => const CardSkeleton(),
    );
  }
}

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: SkeletonLoading(width: double.infinity, height: 80)),
        SizedBox(width: AppSpacing.default_),
        Expanded(child: SkeletonLoading(width: double.infinity, height: 80)),
        SizedBox(width: AppSpacing.default_),
        Expanded(child: SkeletonLoading(width: double.infinity, height: 80)),
      ],
    );
  }
}
