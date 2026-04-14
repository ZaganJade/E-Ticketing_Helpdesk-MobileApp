import 'package:flutter/material.dart';

/// Centralized responsive layout that provides sizing info
/// without requiring MediaQuery.of in child widgets
class ResponsiveLayout extends InheritedWidget {
  final bool isTablet;
  final bool isSmallPhone;
  final double horizontalPadding;
  final EdgeInsets cardPadding;
  final double avatarSize;

  const ResponsiveLayout({
    super.key,
    required super.child,
    required this.isTablet,
    required this.isSmallPhone,
    required this.horizontalPadding,
    required this.cardPadding,
    required this.avatarSize,
  });

  static ResponsiveLayout of(BuildContext context) {
    final layout = context.dependOnInheritedWidgetOfExactType<ResponsiveLayout>();
    assert(layout != null, 'ResponsiveLayout not found in widget tree');
    return layout!;
  }

  @override
  bool updateShouldNotify(ResponsiveLayout oldWidget) {
    return isTablet != oldWidget.isTablet ||
        isSmallPhone != oldWidget.isSmallPhone ||
        horizontalPadding != oldWidget.horizontalPadding;
  }
}

/// Builder that provides responsive values
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayout layout) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isSmallPhone = size.width < 360;
    final isLargePhone = size.width >= 400;

    return ResponsiveLayout(
      isTablet: isTablet,
      isSmallPhone: isSmallPhone,
      horizontalPadding: isTablet ? 24.0 : 16.0,
      cardPadding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      avatarSize: isTablet ? 60.0 : 52.0,
      child: Builder(
        builder: (context) => builder(context, ResponsiveLayout.of(context)),
      ),
    );
  }
}
