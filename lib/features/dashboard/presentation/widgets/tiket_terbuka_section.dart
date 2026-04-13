import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Modern section for open tickets that need to be handled (helpdesk only)
class TiketTerbukaSection extends StatefulWidget {
  final List<Tiket> tiketList;
  final Function(String)? onAmbilTiket;
  final bool isLoading;

  const TiketTerbukaSection({
    super.key,
    required this.tiketList,
    this.onAmbilTiket,
    this.isLoading = false,
  });

  @override
  State<TiketTerbukaSection> createState() => _TiketTerbukaSectionState();
}

class _TiketTerbukaSectionState extends State<TiketTerbukaSection>
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
  void didUpdateWidget(TiketTerbukaSection oldWidget) {
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
                          AppColors.statusTerbuka.withValues(alpha: 0.2),
                          AppColors.statusTerbuka.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inbox_rounded,
                      color: AppColors.statusTerbuka,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tiket Terbuka',
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
                        AppColors.statusTerbuka.withValues(alpha: 0.15),
                        AppColors.statusTerbuka.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.statusTerbuka.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${widget.tiketList.length} tiket',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.statusTerbuka,
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
            child: _TiketTerbukaCard(
              tiket: tiket,
              onAmbil: widget.onAmbilTiket != null
                  ? () => widget.onAmbilTiket!(tiket.id)
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
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppBorderRadius.buttonRadius,
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

/// Modern ticket card with action button
class _TiketTerbukaCard extends StatefulWidget {
  final Tiket tiket;
  final VoidCallback? onAmbil;

  const _TiketTerbukaCard({
    required this.tiket,
    this.onAmbil,
  });

  @override
  State<_TiketTerbukaCard> createState() => _TiketTerbukaCardState();
}

class _TiketTerbukaCardState extends State<_TiketTerbukaCard>
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
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
                    ? AppColors.statusTerbuka.withValues(alpha: 0.5)
                    : AppColors.statusTerbuka.withValues(alpha: 0.2),
                width: _isPressed ? 2 : 1,
              ),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: AppColors.statusTerbuka.withValues(alpha: 0.15),
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
                            AppColors.statusTerbuka,
                            AppColors.statusTerbuka.withValues(alpha: 0.7),
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
                                // Modern action button
                                GestureDetector(
                                  onTapDown: (_) {
                                    HapticFeedback.mediumImpact();
                                  },
                                  onTap: widget.onAmbil,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF2563EB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_task_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Ambil',
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
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
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Dibuat: ${_formatDate(widget.tiket.dibuatPada)}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
