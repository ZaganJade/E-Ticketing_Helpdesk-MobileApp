import 'package:flutter/material.dart';
import '../../core/theme/shadcn_theme.dart';
import 'app_navbar.dart';

/// App Scaffold - Redesigned with shadcn_ui styling
/// Main scaffold with bottom navigation following AGENTS.md guidelines
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final NavTab? currentTab;
  final ValueChanged<NavTab>? onTabChanged;
  final int? notificationCount;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool useFloatingNavbar;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.currentTab,
    this.onTabChanged,
    this.notificationCount,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.useFloatingNavbar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody || useFloatingNavbar,
      backgroundColor: backgroundColor ??
          (isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background),
      bottomNavigationBar: currentTab != null && onTabChanged != null
          ? useFloatingNavbar
              ? AppFloatingNavbar(
                  currentTab: currentTab!,
                  onTabChanged: onTabChanged!,
                  notificationCount: notificationCount ?? 0,
                )
              : AppNavbar(
                  currentTab: currentTab!,
                  onTabChanged: onTabChanged!,
                  notificationCount: notificationCount ?? 0,
                )
          : null,
    );
  }
}

/// Simple Scaffold - Scaffold without bottom navigation
class SimpleScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const SimpleScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor ??
          (isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background),
    );
  }
}
