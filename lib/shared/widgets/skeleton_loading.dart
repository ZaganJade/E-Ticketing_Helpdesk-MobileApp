import 'package:flutter/material.dart';
import '../../core/theme/shadcn_theme.dart';

/// Skeleton Loading - Redesigned with shadcn_ui theme colors
/// A reusable shimmer/skeleton loading component
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Card Skeleton - A skeleton loading for card content
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoading(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                borderRadius: 10,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(
                      width: double.infinity,
                      height: isTablet ? 18 : 16,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoading(
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 14 : 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          SkeletonLoading(
            width: double.infinity,
            height: isTablet ? 16 : 14,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          SkeletonLoading(
            width: double.infinity,
            height: isTablet ? 16 : 14,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          SkeletonLoading(
            width: isTablet ? 200 : 150,
            height: isTablet ? 16 : 14,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// List Skeleton - A list of card skeletons
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(
        height: isTablet ? 12 : 8,
      ),
      itemBuilder: (context, index) => const CardSkeleton(),
    );
  }
}

/// Stats Skeleton - Row of stat skeletons
class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              ),
            ),
            child: Center(
              child: SkeletonLoading(
                width: isTablet ? 60 : 50,
                height: isTablet ? 40 : 32,
                borderRadius: 8,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Container(
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              ),
            ),
            child: Center(
              child: SkeletonLoading(
                width: isTablet ? 60 : 50,
                height: isTablet ? 40 : 32,
                borderRadius: 8,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Container(
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              ),
            ),
            child: Center(
              child: SkeletonLoading(
                width: isTablet ? 60 : 50,
                height: isTablet ? 40 : 32,
                borderRadius: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tiket Card Skeleton - Skeleton for tiket card specifically
class TiketCardSkeleton extends StatelessWidget {
  const TiketCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar skeleton
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            // Content skeleton
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonLoading(
                          width: isTablet ? 80 : 70,
                          height: isTablet ? 24 : 22,
                          borderRadius: 6,
                        ),
                        const Spacer(),
                        SkeletonLoading(
                          width: isTablet ? 50 : 40,
                          height: isTablet ? 16 : 14,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    SkeletonLoading(
                      width: double.infinity,
                      height: isTablet ? 20 : 18,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoading(
                      width: isTablet ? 200 : 150,
                      height: isTablet ? 18 : 16,
                      borderRadius: 4,
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    SkeletonLoading(
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 16 : 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
