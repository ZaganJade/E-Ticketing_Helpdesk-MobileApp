import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tiket_status_stats.dart';

/// Animated counter widget for numbers
class _AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle style;

  const _AnimatedCounter({
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
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
      builder: (context, child) {
        return Text(
          _animation.value.toString(),
          style: widget.style,
        );
      },
    );
  }
}

/// Main stat card with glassmorphism effect and animations
class StatCard extends StatefulWidget {
  final int total;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.total,
    this.isLoading = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A5F).withValues(alpha: 0.9),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                ]
              : [
                  const Color(0xFF3B82F6).withValues(alpha: 0.95),
                  const Color(0xFF1D4ED8).withValues(alpha: 0.98),
                ],
        ),
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: widget.isLoading
          ? _buildSkeleton()
          : Row(
              children: [
                // Animated icon container
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1 + (_pulseController.value * 0.1)),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.confirmation_number_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Tiket',
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _AnimatedCounter(
                        value: widget.total,
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mini stat card with interactive hover effect
class MiniStatCard extends StatefulWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isLoading;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.isLoading = false,
  });

  @override
  State<MiniStatCard> createState() => _MiniStatCardState();
}

class _MiniStatCardState extends State<MiniStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onHover(true),
        onTapUp: (_) => _onHover(false),
        onTapCancel: () => _onHover(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.default_),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [
                            widget.color.withValues(alpha: isDark ? 0.25 : 0.15),
                            widget.color.withValues(alpha: isDark ? 0.15 : 0.08),
                          ]
                        : [
                            widget.color.withValues(alpha: isDark ? 0.15 : 0.1),
                            widget.color.withValues(alpha: isDark ? 0.08 : 0.05),
                          ],
                  ),
                  borderRadius: AppBorderRadius.cardRadius,
                  border: Border.all(
                    color: _isHovered
                        ? widget.color.withValues(alpha: 0.5)
                        : widget.color.withValues(alpha: 0.3),
                    width: _isHovered ? 1.5 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: widget.isLoading ? _buildSkeleton() : _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.2)
                    : widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.caption.copyWith(
                  color: _isHovered ? widget.color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _AnimatedCounter(
          value: widget.count,
          style: AppTextStyles.headlineSmall.copyWith(
            color: widget.color,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          duration: const Duration(milliseconds: 800),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 50,
          height: 32,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Row of mini stat cards for status breakdown
class StatusStatsRow extends StatelessWidget {
  final TiketStatusStats stats;
  final bool isLoading;

  const StatusStatsRow({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            label: 'Terbuka',
            count: stats.terbuka,
            color: AppColors.statusTerbuka,
            icon: Icons.pending_actions_rounded,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.default_),
        Expanded(
          child: MiniStatCard(
            label: 'Diproses',
            count: stats.diproses,
            color: AppColors.statusDiproses,
            icon: Icons.sync_rounded,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.default_),
        Expanded(
          child: MiniStatCard(
            label: 'Selesai',
            count: stats.selesai,
            color: AppColors.statusSelesai,
            icon: Icons.check_circle_rounded,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
