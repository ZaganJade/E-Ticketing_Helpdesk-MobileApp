import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../../core/services/date_service.dart';
import '../../../tiket/domain/entities/tiket.dart';
import 'lightweight_card.dart';
import 'responsive_layout.dart';

/// Recent Tickets with modern, consistent design - Fully Responsive
class TiketRecentList extends StatelessWidget {
  final List<Tiket> tiketList;
  final VoidCallback? onViewAll;
  final void Function(Tiket)? onTapTiket;
  final bool isLoading;

  const TiketRecentList({
    super.key,
    required this.tiketList,
    this.onViewAll,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = ResponsiveLayout.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: LightweightCard(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(responsive.isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShadcnTheme.accent.withValues(alpha: 0.2),
                            ShadcnTheme.accent.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: ShadcnTheme.accent,
                        size: responsive.isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: responsive.isTablet ? 16 : 12),
                    Text(
                      'Tiket Terbaru',
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (onViewAll != null && !isLoading)
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: responsive.isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: ShadcnTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: responsive.isTablet ? 16 : 14,
                          color: ShadcnTheme.accent,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: responsive.isTablet ? 8 : 4),
            Text(
              '${tiketList.length} tiket baru-baru ini',
              style: TextStyle(
                fontSize: responsive.isTablet ? 14 : 13,
                fontWeight: FontWeight.w400,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            SizedBox(height: responsive.isTablet ? 20 : 16),
            // Content
            if (isLoading)
              _buildSkeletonList(context, isDark, responsive)
            else if (tiketList.isEmpty)
              _buildEmptyState(context, isDark, responsive)
            else
              Column(
                children: tiketList.take(5).map((tiket) => _TicketCard(
                  tiket: tiket,
                  onTap: onTapTiket != null ? () => onTapTiket!(tiket) : null,
                  responsive: responsive,
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, ResponsiveLayout responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.isTablet ? 40 : 32),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: responsive.isTablet ? 56 : 48,
              color: isDark ? ShadcnTheme.darkMutedForeground : ShadcnTheme.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tiket',
              style: TextStyle(
                fontSize: responsive.isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Buat tiket baru untuk memulai',
              style: TextStyle(
                fontSize: responsive.isTablet ? 14 : 12,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList(BuildContext context, bool isDark, ResponsiveLayout responsive) {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(responsive.isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: responsive.isTablet ? 48 : 40,
              height: responsive.isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: responsive.isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: responsive.isTablet ? 180 : 150,
                    height: responsive.isTablet ? 18 : 16,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: responsive.isTablet ? 120 : 100,
                    height: responsive.isTablet ? 14 : 12,
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
      )),
    );
  }
}

/// Individual ticket card - Responsive
class _TicketCard extends StatelessWidget {
  final Tiket tiket;
  final void Function()? onTap;
  final ResponsiveLayout responsive;

  const _TicketCard({
    required this.tiket,
    this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                height: responsive.isTablet ? 80 : 70,
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
                  padding: EdgeInsets.all(responsive.isTablet ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(), size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  tiket.status.displayName,
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
                          // Date
                          Text(
                            _formatDate(tiket.dibuatPada),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.isTablet ? 10 : 8),
                      // Title
                      Text(
                        tiket.judul,
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 15 : 14,
                          fontWeight: FontWeight.w600,
                          color: ShadTheme.of(context).colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Color _getStatusColor() {
    return switch (tiket.status) {
      StatusTiket.terbuka => ShadcnTheme.statusOpen,
      StatusTiket.diproses => ShadcnTheme.statusInProgress,
      StatusTiket.selesai => ShadcnTheme.statusDone,
    };
  }

  IconData _getStatusIcon() {
    return switch (tiket.status) {
      StatusTiket.terbuka => Icons.radio_button_unchecked_rounded,
      StatusTiket.diproses => Icons.sync_rounded,
      StatusTiket.selesai => Icons.check_circle_rounded,
    };
  }

  String _formatDate(DateTime date) {
    return date.toRelativeTime();
  }
}

/// Skeleton loading state - Responsive
class TiketRecentListSkeleton extends StatelessWidget {
  final bool isDark;
  const TiketRecentListSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: LightweightCard(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: responsive.isTablet ? 44 : 40,
                  height: responsive.isTablet ? 44 : 40,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: responsive.isTablet ? 140 : 120,
                  height: responsive.isTablet ? 28 : 24,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: responsive.isTablet ? 100 : 80,
                  height: responsive.isTablet ? 32 : 28,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.isTablet ? 20 : 16),
            ...List.generate(3, (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(responsive.isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: responsive.isTablet ? 48 : 40,
                    height: responsive.isTablet ? 48 : 40,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: responsive.isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: responsive.isTablet ? 180 : 150,
                          height: responsive.isTablet ? 18 : 16,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: responsive.isTablet ? 120 : 100,
                          height: responsive.isTablet ? 14 : 12,
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
            )),
          ],
        ),
      ),
    );
  }
}
