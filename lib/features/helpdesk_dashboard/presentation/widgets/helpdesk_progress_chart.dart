import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

/// Donut chart segment data
class _ChartSegment {
  final String label;
  final int value;
  final Color color;
  final double percentage;

  _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });
}

/// Donut chart painter for status distribution
class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final double strokeWidth;
  final double animationValue;

  _DonutChartPainter({
    required this.segments,
    required this.strokeWidth,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background track
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -math.pi / 2;
    final totalSweep = 2 * math.pi * animationValue;

    for (final segment in segments) {
      if (segment.value == 0) continue;

      final sweepAngle = segment.percentage * totalSweep;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Helpdesk-specific progress chart with animated donut + legend
class HelpdeskProgressChart extends StatefulWidget {
  final int perluDitangani;
  final int diproses;
  final int selesai;
  final bool isLoading;

  const HelpdeskProgressChart({
    super.key,
    required this.perluDitangani,
    required this.diproses,
    required this.selesai,
    this.isLoading = false,
  });

  @override
  State<HelpdeskProgressChart> createState() => _HelpdeskProgressChartState();
}

class _HelpdeskProgressChartState extends State<HelpdeskProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _total => widget.perluDitangani + widget.diproses + widget.selesai;

  List<_ChartSegment> get _segments {
    final total = _total;
    if (total == 0) return [];
    return [
      _ChartSegment(
        label: 'Perlu Ditangani',
        value: widget.perluDitangani,
        color: ShadcnTheme.statusOpen,
        percentage: widget.perluDitangani / total,
      ),
      _ChartSegment(
        label: 'Diproses',
        value: widget.diproses,
        color: ShadcnTheme.statusInProgress,
        percentage: widget.diproses / total,
      ),
      _ChartSegment(
        label: 'Selesai',
        value: widget.selesai,
        color: ShadcnTheme.statusDone,
        percentage: widget.selesai / total,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final segments = _segments;
    final hasData = _total > 0;

    if (widget.isLoading) {
      return _buildSkeleton(isDark, isTablet);
    }

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return ShadCard(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
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
                  Icons.donut_large_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Distribusi Status',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
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
                child: Text(
                  '$_total Total',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),
          // Chart and legend - responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 350) {
                return Column(
                  children: [
                    _buildChart(context, segments, isTablet, true),
                    const SizedBox(height: 16),
                    _buildLegend(context, segments, isDark, isTablet),
                  ],
                );
              }
              return Row(
                children: [
                  _buildChart(context, segments, isTablet, false),
                  SizedBox(width: isTablet ? 32 : 20),
                  Expanded(
                    child: _buildLegend(context, segments, isDark, isTablet),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<_ChartSegment> segments,
    bool isTablet,
    bool isVertical,
  ) {
    final chartSize = isTablet ? 150.0 : (isVertical ? 130.0 : 110.0);
    final strokeWidth = isTablet ? 22.0 : 18.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(chartSize, chartSize),
              painter: _DonutChartPainter(
                segments: segments,
                strokeWidth: strokeWidth,
                animationValue: _animation.value,
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: _total),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: TextStyle(
                        fontSize: isTablet ? 26 : (isVertical ? 22 : 20),
                        fontWeight: FontWeight.w800,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 11,
                    fontWeight: FontWeight.w500,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(
    BuildContext context,
    List<_ChartSegment> segments,
    bool isDark,
    bool isTablet,
  ) {
    return Column(
      children: segments.map((segment) {
        if (segment.value == 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(isTablet ? 14 : 10),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 12 : 10,
                height: isTablet ? 12 : 10,
                decoration: BoxDecoration(
                  color: segment.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  segment.label,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                ),
              ),
              Text(
                '${segment.value}',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w700,
                  color: segment.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${(segment.percentage * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.w400,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkeleton(bool isDark, bool isTablet) {
    return ShadCard(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 44 : 40,
                height: isTablet ? 44 : 40,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: isTablet ? 140 : 120,
                height: isTablet ? 22 : 18,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: isTablet ? 70 : 60,
                height: isTablet ? 28 : 24,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Row(
            children: [
              Container(
                width: isTablet ? 150 : 110,
                height: isTablet ? 150 : 110,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isTablet ? 32 : 20),
              Expanded(
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      height: isTablet ? 42 : 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? ShadcnTheme.darkBorder
                            : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
