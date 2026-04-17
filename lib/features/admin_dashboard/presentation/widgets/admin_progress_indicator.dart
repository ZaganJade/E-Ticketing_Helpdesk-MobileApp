import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

class AdminProgressIndicator extends StatelessWidget {
  final int total;
  final int terbuka;
  final int diproses;
  final int selesai;
  final bool isLoading;

  const AdminProgressIndicator({
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

    final completionRate = total > 0 ? (selesai / total) * 100 : 0.0;
    final processingRate = total > 0 ? (diproses / total) * 100 : 0.0;
    final openRate = total > 0 ? (terbuka / total) * 100 : 0.0;

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
                      ShadcnTheme.statusDone.withValues(alpha: 0.2),
                      ShadcnTheme.statusDone.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: ShadcnTheme.statusDone,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Penyelesaian',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${completionRate.toStringAsFixed(0)}% tiket selesai',
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
          SizedBox(height: isTablet ? 24 : 20),
          if (isLoading)
            _buildSkeletonProgress(isDark, isTablet)
          else if (total == 0)
            _buildEmptyState(context, isDark, isTablet)
          else
            _buildProgressBars(
              context: context,
              completionRate: completionRate,
              processingRate: processingRate,
              openRate: openRate,
              isTablet: isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBars({
    required BuildContext context,
    required double completionRate,
    required double processingRate,
    required double openRate,
    required bool isTablet,
  }) {
    return Column(
      children: [
        _ProgressBar(
          label: 'Selesai',
          percentage: completionRate,
          color: ShadcnTheme.statusDone,
          count: selesai,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _ProgressBar(
          label: 'Diproses',
          percentage: processingRate,
          color: ShadcnTheme.statusInProgress,
          count: diproses,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _ProgressBar(
          label: 'Terbuka',
          percentage: openRate,
          color: ShadcnTheme.statusOpen,
          count: terbuka,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: isTablet ? 40 : 32,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Belum ada data',
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonProgress(bool isDark, bool isTablet) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < 2 ? (isTablet ? 12 : 10) : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: isTablet ? 14 : 12,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Container(
                width: double.infinity,
                height: isTablet ? 12 : 10,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;
  final int count;
  final bool isTablet;

  const _ProgressBar({
    required this.label,
    required this.percentage,
    required this.color,
    required this.count,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const Spacer(),
            Text(
              '$count tiket (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Container(
          height: isTablet ? 10 : 8,
          decoration: BoxDecoration(
            color: ShadTheme.of(context).colorScheme.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withValues(alpha: 0.9),
                    color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminProgressIndicatorSkeleton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const AdminProgressIndicatorSkeleton({
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
          width: 1,
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
                      width: 180,
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
          SizedBox(height: isTablet ? 24 : 20),
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < 2 ? (isTablet ? 12 : 10) : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: isTablet ? 14 : 12,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Container(
                    width: double.infinity,
                    height: isTablet ? 12 : 10,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
