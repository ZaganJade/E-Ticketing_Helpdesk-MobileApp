import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/admin_dashboard_stats.dart';

class HelpdeskPerformanceCard extends StatelessWidget {
  final List<HelpdeskPerformance> performances;

  const HelpdeskPerformanceCard({
    super.key,
    required this.performances,
  });

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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.statusDone.withValues(alpha: 0.2),
                      ShadcnTheme.statusDone.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: ShadcnTheme.statusDone,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Text(
                  'Performa Helpdesk',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          // Performance list
          if (performances.isEmpty)
            _EmptyPerformanceCard(isTablet: isTablet)
          else
            ...performances.asMap().entries.map((entry) {
              final index = entry.key;
              final perf = entry.value;
              final isTopPerformer = index == 0;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < performances.length - 1
                      ? (isTablet ? 12 : 10)
                      : 0,
                ),
                child: _PerformanceItem(
                  performance: perf,
                  isTopPerformer: isTopPerformer,
                  isTablet: isTablet,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final HelpdeskPerformance performance;
  final bool isTopPerformer;
  final bool isTablet;

  const _PerformanceItem({
    required this.performance,
    required this.isTopPerformer,
    required this.isTablet,
  });

  Color _getPerformanceColor() {
    if (performance.persentasePenyelesaian >= 80) {
      return ShadcnTheme.statusDone;
    } else if (performance.persentasePenyelesaian >= 60) {
      return ShadcnTheme.statusInProgress;
    }
    return ShadcnTheme.statusOpen;
  }

  @override
  Widget build(BuildContext context) {
    final performanceColor = _getPerformanceColor();

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isTopPerformer
            ? performanceColor.withValues(alpha: 0.1)
            : null,
        gradient: isTopPerformer
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  performanceColor.withValues(alpha: 0.15),
                  performanceColor.withValues(alpha: 0.08),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: performanceColor.withValues(alpha: isTopPerformer ? 0.4 : 0.2),
          width: isTopPerformer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge for top performer
          if (isTopPerformer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: performanceColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terbaik',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (!isTopPerformer) const SizedBox(width: 44),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.helpdeskNama,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Row(
                  children: [
                    Expanded(
                      child: _StatRow(
                        label: 'Ditugaskan',
                        value: performance.totalTiketDitugaskan.toString(),
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: _StatRow(
                        label: 'Selesai',
                        value: performance.tiketSelesai.toString(),
                        color: performanceColor,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Row(
                  children: [
                    Expanded(
                      child: _StatRow(
                        label: 'Rata-rata',
                        value: '${performance.rataRataPenyelesaianJam.toStringAsFixed(1)}j',
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: _StatRow(
                        label: 'Penyelesaian',
                        value: '${performance.persentasePenyelesaian.toStringAsFixed(0)}%',
                        color: performanceColor,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isTablet;

  const _StatRow({
    required this.label,
    required this.value,
    this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: color ?? ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
      ],
    );
  }
}

class _EmptyPerformanceCard extends StatelessWidget {
  final bool isTablet;

  const _EmptyPerformanceCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 32),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: isTablet ? 48 : 40,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Belum ada data performa',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
