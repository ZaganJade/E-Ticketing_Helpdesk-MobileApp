import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: title != null
          ? Text(title!, style: AppTextStyles.headline)
          : null,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.darkBackground : AppColors.background),
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      leading: leading,
      actions: actions,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

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
          (isDark ? AppColors.darkBackground : AppColors.background),
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      automaticallyImplyLeading: onBack != null,
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller!.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;

  const AppTabAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(title, style: AppTextStyles.headline),
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.darkBackground : AppColors.background),
      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: TabBar(
        tabs: tabs,
        labelStyle: AppTextStyles.label,
        unselectedLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
        ),
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}
