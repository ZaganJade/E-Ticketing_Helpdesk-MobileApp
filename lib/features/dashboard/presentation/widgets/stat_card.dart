import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/tiket_status_stats.dart';
import 'responsive_layout.dart';

/// Modern stats overview with animated counters and gradient accent bars - Fully Responsive
class StatCard extends StatelessWidget {
  final int total;
  final TiketStatusStats statusStats;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.total,
    required this.statusStats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = ResponsiveLayout.of(context);

    if (isLoading) {
      return StatCardSkeleton(isDark: isDark);
    }

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
              children: [
              Container(
                padding: EdgeInsets.all(responsive.isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent.withValues(alpha: 0.2),
                      ShadcnTheme.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: ShadcnTheme.accent,
                  size: responsive.isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: responsive.isTablet ? 16 : 12),
              Text(
                'Ringkasan Tiket',
                style: TextStyle(
                  fontSize: responsive.isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ShadcnTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: total),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      '$value Total',
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: ShadcnTheme.accent,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Status cards — grid on tablet, horizontal scroll on phone
        LayoutBuilder(
          builder: (context, constraints) {
            if (responsive.isTablet && constraints.maxWidth >= 500) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                child: Row(
                children: [
                    Expanded(
                      child: _AnimatedStatItem(
                        label: 'Terbuka',
                        value: statusStats.terbuka,
                        icon: Icons.inbox_rounded,
                        color: ShadcnTheme.statusOpen,
                        delayMs: 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatItem(
                        label: 'Diproses',
                        value: statusStats.diproses,
                        icon: Icons.sync_rounded,
                        color: ShadcnTheme.statusInProgress,
                        delayMs: 100,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatItem(
                        label: 'Selesai',
                        value: statusStats.selesai,
                        icon: Icons.check_circle_rounded,
                        color: ShadcnTheme.statusDone,
                        delayMs: 200,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: Row(
                children: [
                  _AnimatedStatItem(
                    label: 'Terbuka',
                    value: statusStats.terbuka,
                    icon: Icons.inbox_rounded,
                    color: ShadcnTheme.statusOpen,
                    delayMs: 0,
                    fixedWidth: responsive.isSmallPhone ? 105.0 : 120.0,
                  ),
                  const SizedBox(width: 10),
                  _AnimatedStatItem(
                    label: 'Diproses',
                    value: statusStats.diproses,
                    icon: Icons.sync_rounded,
                    color: ShadcnTheme.statusInProgress,
                    delayMs: 100,
                    fixedWidth: responsive.isSmallPhone ? 105.0 : 120.0,
                  ),
                  const SizedBox(width: 10),
                  _AnimatedStatItem(
                    label: 'Selesai',
                    value: statusStats.selesai,
                    icon: Icons.check_circle_rounded,
                    color: ShadcnTheme.statusDone,
                    delayMs: 200,
                    fixedWidth: responsive.isSmallPhone ? 105.0 : 120.0,
                  ),
                ],
              ),
            );
          },
        ),
      ],
  );
  }
}

/// Individual animated stat item card with gradient top bar and staggered entrance
class _AnimatedStatItem extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final int delayMs;
  final double? fixedWidth;

  const _AnimatedStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delayMs,
    this.fixedWidth,
  });

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = ResponsiveLayout.of(context);

    final iconSize = responsive.isTablet ? 22.0 : 18.0;
    final iconPadding = responsive.isTablet ? 10.0 : 8.0;
    final valueSize = responsive.isTablet ? 30.0 : 26.0;
    final labelSize = responsive.isTablet ? 13.0 : 12.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SizedBox(
          width: widget.fixedWidth,
          child: Container(
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
                // Gradient top accent bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.8),
                        widget.color.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                // Card content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.isTablet ? 20 : 16,
                    vertical: responsive.isTablet ? 18 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with gradient background
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withValues(alpha: 0.2),
                              widget.color.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, size: iconSize, color: widget.color),
                      ),
                      SizedBox(height: responsive.isTablet ? 14 : 12),
                      // Animated counter
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.value),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              fontSize: valueSize,
                              fontWeight: FontWeight.w800,
                              color: ShadTheme.of(context).colorScheme.foreground,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      // Label
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w500,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
        ),
      ),
    );
  }
}

/// Skeleton loading for stat card - Responsive (Public)
class StatCardSkeleton extends StatelessWidget {
  final bool isDark;
  const StatCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton with icon circle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
              children: [
              _ShimmerBox(
                width: responsive.isTablet ? 44 : 40,
                height: responsive.isTablet ? 44 : 40,
                borderRadius: 12,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _ShimmerBox(
                width: responsive.isTablet ? 140 : 120,
                height: responsive.isTablet ? 24 : 20,
                borderRadius: 4,
                isDark: isDark,
              ),
              const Spacer(),
              _ShimmerBox(
                width: responsive.isTablet ? 70 : 60,
                height: responsive.isTablet ? 28 : 24,
                borderRadius: 12,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Cards skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
          children: List.generate(3, (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < 2 ? 10 : 0,
                ),
                child: Column(
                  children: [
                    // Top bar shimmer
                    _ShimmerBox(
                      width: double.infinity,
                      height: 4,
                      borderRadius: 12,
                      isDark: isDark,
                    ),
                    Container(
                      height: responsive.isTablet ? 130 : 115,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        ),
                      ),
                      padding: EdgeInsets.all(responsive.isTablet ? 16 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(
                            width: responsive.isTablet ? 36 : 30,
                            height: responsive.isTablet ? 36 : 30,
                            borderRadius: 10,
                            isDark: isDark,
                          ),
                          const Spacer(),
                          _ShimmerBox(
                            width: responsive.isTablet ? 50 : 40,
                            height: responsive.isTablet ? 26 : 22,
                            borderRadius: 4,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 4),
                          _ShimmerBox(
                            width: responsive.isTablet ? 60 : 48,
                            height: responsive.isTablet ? 14 : 12,
                            borderRadius: 3,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
      ),
      ],
    );
  }
}

/// Shimmer animation box for skeleton loading
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isDark,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border;
    final highlightColor = widget.isDark
        ? ShadcnTheme.darkMuted
        : const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
