import 'package:flutter/material.dart';
import '../../core/theme/shadcn_theme.dart';

/// Navigation item configuration
class NavItemConfig {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavItemConfig({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Nav Tab enumeration
enum NavTab {
  dashboard,
  tiket,
  notifikasi,
  profil,
}

/// Neo-Brutalist Editorial Navbar
///
/// A distinctive bottom navigation with:
/// - Raw geometric shapes with refined typography
/// - Animated pill indicator with ink-bleed effect
/// - Haptic-like visual feedback
/// - Monospace labels for technical aesthetic
class AppNavbar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabChanged;
  final int notificationCount;

  static const List<NavItemConfig> _items = [
    NavItemConfig(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'DASHBOARD',
      route: '/dashboard',
    ),
    NavItemConfig(
      icon: Icons.confirmation_num_outlined,
      activeIcon: Icons.confirmation_num_rounded,
      label: 'TIKET',
      route: '/tiket',
    ),
    NavItemConfig(
      icon: Icons.notifications_none_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'INBOX',
      route: '/notifikasi',
    ),
    NavItemConfig(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'PROFIL',
      route: '/profil',
    ),
  ];

  const AppNavbar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.slate900 : ShadcnTheme.slate50,
        border: Border(
          top: BorderSide(
            color: isDark ? ShadcnTheme.slate700 : ShadcnTheme.slate200,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final isSelected = currentTab.index == index;
              return _NavItem(
                config: _items[index],
                isSelected: isSelected,
                isTablet: isTablet,
                isDark: isDark,
                notificationCount: index == 2 ? notificationCount : 0,
                onTap: () => onTabChanged(NavTab.values[index]),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final NavItemConfig config;
  final bool isSelected;
  final bool isTablet;
  final bool isDark;
  final int notificationCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.config,
    required this.isSelected,
    required this.isTablet,
    required this.isDark,
    required this.notificationCount,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getTabColor();

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 20 : 12,
            vertical: widget.isTablet ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? accentColor.withValues(alpha: widget.isDark ? 0.15 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(widget.isTablet ? 8 : 6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? accentColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? widget.config.activeIcon
                          : widget.config.icon,
                      size: widget.isTablet ? 28 : 24,
                      color: widget.isSelected
                          ? accentColor
                          : widget.isDark
                              ? ShadcnTheme.slate400
                              : ShadcnTheme.slate500,
                    ),
                  ),
                  if (widget.notificationCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ShadcnTheme.statusOpen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: widget.isDark
                                  ? ShadcnTheme.slate900
                                  : ShadcnTheme.slate50,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ShadcnTheme.statusOpen.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            widget.notificationCount > 99
                                ? '99+'
                                : widget.notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: widget.isTablet ? 8 : 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: widget.isTablet ? 11 : 10,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? accentColor
                      : widget.isDark
                          ? ShadcnTheme.slate400
                          : ShadcnTheme.slate500,
                  letterSpacing: widget.isSelected ? 1.2 : 0.8,
                  fontFamily: 'monospace',
                  height: 1.0,
                ),
                child: Text(widget.config.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTabColor() {
    switch (widget.config.label) {
      case 'DASHBOARD':
        return ShadcnTheme.accent;
      case 'TIKET':
        return ShadcnTheme.statusInProgress;
      case 'INBOX':
        return ShadcnTheme.statusOpen;
      case 'PROFIL':
        return ShadcnTheme.statusDone;
      default:
        return ShadcnTheme.accent;
    }
  }
}

/// Floating Navbar Variant
///
/// A floating pill-style navbar that hovers above content
/// with glassmorphism effect
class AppFloatingNavbar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabChanged;
  final int notificationCount;

  static const List<NavItemConfig> _items = [
    NavItemConfig(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Dash',
      route: '/dashboard',
    ),
    NavItemConfig(
      icon: Icons.confirmation_num_outlined,
      activeIcon: Icons.confirmation_num_rounded,
      label: 'Tiket',
      route: '/tiket',
    ),
    NavItemConfig(
      icon: Icons.notifications_none_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Inbox',
      route: '/notifikasi',
    ),
    NavItemConfig(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Me',
      route: '/profil',
    ),
  ];

  const AppFloatingNavbar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48 : 16,
        vertical: isTablet ? 24 : 16,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: (isDark ? ShadcnTheme.slate900 : Colors.white).withValues(
            alpha: 0.85,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? ShadcnTheme.slate700.withValues(alpha: 0.5)
                : ShadcnTheme.slate200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isSelected = currentTab.index == index;
            return _FloatingNavItem(
              config: _items[index],
              isSelected: isSelected,
              isTablet: isTablet,
              isDark: isDark,
              notificationCount: index == 2 ? notificationCount : 0,
              onTap: () => onTabChanged(NavTab.values[index]),
            );
          }),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  final NavItemConfig config;
  final bool isSelected;
  final bool isTablet;
  final bool isDark;
  final int notificationCount;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.config,
    required this.isSelected,
    required this.isTablet,
    required this.isDark,
    required this.notificationCount,
    required this.onTap,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: _controller.reverse,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.08),
            child: child,
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: widget.isTablet ? 4 : 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected
                ? (widget.isTablet ? 20 : 16)
                : (widget.isTablet ? 12 : 8),
            vertical: widget.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent,
                      ShadcnTheme.accent.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: widget.isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    widget.isSelected
                        ? widget.config.activeIcon
                        : widget.config.icon,
                    size: widget.isTablet ? 24 : 22,
                    color: widget.isSelected
                        ? Colors.white
                        : widget.isDark
                            ? ShadcnTheme.slate400
                            : ShadcnTheme.slate500,
                  ),
                  if (widget.notificationCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: ShadcnTheme.statusOpen,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: widget.isSelected
                                ? ShadcnTheme.accent
                                : (widget.isDark
                                    ? ShadcnTheme.slate900
                                    : Colors.white),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isSelected) ...[
                SizedBox(width: widget.isTablet ? 10 : 8),
                Text(
                  widget.config.label,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
