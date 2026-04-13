import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Modern section for tickets assigned to current helpdesk
class TiketSayaSection extends StatefulWidget {
  final List<Tiket> tiketList;
  final Function(Tiket)? onTapTiket;
  final bool isLoading;

  const TiketSayaSection({
    super.key,
    required this.tiketList,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  State<TiketSayaSection> createState() => _TiketSayaSectionState();
}

class _TiketSayaSectionState extends State<TiketSayaSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(TiketSayaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading &&
        widget.tiketList.isNotEmpty &&
        oldWidget.tiketList != widget.tiketList) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.tiketList.isEmpty && !widget.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.statusDiproses.withValues(alpha: 0.2),
                          AppColors.statusDiproses.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.assignment_ind_rounded,
                      color: AppColors.statusDiproses,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tiket Saya',
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (widget.tiketList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.statusDiproses.withValues(alpha: 0.15),
                        AppColors.statusDiproses.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.statusDiproses.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${widget.tiketList.length} tiket',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.statusDiproses,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.default_),
          if (widget.isLoading)
            _buildSkeletonList()
          else
            _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(
        widget.tiketList.take(5).length,
        (index) {
          final tiket = widget.tiketList[index];
          final animation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                0.6 + index * 0.1,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animation.value)),
                  child: child,
                ),
              );
            },
            child: _TiketSayaCard(
              tiket: tiket,
              onTap: widget.onTapTiket != null
                  ? () => widget.onTapTiket!(tiket)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.default_),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.cardRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppBorderRadius.badgeRadius,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Modern ticket card with status-based design
class _TiketSayaCard extends StatefulWidget {
  final Tiket tiket;
  final VoidCallback? onTap;

  const _TiketSayaCard({
    required this.tiket,
    this.onTap,
  });

  @override
  State<_TiketSayaCard> createState() => _TiketSayaCardState();
}

class _TiketSayaCardState extends State<_TiketSayaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.tiket.status) {
      case StatusTiket.terbuka:
        return AppColors.statusTerbuka;
      case StatusTiket.diproses:
        return AppColors.statusDiproses;
      case StatusTiket.selesai:
        return AppColors.statusSelesai;
      default:
        return AppColors.textSecondary;
    }
  }

  void _onTapDown(_) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [
                          AppColors.darkSurface.withValues(alpha: 0.8),
                          AppColors.darkSurface.withValues(alpha: 0.5),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: AppBorderRadius.cardRadius,
                border: Border.all(
                  color: _isPressed
                      ? statusColor.withValues(alpha: 0.5)
                      : statusColor.withValues(alpha: 0.2),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: AppBorderRadius.cardRadius,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Status accent bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isPressed ? 6 : 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              statusColor,
                              statusColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.default_),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusBadgeFromString(
                                    status: widget.tiket.status.name,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textMuted.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(widget.tiket.dibuatPada),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                widget.tiket.judul,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.tiket.namaPembuat != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pembuat: ${widget.tiket.namaPembuat}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}h lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}j lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m lalu';
    } else {
      return 'Baru';
    }
  }
}
