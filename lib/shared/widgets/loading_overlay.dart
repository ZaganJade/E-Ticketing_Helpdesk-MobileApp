import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../core/theme/app_text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final bool dismissible;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
    this.dismissible = false,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          GestureDetector(
            onTap: dismissible ? () {} : null,
            child: Container(
              color: (backgroundColor ?? AppColors.overlay).withOpacity(0.5),
              child: Center(
                child: _LoadingIndicator(
                  message: message,
                  indicatorColor: indicatorColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? indicatorColor;

  const _LoadingIndicator({
    this.message,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              indicatorColor ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.default_),
            Text(
              message!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const FullScreenLoading({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: Center(
        child: _LoadingIndicator(
          message: message,
          indicatorColor: indicatorColor,
        ),
      ),
    );
  }
}

class InlineLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const InlineLoading({
    super.key,
    this.message,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            message!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
