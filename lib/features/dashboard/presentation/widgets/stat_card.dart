import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/tiket_status_stats.dart';
import 'lightweight_card.dart';
import 'responsive_layout.dart';

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
    final responsive = ResponsiveLayout.of(context);

    if (isLoading) {
      return StatCardSkeleton(isDark: isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Tiket',
                style: TextStyle(
                  fontSize: responsive.isTablet ? 18 : 16,
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
                    fontSize: responsive.isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Use grid for tablet, horizontal scroll for phone
        LayoutBuilder(
          builder: (context, constraints) {
            if (responsive.isTablet && constraints.maxWidth >= 500) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
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

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: Row(
                children: [
                  _StatItem(
                    label: 'Terbuka',
                    value: statusStats.terbuka,
                    icon: Icons.inbox_rounded,
                    color: ShadcnTheme.statusOpen,
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

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    // Responsive sizing
    final cardWidth = responsive.isTablet ? null : (responsive.isSmallPhone ? 95.0 : 110.0);
    final iconSize = responsive.isTablet ? 26.0 : 22.0;
    final iconPadding = responsive.isTablet ? 12.0 : 10.0;
    final valueSize = responsive.isTablet ? 32.0 : 28.0;
    final labelSize = responsive.isTablet ? 14.0 : 13.0;

    return LightweightCard(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isTablet ? 24 : 20,
        vertical: responsive.isTablet ? 20 : 16,
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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            SizedBox(height: responsive.isTablet ? 16 : 14),
            // Simple text instead of AnimatedCount
            Text(
              '$value',
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Container(
            width: responsive.isTablet ? 140 : 120,
            height: responsive.isTablet ? 24 : 20,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
            children: List.generate(3, (index) => Container(
              margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
              width: responsive.isTablet ? 180 : (responsive.isSmallPhone ? 95 : 150),
              height: responsive.isTablet ? 150 : 130,
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
