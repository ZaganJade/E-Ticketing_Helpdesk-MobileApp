import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';

/// Lightweight card optimized for dashboard performance
/// Replaces ShadCard which has complex rendering overhead
class LightweightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool useBorder;

  const LightweightCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.useBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.getCardBackground(context);

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorderRadius.cardRadius,
        border: useBorder
            ? Border.all(
                color: AppColors.getBorder(context),
                width: 1,
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: AppBorderRadius.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.cardRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}
