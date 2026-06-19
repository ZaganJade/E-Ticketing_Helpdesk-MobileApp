import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

/// 3-column animated status analytics cards with summary footer
/// Hero widget for the helpdesk dashboard
class HelpdeskStatusOverview extends StatelessWidget {
  final int perluDitangani;
  final int diproses;
  final int selesai;
  final int totalDitangani;
  final double rataRataWaktu;
  final bool isLoading;

  const HelpdeskStatusOverview({
    super.key,
    required this.perluDitangani,
    required this.diproses,
    required this.selesai,
    required this.totalDitangani,
    required this.rataRataWaktu,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (isLoading) {
      return HelpdeskStatusOverviewSkeleton(isDark: isDark, isTablet: isTablet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
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
                Icons.analytics_rounded,
                color: ShadcnTheme.accent,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Text(
              'Status Tiket',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        // 3 Status Cards
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 500) {
              // Tablet: Grid layout
              return Row(
                children: [
                  Expanded(
                    child: _AnimatedStatCard(
                      label: 'Sedang Dikerjakan',
                      count: perluDitangani,
                      icon: Icons.sync_rounded,
                      color: ShadcnTheme.statusInProgress,
                      showPulse: perluDitangani > 0,
                      delayMs: 0,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnimatedStatCard(
                      label: 'Selesai',
                      count: diproses,
                      icon: Icons.check_circle_rounded,
                      color: ShadcnTheme.statusDone,
                      delayMs: 100,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnimatedStatCard(
                      label: 'Total Ditangani',
                      count: selesai,
                      icon: Icons.analytics_rounded,
                      color: ShadcnTheme.accent,
                      delayMs: 200,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              );
            }

            // Phone: Horizontal scroll
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AnimatedStatCard(
                    label: 'Sedang Dikerjakan',
                    count: perluDitangani,
                    icon: Icons.sync_rounded,
                    color: ShadcnTheme.statusInProgress,
                    showPulse: perluDitangani > 0,
                    delayMs: 0,
                    isTablet: false,
                    fixedWidth: constraints.maxWidth * 0.38,
                  ),
                  const SizedBox(width: 10),
                  _AnimatedStatCard(
                    label: 'Selesai',
                    count: diproses,
                    icon: Icons.check_circle_rounded,
                    color: ShadcnTheme.statusDone,
                    delayMs: 100,
                    isTablet: false,
                    fixedWidth: constraints.maxWidth * 0.38,
                  ),
                  const SizedBox(width: 10),
                  _AnimatedStatCard(
                    label: 'Total Ditangani',
                    count: selesai,
                    icon: Icons.analytics_rounded,
                    color: ShadcnTheme.accent,
                    delayMs: 200,
                    isTablet: false,
                    fixedWidth: constraints.maxWidth * 0.38,
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: isTablet ? 12 : 10),
        // Summary footer bar
        _SummaryBar(
          totalDitangani: totalDitangani,
          rataRataWaktu: rataRataWaktu,
          isTablet: isTablet,
        ),
      ],
    );
  }
}

/// Individual animated stat card with gradient top bar
class _AnimatedStatCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool showPulse;
  final int delayMs;
  final bool isTablet;
  final double? fixedWidth;

  const _AnimatedStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.showPulse = false,
    required this.delayMs,
    required this.isTablet,
    this.fixedWidth,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
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
      begin: const Offset(0, 0.15),
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
                // Top gradient accent bar
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
                  padding: EdgeInsets.all(widget.isTablet ? 16 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon row with optional pulse
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(widget.isTablet ? 10 : 8),
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
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: widget.isTablet ? 20 : 18,
                            ),
                          ),
                          if (widget.showPulse) ...[
                            const Spacer(),
                            _PulseIndicator(color: widget.color),
                          ],
                        ],
                      ),
                      SizedBox(height: widget.isTablet ? 14 : 12),
                      // Animated counter
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.count),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 30 : 26,
                              fontWeight: FontWeight.w800,
                              color: ShadTheme.of(context)
                                  .colorScheme
                                  .foreground,
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
                          fontSize: widget.isTablet ? 13 : 12,
                          fontWeight: FontWeight.w500,
                          color: ShadTheme.of(context)
                              .colorScheme
                              .mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

/// Pulsing dot indicator for urgent items
class _PulseIndicator extends StatefulWidget {
  final Color color;

  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(
              alpha: 0.5 + (_controller.value * 0.5),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: 0.3 * _controller.value,
                ),
                blurRadius: 8,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Summary bar showing total handled + avg time
class _SummaryBar extends StatelessWidget {
  final int totalDitangani;
  final double rataRataWaktu;
  final bool isTablet;

  const _SummaryBar({
    required this.totalDitangani,
    required this.rataRataWaktu,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 14,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnTheme.accent.withValues(alpha: 0.12),
            ShadcnTheme.accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ShadcnTheme.accent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Total Ditangani
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: isTablet ? 18 : 16,
                  color: ShadcnTheme.accent,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Ditangani',
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? ShadcnTheme.darkMutedForeground
                              : ShadcnTheme.mutedForeground,
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: totalDitangani),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Text(
                            '$value tiket',
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 13,
                              fontWeight: FontWeight.w700,
                              color: ShadcnTheme.accent,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: isTablet ? 32 : 28,
            width: 1,
            color: ShadcnTheme.accent.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 12),
          // Avg time
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: isTablet ? 18 : 16,
                  color: ShadcnTheme.accent,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rata-rata Selesai',
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? ShadcnTheme.darkMutedForeground
                              : ShadcnTheme.mutedForeground,
                        ),
                      ),
                      Text(
                        '${rataRataWaktu.toStringAsFixed(1)} jam',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13,
                          fontWeight: FontWeight.w700,
                          color: ShadcnTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading for status overview
class HelpdeskStatusOverviewSkeleton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const HelpdeskStatusOverviewSkeleton({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
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
              width: isTablet ? 120 : 100,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        // Cards skeleton
        Row(
          children: List.generate(3, (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 2 ? 10 : 0,
                left: index > 0 ? 0 : 0,
              ),
              height: isTablet ? 140 : 130,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                ),
              ),
            ),
          )),
        ),
        SizedBox(height: isTablet ? 12 : 10),
        // Summary bar skeleton
        Container(
          height: isTablet ? 56 : 48,
          decoration: BoxDecoration(
            color: isDark
                ? ShadcnTheme.darkBorder.withValues(alpha: 0.3)
                : ShadcnTheme.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
