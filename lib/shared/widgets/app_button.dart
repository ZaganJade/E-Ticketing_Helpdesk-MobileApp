import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// App Button - Redesigned to use shadcn_ui ShadButton
/// A wrapper around ShadButton with additional convenience constructors
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
    final shadSize = _getShadButtonSize();

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ShadButton(
          size: shadSize,
          onPressed: isLoading || isDisabled ? null : onPressed,
          child: _buildContent(),
        );
        break;
      case AppButtonVariant.secondary:
        button = ShadButton.secondary(
          size: shadSize,
          onPressed: isLoading || isDisabled ? null : onPressed,
          child: _buildContent(),
        );
        break;
      case AppButtonVariant.destructive:
        button = ShadButton.destructive(
          size: shadSize,
          onPressed: isLoading || isDisabled ? null : onPressed,
          child: _buildContent(),
        );
        break;
      case AppButtonVariant.outline:
        button = ShadButton.outline(
          size: shadSize,
          onPressed: isLoading || isDisabled ? null : onPressed,
          child: _buildContent(),
        );
        break;
      case AppButtonVariant.ghost:
        button = ShadButton.ghost(
          size: shadSize,
          onPressed: isLoading || isDisabled ? null : onPressed,
          child: _buildContent(),
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = Icon(icon, size: _getIconSize());
      final textWidget = Text(
        label,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconRight
            ? [textWidget, const SizedBox(width: 8), iconWidget]
            : [iconWidget, const SizedBox(width: 8), textWidget],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ShadButtonSize? _getShadButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return ShadButtonSize.sm;
      case AppButtonSize.medium:
        return null; // Default size
      case AppButtonSize.large:
        return ShadButtonSize.lg;
    }
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

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }
}

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

/// Icon Button - A simple icon button using shadcn_ui
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final shadSize = _getShadButtonSize();

    switch (variant) {
      case AppButtonVariant.primary:
        return ShadButton(
          size: shadSize,
          onPressed: onPressed,
          child: Icon(icon, size: _getIconSize()),
        );
      case AppButtonVariant.secondary:
        return ShadButton.secondary(
          size: shadSize,
          onPressed: onPressed,
          child: Icon(icon, size: _getIconSize()),
        );
      case AppButtonVariant.destructive:
        return ShadButton.destructive(
          size: shadSize,
          onPressed: onPressed,
          child: Icon(icon, size: _getIconSize()),
        );
      case AppButtonVariant.outline:
        return ShadButton.outline(
          size: shadSize,
          onPressed: onPressed,
          child: Icon(icon, size: _getIconSize()),
        );
      case AppButtonVariant.ghost:
        return ShadButton.ghost(
          size: shadSize,
          onPressed: onPressed,
          child: Icon(icon, size: _getIconSize()),
        );
    }
  }

  ShadButtonSize? _getShadButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return ShadButtonSize.sm;
      case AppButtonSize.medium:
        return null;
      case AppButtonSize.large:
        return ShadButtonSize.lg;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 22;
      case AppButtonSize.large:
        return 26;
    }
  }
}
