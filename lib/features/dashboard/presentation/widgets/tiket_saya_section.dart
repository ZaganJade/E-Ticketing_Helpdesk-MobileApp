import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Tiket Saya section with modern, consistent design - Fully Responsive
class TiketSayaSection extends StatelessWidget {
  final List<Tiket> tiketList;
  final void Function(Tiket)? onTapTiket;
  final bool isLoading;

  const TiketSayaSection({
    super.key,
    required this.tiketList,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    if (tiketList.isEmpty && !isLoading) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShadcnTheme.statusInProgress.withValues(alpha: 0.2),
                            ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_ind_rounded,
                        color: ShadcnTheme.statusInProgress,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Text(
                      'Tiket Saya',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (tiketList.isNotEmpty && !isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tiketList.length}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: ShadcnTheme.statusInProgress,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            // Content
            if (isLoading)
              _buildSkeletonList(context, isDark, isTablet)
            else if (tiketList.isEmpty)
              _buildEmptyState(context, isDark, isTablet)
            else
              Column(
                children: tiketList.take(5).map((tiket) => _TicketCard(
                  tiket: tiket,
                  onTap: onTapTiket != null ? () => onTapTiket!(tiket) : null,
                  isTablet: isTablet,
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 32),
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
              Icons.assignment_ind_outlined,
              size: isTablet ? 56 : 48,
              color: isDark ? ShadcnTheme.darkMutedForeground : ShadcnTheme.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tiket',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiket yang ditugaskan akan muncul di sini',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList(BuildContext context, bool isDark, bool isTablet) {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                          // Status badge skeleton
                          Container(
                            width: isTablet ? 90 : 80,
                            height: isTablet ? 28 : 24,
                            decoration: BoxDecoration(
                              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const Spacer(),
                          // Date skeleton
                          Container(
                            width: isTablet ? 70 : 60,
                            height: isTablet ? 16 : 14,
                            decoration: BoxDecoration(
                              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      // Title skeleton
                      Container(
                        width: double.infinity,
                        height: isTablet ? 20 : 18,
                        decoration: BoxDecoration(
                          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

/// Individual ticket card - Responsive
class _TicketCard extends StatelessWidget {
  final Tiket tiket;
  final void Function()? onTap;
  final bool isTablet;

  const _TicketCard({
    required this.tiket,
    this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

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
                      SizedBox(height: isTablet ? 10 : 8),
                      // Title
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
                      // Pembuat info if available
                      if (tiket.namaPembuat != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Oleh: ${tiket.namaPembuat}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
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
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}h lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru';
  }
}
