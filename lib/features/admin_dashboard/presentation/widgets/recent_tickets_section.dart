import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../tiket/domain/entities/tiket.dart';

class RecentTicketsSection extends StatelessWidget {
  final List<Tiket> tiketList;
  final VoidCallback? onViewAll;
  final void Function(Tiket)? onTapTiket;
  final bool isLoading;

  const RecentTicketsSection({
    super.key,
    required this.tiketList,
    this.onViewAll,
    this.onTapTiket,
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
                  Icons.history_rounded,
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
                      'Tiket Terbaru',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${tiketList.length} tiket baru-baru ini',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
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
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.w500,
                          color: ShadcnTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: isTablet ? 16 : 14,
                        color: ShadcnTheme.accent,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          if (isLoading)
            _buildSkeletonList(isDark, isTablet)
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
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 32),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: isTablet ? 48 : 40,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Belum ada tiket',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            'Tiket baru akan muncul di sini',
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList(bool isDark, bool isTablet) {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTablet ? 180 : 140,
                    height: isTablet ? 16 : 14,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 12 : 10,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: isTablet ? 70 : 60,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          Text(
                            _formatDate(tiket.dibuatPada),
                            style: TextStyle(
                              fontSize: 11,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Text(
                        tiket.judul,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: ShadTheme.of(context).colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tiket.namaPembuat?.isNotEmpty == true)
                        Text(
                          'Oleh: ${tiket.namaPembuat}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
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
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}h lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru';
  }
}
