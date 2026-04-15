import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Tiket Terbuka section with modern, consistent design
class TiketTerbukaSection extends StatelessWidget {
  final List<Tiket> tiketList;
  final Function(String)? onAmbilTiket;
  final bool isLoading;

  const TiketTerbukaSection({
    super.key,
    required this.tiketList,
    this.onAmbilTiket,
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
                            ShadcnTheme.statusOpen.withValues(alpha: 0.2),
                            ShadcnTheme.statusOpen.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inbox_rounded,
                        color: ShadcnTheme.statusOpen,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Text(
                      'Tiket Terbuka',
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
                      color: ShadcnTheme.statusOpen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tiketList.length}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: ShadcnTheme.statusOpen,
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
              const EmptyState.tickets()
            else
              Column(
                children: tiketList.take(5).map((tiket) => _TicketCard(
                  tiket: tiket,
                  onAmbil: onAmbilTiket != null ? () => onAmbilTiket!(tiket.id) : null,
                  isTablet: isTablet,
                )).toList(),
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
                          // Button skeleton
                          Container(
                            width: isTablet ? 80 : 70,
                            height: isTablet ? 36 : 32,
                            decoration: BoxDecoration(
                              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                              borderRadius: BorderRadius.circular(8),
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

/// Individual ticket card with action button - Responsive
class _TicketCard extends StatelessWidget {
  final Tiket tiket;
  final void Function()? onAmbil;
  final bool isTablet;

  const _TicketCard({
    required this.tiket,
    this.onAmbil,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Left accent bar (always statusOpen color for open tickets)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: ShadcnTheme.statusOpen,
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
                            color: ShadcnTheme.statusOpen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.radio_button_unchecked_rounded,
                                size: 12,
                                color: ShadcnTheme.statusOpen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tiket.status.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ShadcnTheme.statusOpen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Ambil button
                        ShadButton(
                          size: ShadButtonSize.sm,
                          backgroundColor: ShadcnTheme.accent,
                          onPressed: onAmbil,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_task_rounded,
                                size: isTablet ? 16 : 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ambil',
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }
}
