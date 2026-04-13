import 'dart:math' as math show pi, atan2;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tiket_status_stats.dart';

/// Animated circular chart segment
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

/// Custom painter for animated donut chart
class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final double animationValue;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.segments,
    required this.animationValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 28.0;
    final innerRadius = radius - strokeWidth;

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.value == 0) continue;

      final sweepAngle = segment.percentage * 2 * math.pi * animationValue;
      final isSelected = selectedIndex == i;

      // Outer glow for selected segment
      if (isSelected) {
        final glowPaint = Paint()
          ..color = segment.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 12
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );
      }

      // Main segment
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
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

    // Inner white/dark circle for donut effect
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius - 4, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segments.length != segments.length;
  }
}

/// Interactive circular progress chart with animations
class StatusProgressIndicator extends StatefulWidget {
  final TiketStatusStats stats;
  final bool isLoading;

  const StatusProgressIndicator({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  State<StatusProgressIndicator> createState() => _StatusProgressIndicatorState();
}

class _StatusProgressIndicatorState extends State<StatusProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartAnimation;
  int? _selectedIndex;
  int _hoveredLegendIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(StatusProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats && !widget.isLoading) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<_ChartSegment> get _segments {
    final total = widget.stats.total;
    if (total == 0) return [];

    return [
      _ChartSegment(
        label: 'Terbuka',
        value: widget.stats.terbuka,
        color: AppColors.statusTerbuka,
        percentage: widget.stats.terbuka / total,
      ),
      _ChartSegment(
        label: 'Diproses',
        value: widget.stats.diproses,
        color: AppColors.statusDiproses,
        percentage: widget.stats.diproses / total,
      ),
      _ChartSegment(
        label: 'Selesai',
        value: widget.stats.selesai,
        color: AppColors.statusSelesai,
        percentage: widget.stats.selesai / total,
      ),
    ];
  }

  void _onChartTap(TapDownDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPosition = details.localPosition;

    // Calculate angle
    final dx = touchPosition.dx - center.dx;
    final dy = touchPosition.dy - center.dy;
    var angle = (dx == 0 && dy == 0) ? 0 : (math.atan2(dy, dx) + math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    // Find which segment was tapped
    double currentAngle = 0;
    for (int i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      if (segment.value == 0) continue;

      final sweepAngle = segment.percentage * 2 * math.pi;
      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        setState(() {
          _selectedIndex = _selectedIndex == i ? null : i;
        });
        HapticFeedback.lightImpact();
        break;
      }
      currentAngle += sweepAngle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final segments = _segments;
    final hasData = widget.stats.total > 0;

    if (widget.isLoading) {
      return _buildSkeleton();
    }

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkSurface.withValues(alpha: 0.6),
                    AppColors.darkSurface.withValues(alpha: 0.3),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.4),
                  ],
          ),
          borderRadius: AppBorderRadius.cardRadius,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.default_),
              Text(
                'Belum ada data tiket',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface.withValues(alpha: 0.6),
                  AppColors.darkSurface.withValues(alpha: 0.3),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.4),
                ],
        ),
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribusi Status',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.stats.total} Total',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Chart and Legend Row
          Row(
            children: [
              // Interactive Donut Chart
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxWidth.clamp(140, 200),
                    );
                    return GestureDetector(
                      onTapDown: (details) => _onChartTap(details, size),
                      child: AnimatedBuilder(
                        animation: _chartAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: size,
                            painter: _DonutChartPainter(
                              segments: segments,
                              animationValue: _chartAnimation.value,
                              selectedIndex: _selectedIndex,
                            ),
                            child: Container(
                              width: size.width,
                              height: size.height,
                              alignment: Alignment.center,
                              child: _selectedIndex != null
                                  ? _buildSelectedInfo(segments[_selectedIndex!])
                                  : _buildTotalInfo(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: AppSpacing.default_),

              // Interactive Legend
              Expanded(
                flex: 3,
                child: Column(
                  children: segments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final segment = entry.value;
                    if (segment.value == 0) return const SizedBox.shrink();

                    final isSelected = _selectedIndex == index;
                    final isHovered = _hoveredLegendIndex == index;

                    return MouseRegion(
                      onEnter: (_) {
                        setState(() => _hoveredLegendIndex = index);
                      },
                      onExit: (_) {
                        setState(() => _hoveredLegendIndex = -1);
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = isSelected ? null : index;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected || isHovered
                                  ? [
                                      segment.color.withValues(alpha: 0.15),
                                      segment.color.withValues(alpha: 0.05),
                                    ]
                                  : [
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected || isHovered
                                  ? segment.color.withValues(alpha: 0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 16 : 12,
                                height: isSelected ? 16 : 12,
                                decoration: BoxDecoration(
                                  color: segment.color,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: segment.color.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      segment.label,
                                      style: AppTextStyles.caption.copyWith(
                                        color: isSelected || isHovered
                                            ? segment.color
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected || isHovered
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${segment.value}',
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected || isHovered
                                                ? segment.color
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${(segment.percentage * 100).toInt()}%)',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.stats.total.toString(),
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        Text(
          'Total',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedInfo(_ChartSegment segment) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(segment.percentage * 100).toInt()}%',
              style: AppTextStyles.headline.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: segment.color,
              ),
            ),
            Text(
              segment.label,
              style: AppTextStyles.caption.copyWith(
                color: segment.color.withValues(alpha: 0.8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
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
          Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.default_),
              Expanded(
                child: Column(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.shimmerBase,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.shimmerBase,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.shimmerBase,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

