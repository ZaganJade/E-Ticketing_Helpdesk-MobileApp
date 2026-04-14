import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../models/tiket_model.dart';

/// Tiket Card Widget - Redesigned with shadcn_ui
/// Displays ticket information in a list item card pattern
class TiketCard extends StatelessWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCard({
    super.key,
    required this.tiket,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return ShadcnTheme.statusOpen;
      case 'DIPROSES':
        return ShadcnTheme.statusInProgress;
      case 'SELESAI':
        return ShadcnTheme.statusDone;
      default:
        return ShadcnTheme.zinc500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return Icons.radio_button_unchecked_rounded;
      case 'DIPROSES':
        return Icons.sync_rounded;
      case 'SELESAI':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}b lalu';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}h lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}j lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m lalu';
    } else {
      return 'Baru';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(tiket.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusColor.withValues(alpha: 0.15),
                                  statusColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(tiket.status),
                                  size: 12,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tiket.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Time
                          Text(
                            _getRelativeTime(tiket.dibuatPada),
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w400,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      // Title
                      Text(
                        tiket.judul,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 15,
                          fontWeight: FontWeight.w600,
                          color: ShadTheme.of(context).colorScheme.foreground,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        tiket.deskripsi,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w400,
                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      // Footer with creator info
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isTablet ? 18 : 16,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tiket.pembuatNama ?? 'Unknown',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w500,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                          if (tiket.penanggungJawabNama != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: ShadcnTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.support_agent,
                              size: isTablet ? 18 : 16,
                              color: ShadcnTheme.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tiket.penanggungJawabNama!,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                                color: ShadcnTheme.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini Tiket Card - Compact version for tight spaces
class TiketCardMini extends StatelessWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCardMini({
    super.key,
    required this.tiket,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return ShadcnTheme.statusOpen;
      case 'DIPROSES':
        return ShadcnTheme.statusInProgress;
      case 'SELESAI':
        return ShadcnTheme.statusDone;
      default:
        return ShadcnTheme.zinc500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return Icons.radio_button_unchecked_rounded;
      case 'DIPROSES':
        return Icons.sync_rounded;
      case 'SELESAI':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(tiket.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tiket.judul,
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 14,
                                fontWeight: FontWeight.w600,
                                color: ShadTheme.of(context).colorScheme.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(tiket.status),
                                  size: 12,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tiket.statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                        size: isTablet ? 24 : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading for TiketCard
class TiketCardSkeleton extends StatelessWidget {
  const TiketCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar skeleton
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            // Content skeleton
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isTablet ? 80 : 70,
                          height: isTablet ? 24 : 22,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: isTablet ? 50 : 40,
                          height: isTablet ? 16 : 14,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Container(
                      width: double.infinity,
                      height: isTablet ? 20 : 18,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: isTablet ? 200 : 150,
                      height: isTablet ? 18 : 16,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Row(
                      children: [
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 16 : 14,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget for tiket
class TiketStatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const TiketStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return ShadcnTheme.statusOpen;
      case 'DIPROSES':
        return ShadcnTheme.statusInProgress;
      case 'SELESAI':
        return ShadcnTheme.statusDone;
      default:
        return ShadcnTheme.zinc500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return Icons.radio_button_unchecked_rounded;
      case 'DIPROSES':
        return Icons.sync_rounded;
      case 'SELESAI':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return 'Terbuka';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? (isTablet ? 12 : 10) : (isTablet ? 10 : 8),
        vertical: isLarge ? (isTablet ? 8 : 6) : (isTablet ? 6 : 4),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: isLarge ? (isTablet ? 16 : 14) : (isTablet ? 14 : 12),
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              fontSize: isLarge ? (isTablet ? 14 : 13) : (isTablet ? 12 : 11),
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
