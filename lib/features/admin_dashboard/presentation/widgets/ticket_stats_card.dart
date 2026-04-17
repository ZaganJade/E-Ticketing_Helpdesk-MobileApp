import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

class TicketStatsCard extends StatelessWidget {
  final int total;
  final int terbuka;
  final int diproses;
  final int selesai;
  final bool isLoading;

  const TicketStatsCard({
    super.key,
    required this.total,
    required this.terbuka,
    required this.diproses,
    required this.selesai,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (isLoading) {
      return TicketStatsCardSkeleton(isDark: isDark, isTablet: isTablet);
    }

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
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent.withValues(alpha: 0.2),
                      ShadcnTheme.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Tiket',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Total $total tiket di sistem',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Terbuka',
                  count: terbuka,
                  color: ShadcnTheme.statusOpen,
                  icon: Icons.inbox_rounded,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: _StatItem(
                  label: 'Diproses',
                  count: diproses,
                  color: ShadcnTheme.statusInProgress,
                  icon: Icons.sync_rounded,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: _StatItem(
                  label: 'Selesai',
                  count: selesai,
                  color: ShadcnTheme.statusDone,
                  icon: Icons.check_circle_rounded,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isTablet;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: isTablet ? 20 : 18, color: color),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketStatsCardSkeleton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const TicketStatsCardSkeleton({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 42 : 38,
                height: isTablet ? 42 : 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.6),
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160,
                      height: isTablet ? 20 : 18,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Container(
                      width: 140,
                      height: isTablet ? 14 : 12,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? (isTablet ? 12 : 10) : 0,
                    left: index > 0 ? (isTablet ? 12 : 10) : 0,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                              .withValues(alpha: 0.15),
                          (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                              .withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: isTablet ? 24 : 20,
                          height: isTablet ? 24 : 20,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: isTablet ? 10 : 8),
                        Container(
                          width: 60,
                          height: isTablet ? 32 : 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Container(
                          width: 50,
                          height: isTablet ? 14 : 12,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
