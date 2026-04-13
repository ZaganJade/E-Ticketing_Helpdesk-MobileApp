import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  ghost,
  outline,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool iconRight;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconRight = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: _getButtonStyle(context, isDark),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: _getTextStyle(),
    );

    if (icon != null) {
      final iconWidget = Icon(icon, size: _getIconSize());

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconRight
            ? [textWidget, const SizedBox(width: 8), iconWidget]
            : [iconWidget, const SizedBox(width: 8), textWidget],
      );
    }

    return textWidget;
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    final (backgroundColor, foregroundColor, borderColor) = _getColors(isDark);

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor.withOpacity(0.5),
      disabledForegroundColor: foregroundColor.withOpacity(0.5),
      elevation: variant == AppButtonVariant.ghost ? 0 : null,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.buttonRadius,
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
    );
  }

  (Color, Color, Color?) _getColors(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return (AppColors.primary, AppColors.white, null);
      case AppButtonVariant.secondary:
        return (AppColors.secondary, AppColors.white, null);
      case AppButtonVariant.destructive:
        return (AppColors.error, AppColors.white, null);
      case AppButtonVariant.ghost:
        return (
          Colors.transparent,
          isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          null
        );
      case AppButtonVariant.outline:
        return (
          Colors.transparent,
          AppColors.primary,
          AppColors.primary,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.default_,
        );
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == AppButtonSize.small
        ? AppTextStyles.buttonSmall
        : AppTextStyles.button;

    return baseStyle;
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}
