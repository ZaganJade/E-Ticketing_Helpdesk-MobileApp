import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

class UserStatsCard extends StatelessWidget {
  final int pengguna;
  final int helpdesk;
  final int admin;

  const UserStatsCard({
    super.key,
    required this.pengguna,
    required this.helpdesk,
    required this.admin,
  });

  int get total => pengguna + helpdesk + admin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent.withValues(alpha: 0.2),
                      ShadcnTheme.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Pengguna',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Total $total pengguna',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Pengguna',
                  count: pengguna,
                  color: ShadcnTheme.accent,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: _StatItem(
                  label: 'Helpdesk',
                  count: helpdesk,
                  color: ShadcnTheme.statusInProgress,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: _StatItem(
                  label: 'Admin',
                  count: admin,
                  color: ShadcnTheme.statusOpen,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isTablet;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
