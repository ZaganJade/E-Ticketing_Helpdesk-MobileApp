import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';

/// Modern greeting section with glassmorphism effect - Fully Responsive
class GreetingSection extends StatelessWidget {
  final String greeting;
  final Pengguna? user;
  final bool isLoading;

  const GreetingSection({
    super.key,
    required this.greeting,
    this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isLargePhone = size.width >= 400;

    // Responsive padding based on screen size
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final topPadding = isTablet ? 16.0 : 8.0;
    final cardPadding = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 8),
      child: ShadCard(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Responsive avatar
                _buildAvatar(isDark, isTablet),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13,
                          fontWeight: FontWeight.w500,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isLoading)
                        Container(
                          width: isTablet ? 160 : 120,
                          height: isTablet ? 28 : 24,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      else
                        Text(
                          user?.nama ?? 'Pengguna',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : (isLargePhone ? 22 : 20),
                            fontWeight: FontWeight.w700,
                            color: ShadTheme.of(context).colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (user != null) _buildRoleBadge(context, user!.peran),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            // Subtle divider with gradient
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ShadTheme.of(context).colorScheme.border.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            // Quick status line
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: isTablet ? 16 : 14,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    user?.peran == Peran.admin
                        ? 'Akses Administrator Penuh'
                        : user?.peran == Peran.helpdesk
                            ? 'Akses Helpdesk'
                            : 'Akses Pengguna',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => context.push('/profil'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          color: ShadcnTheme.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: isTablet ? 14 : 12,
                        color: ShadcnTheme.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isTablet) {
    final size = isTablet ? 60.0 : 52.0;
    final initials = _getInitials(user?.nama ?? '');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnTheme.accent.withValues(alpha: 0.8),
            ShadcnTheme.accent.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        boxShadow: [
          BoxShadow(
            color: ShadcnTheme.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, Peran peran) {
    final (label, color) = switch (peran) {
      Peran.admin => ('Admin', ShadcnTheme.destructive),
      Peran.helpdesk => ('Helpdesk', ShadcnTheme.accent),
      Peran.pengguna => ('Klien', ShadcnTheme.statusDone),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// Skeleton loading for greeting section - Fully Responsive
class GreetingSectionSkeleton extends StatelessWidget {
  final bool isDark;
  const GreetingSectionSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final topPadding = isTablet ? 16.0 : 8.0;
    final avatarSize = isTablet ? 60.0 : 52.0;

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 8),
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: isTablet ? 180 : 140,
                    height: isTablet ? 28 : 24,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
