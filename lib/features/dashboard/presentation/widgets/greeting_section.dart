import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';
import 'responsive_layout.dart';
import 'lightweight_card.dart';

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
    final responsive = ResponsiveLayout.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        responsive.isTablet ? 16.0 : 8.0,
        responsive.horizontalPadding,
        8,
      ),
      child: LightweightCard(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(isDark, responsive.avatarSize),
                SizedBox(width: responsive.isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 15 : 13,
                          fontWeight: FontWeight.w500,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isLoading)
                        Container(
                          width: responsive.isTablet ? 160 : 120,
                          height: responsive.isTablet ? 28 : 24,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      else
                        Text(
                          user?.nama ?? 'Pengguna',
                          style: TextStyle(
                            fontSize: responsive.isTablet ? 24 : 20,
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
            SizedBox(height: responsive.isTablet ? 20 : 16),
            // Subtle divider
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
            SizedBox(height: responsive.isTablet ? 16 : 12),
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: responsive.isTablet ? 16 : 14,
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
                      fontSize: responsive.isTablet ? 13 : 12,
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
                          fontSize: responsive.isTablet ? 13 : 12,
                          color: ShadcnTheme.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: responsive.isTablet ? 14 : 12,
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

  Widget _buildAvatar(bool isDark, double size) {
    final initials = _getInitials(user?.nama ?? '');
    final borderRadius = size >= 55 ? 16.0 : 14.0;

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
        borderRadius: BorderRadius.circular(borderRadius),
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
            fontSize: size * 0.35,
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
    final responsive = ResponsiveLayout.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        responsive.isTablet ? 16.0 : 8.0,
        responsive.horizontalPadding,
        8,
      ),
      child: LightweightCard(
        padding: responsive.cardPadding,
        child: Row(
          children: [
            Container(
              width: responsive.avatarSize,
              height: responsive.avatarSize,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(
                  responsive.avatarSize >= 55 ? 16 : 14,
                ),
              ),
            ),
            SizedBox(width: responsive.isTablet ? 20 : 16),
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
                    width: responsive.isTablet ? 180 : 140,
                    height: responsive.isTablet ? 28 : 24,
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
