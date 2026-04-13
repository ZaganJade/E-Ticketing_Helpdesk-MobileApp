import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum NavTab {
  dashboard,
  tiket,
  notifikasi,
  profil,
}

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
      extendBody: extendBody,
      bottomNavigationBar: currentTab != null && onTabChanged != null
          ? _BottomNavBar(
              currentTab: currentTab!,
              onTabChanged: onTabChanged!,
              notificationCount: notificationCount ?? 0,
              isDark: isDark,
            )
          : null,
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabChanged;
  final int notificationCount;
  final bool isDark;

  const _BottomNavBar({
    required this.currentTab,
    required this.onTabChanged,
    required this.notificationCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.primary;
    final unselectedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                isSelected: currentTab == NavTab.dashboard,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => onTabChanged(NavTab.dashboard),
              ),
              _NavItem(
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number,
                label: 'Tiket',
                isSelected: currentTab == NavTab.tiket,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => onTabChanged(NavTab.tiket),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Notifikasi',
                isSelected: currentTab == NavTab.notifikasi,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => onTabChanged(NavTab.notifikasi),
                badge: notificationCount > 0 ? notificationCount : null,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                isSelected: currentTab == NavTab.profil,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => onTabChanged(NavTab.profil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.buttonRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.default_,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                if (badge != null)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge! > 99 ? '99+' : badge!.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
