import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Tab filter for helpdesk ticket monitoring (assigned tickets only)
enum _MonitoringTab {
  sedangDikerjakan,
  riwayatSaya;

  String get label => switch (this) {
        _MonitoringTab.sedangDikerjakan => 'Sedang Dikerjakan',
        _MonitoringTab.riwayatSaya => 'Riwayat Saya',
      };

  IconData get icon => switch (this) {
        _MonitoringTab.sedangDikerjakan => Icons.sync_rounded,
        _MonitoringTab.riwayatSaya => Icons.check_circle_rounded,
      };

  Color get color => switch (this) {
        _MonitoringTab.sedangDikerjakan => ShadcnTheme.statusInProgress,
        _MonitoringTab.riwayatSaya => ShadcnTheme.statusDone,
      };
}

/// Helpdesk ticket monitoring: active + completed history (no self-assign)
class HelpdeskTiketMonitoring extends StatefulWidget {
  final List<Tiket> tiketSaya;
  final List<Tiket> tiketSelesai;
  final Function(Tiket)? onTapTiket;
  final bool isLoading;

  const HelpdeskTiketMonitoring({
    super.key,
    required this.tiketSaya,
    required this.tiketSelesai,
    this.onTapTiket,
    this.isLoading = false,
  });

  @override
  State<HelpdeskTiketMonitoring> createState() =>
      _HelpdeskTiketMonitoringState();
}

class _HelpdeskTiketMonitoringState extends State<HelpdeskTiketMonitoring> {
  _MonitoringTab _activeTab = _MonitoringTab.sedangDikerjakan;

  List<Tiket> get _activeList => switch (_activeTab) {
        _MonitoringTab.sedangDikerjakan => widget.tiketSaya,
        _MonitoringTab.riwayatSaya => widget.tiketSelesai,
      };

  int _getCount(_MonitoringTab tab) => switch (tab) {
        _MonitoringTab.sedangDikerjakan => widget.tiketSaya.length,
        _MonitoringTab.riwayatSaya => widget.tiketSelesai.length,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return ShadCard(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
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
                  Icons.monitor_heart_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  'Pemantauan Tiket',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // Tab filter
          _buildTabBar(context, isDark, isTablet),
          SizedBox(height: isTablet ? 16 : 12),
          // Content
          if (widget.isLoading)
            _buildSkeleton(isDark, isTablet)
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _activeList.isEmpty
                  ? _buildEmptyState(context, isDark, isTablet)
                  : _buildTicketList(context, isDark, isTablet),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        children: _MonitoringTab.values.map((tab) {
          final isActive = _activeTab == tab;
          final count = _getCount(tab);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeTab = tab);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 10 : 8,
                  horizontal: isTablet ? 8 : 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? ShadcnTheme.darkCard : ShadcnTheme.card)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: tab.color.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    // Count
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive
                            ? tab.color
                            : ShadTheme.of(context)
                                .colorScheme
                                .mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Label
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 9,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? tab.color
                            : ShadTheme.of(context)
                                .colorScheme
                                .mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Active indicator bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: isActive ? (isTablet ? 28 : 24) : 0,
                      decoration: BoxDecoration(
                        color: tab.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context, bool isDark, bool isTablet) {
    final list = _activeList;

    return Column(
      key: ValueKey(_activeTab),
      children: list.take(5).map((tiket) {
        return _MonitoringTicketCard(
          tiket: tiket,
          tab: _activeTab,
          isTablet: isTablet,
          onTap: widget.onTapTiket != null
              ? () => widget.onTapTiket!(tiket)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isTablet) {
    return Container(
      key: ValueKey('empty_$_activeTab'),
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
              _activeTab.icon,
              size: isTablet ? 48 : 40,
              color: _activeTab.color.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyTitle(),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getEmptySubtitle(),
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyTitle() => switch (_activeTab) {
        _MonitoringTab.sedangDikerjakan => 'Belum ada tiket ditugaskan',
        _MonitoringTab.riwayatSaya => 'Belum ada riwayat selesai',
      };

  String _getEmptySubtitle() => switch (_activeTab) {
        _MonitoringTab.sedangDikerjakan =>
          'Tiket akan muncul setelah admin menugaskan kepada Anda',
        _MonitoringTab.riwayatSaya =>
          'Tiket yang sudah diselesaikan akan muncul di sini',
      };

  Widget _buildSkeleton(bool isDark, bool isTablet) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
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
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: isTablet ? 90 : 80,
                              height: isTablet ? 28 : 24,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? ShadcnTheme.darkBorder
                                    : ShadcnTheme.border,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: isTablet ? 80 : 70,
                              height: isTablet ? 36 : 32,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? ShadcnTheme.darkBorder
                                    : ShadcnTheme.border,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 10 : 8),
                        Container(
                          width: double.infinity,
                          height: isTablet ? 20 : 18,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: isTablet ? 160 : 120,
                          height: isTablet ? 14 : 12,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
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
        ),
      ),
    );
  }
}

/// Individual ticket card within the monitoring view
class _MonitoringTicketCard extends StatelessWidget {
  final Tiket tiket;
  final _MonitoringTab tab;
  final bool isTablet;
  final VoidCallback? onTap;

  const _MonitoringTicketCard({
    required this.tiket,
    required this.tab,
    required this.isTablet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = tab.color;

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
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tab.icon, size: 12, color: statusColor),
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
                              fontWeight: FontWeight.w400,
                              color: ShadTheme.of(context)
                                  .colorScheme
                                  .mutedForeground,
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
                          color:
                              ShadTheme.of(context).colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Creator info
                      if (tiket.namaPembuat != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: ShadTheme.of(context)
                                  .colorScheme
                                  .mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Oleh: ${tiket.namaPembuat}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: ShadTheme.of(context)
                                      .colorScheme
                                      .mutedForeground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}h lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru';
  }
}

/// Skeleton for ticket monitoring
class HelpdeskTiketMonitoringSkeleton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const HelpdeskTiketMonitoringSkeleton({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              Container(
                width: isTablet ? 44 : 40,
                height: isTablet ? 44 : 40,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: isTablet ? 140 : 120,
                height: isTablet ? 22 : 18,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // Tab bar skeleton
          Container(
            height: isTablet ? 64 : 56,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          // Ticket cards skeleton
          ...List.generate(
            2,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: isTablet ? 90 : 80,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
