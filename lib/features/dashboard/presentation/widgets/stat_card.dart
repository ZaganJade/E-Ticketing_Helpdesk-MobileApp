import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/tiket_status_stats.dart';

/// Modern stats overview with horizontal scrolling cards - Fully Responsive
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    if (isLoading) {
      return StatCardSkeleton(isDark: isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Tiket',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ShadcnTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$total Total',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scrolling stat cards with responsive sizing
        LayoutBuilder(
          builder: (context, constraints) {
            // For tablets, show a grid instead of scrolling
            if (isTablet && constraints.maxWidth >= 500) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Terbuka',
                        value: statusStats.terbuka,
                        icon: Icons.inbox_rounded,
                        color: ShadcnTheme.statusOpen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatItem(
                        label: 'Diproses',
                        value: statusStats.diproses,
                        icon: Icons.sync_rounded,
                        color: ShadcnTheme.statusInProgress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatItem(
                        label: 'Selesai',
                        value: statusStats.selesai,
                        icon: Icons.check_circle_rounded,
                        color: ShadcnTheme.statusDone,
                      ),
                    ),
                  ],
                ),
              );
            }

            // For phones, use horizontal scrolling
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  _StatItem(
                    label: 'Terbuka',
                    value: statusStats.terbuka,
                    icon: Icons.inbox_rounded,
                    color: ShadcnTheme.statusOpen,
                    isFirst: true,
                  ),
                  const SizedBox(width: 12),
                  _StatItem(
                    label: 'Diproses',
                    value: statusStats.diproses,
                    icon: Icons.sync_rounded,
                    color: ShadcnTheme.statusInProgress,
                  ),
                  const SizedBox(width: 12),
                  _StatItem(
                    label: 'Selesai',
                    value: statusStats.selesai,
                    icon: Icons.check_circle_rounded,
                    color: ShadcnTheme.statusDone,
                    isLast: true,
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

/// Individual stat item card - Fully Responsive
class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isSmallPhone = size.width < 360;

    // Responsive sizing
    final cardWidth = isTablet ? null : (isSmallPhone ? 95.0 : 110.0);
    final iconSize = isTablet ? 26.0 : 22.0;
    final iconPadding = isTablet ? 12.0 : 10.0;
    final valueSize = isTablet ? 32.0 : 28.0;
    final labelSize = isTablet ? 14.0 : 13.0;

    return ShadCard(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 20 : 16,
      ),
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with soft background
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            SizedBox(height: isTablet ? 16 : 14),
            // Value with animation
            AnimatedCount(
              count: value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                color: ShadTheme.of(context).colorScheme.foreground,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated counter widget - Responsive
class AnimatedCount extends StatefulWidget {
  final int count;
  final TextStyle style;

  const AnimatedCount({
    super.key,
    required this.count,
    required this.style,
  });

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = IntTween(begin: 0, end: widget.count).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _animation = IntTween(begin: oldWidget.count, end: widget.count).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Text(
        '${_animation.value}',
        style: widget.style,
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            width: isTablet ? 140 : 120,
            height: isTablet ? 24 : 20,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: List.generate(3, (index) => Container(
              margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
              width: isTablet ? 180 : (size.width < 360 ? 95 : 150),
              height: isTablet ? 150 : 130,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),
        ),
      ],
    );
  }
}
