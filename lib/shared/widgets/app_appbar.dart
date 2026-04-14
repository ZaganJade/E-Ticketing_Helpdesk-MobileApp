import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// App AppBar - Redesigned with shadcn_ui styling
/// A reusable app bar component following AGENTS.md guidelines
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final bool showBorder;

  const AppAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            )
          : null,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ??
          (isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background),
      foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      leading: leading,
      actions: actions,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// App Search AppBar - Search-focused app bar with integrated search field
class AppSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const AppSearchAppBar({
    super.key,
    this.hint = 'Cari...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.onBack,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ??
          (isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background),
      foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      leading: onBack != null
          ? ShadButton.ghost(
              onPressed: onBack,
              child: const Icon(Icons.arrow_back),
            )
          : null,
      automaticallyImplyLeading: onBack != null,
      title: ShadInput(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        placeholder: Text(hint),
        leading: const Icon(Icons.search, size: 18),
        trailing: controller != null && controller!.text.isNotEmpty
            ? ShadButton.ghost(
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                },
                child: const Icon(Icons.clear, size: 18),
              )
            : null,
      ),
      actions: actions,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App Tab AppBar - App bar with integrated tab navigation
class AppTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> tabs;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final TabController? tabController;

  const AppTabAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 20 : 18,
          fontWeight: FontWeight.w600,
          color: ShadTheme.of(context).colorScheme.foreground,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor ??
          (isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background),
      foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      leading: showBackButton
          ? ShadButton.ghost(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        labelStyle: TextStyle(
          fontSize: isTablet ? 14 : 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isTablet ? 14 : 13,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: ShadcnTheme.accent,
        labelColor: ShadcnTheme.accent,
        unselectedLabelColor: ShadTheme.of(context).colorScheme.mutedForeground,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}

/// App Transparent AppBar - Transparent app bar for hero images
class AppTransparentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppTransparentAppBar({
    super.key,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
