import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';

class AdminGreetingSection extends StatelessWidget {
  final String greeting;
  final Pengguna? user;
  final bool isLoading;

  const AdminGreetingSection({
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

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEEF2FF),
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ShadcnTheme.accent.withValues(alpha: 0.3)
              : ShadcnTheme.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(isDark, isTablet),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? ShadcnTheme.accent.withValues(alpha: 0.8)
                        : ShadcnTheme.accent,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                if (isLoading)
                  Container(
                    width: isTablet ? 160 : 120,
                    height: isTablet ? 26 : 22,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                else
                  Text(
                    user?.nama ?? 'Admin',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: ShadTheme.of(context).colorScheme.foreground,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!isLoading) ...[
                  SizedBox(height: isTablet ? 4 : 2),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: isTablet ? 14 : 12,
                        color: isDark
                            ? ShadcnTheme.accent.withValues(alpha: 0.7)
                            : ShadcnTheme.accent.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Akses Administrator Penuh',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: isDark
                              ? ShadcnTheme.accent.withValues(alpha: 0.7)
                              : ShadcnTheme.accent.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ShadcnTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ShadcnTheme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: isTablet ? 14 : 12,
                    color: ShadcnTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 10,
                      fontWeight: FontWeight.w700,
                      color: ShadcnTheme.accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isTablet) {
    final initials = _getInitials(user?.nama ?? '');
    final size = isTablet ? 56.0 : 48.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnTheme.accent.withValues(alpha: 0.9),
            ShadcnTheme.accent.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ShadcnTheme.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: ShadcnTheme.statusDone,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'AD';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

class AdminGreetingSectionSkeleton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const AdminGreetingSectionSkeleton({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEEF2FF),
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ShadcnTheme.accent.withValues(alpha: 0.3)
              : ShadcnTheme.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 56 : 48,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: isTablet ? 16 : 14,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: isTablet ? 160 : 120,
                  height: isTablet ? 26 : 22,
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
    );
  }
}
