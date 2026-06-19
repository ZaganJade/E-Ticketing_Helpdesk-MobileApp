import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/helpdesk_availability.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Admin ticket pool management: assign TERBUKA tickets, reassign/unassign DIPROSES
class AdminTicketPoolSection extends StatelessWidget {
  final List<Tiket> poolTickets;
  final List<Tiket> diprosesTickets;
  final List<HelpdeskAvailability> helpdesks;
  final bool isLoading;
  final void Function(Tiket tiket, String helpdeskId)? onAssign;
  final void Function(Tiket tiket, String helpdeskId)? onReassign;
  final void Function(Tiket tiket)? onUnassign;
  final void Function(Tiket tiket)? onTapTiket;

  const AdminTicketPoolSection({
    super.key,
    required this.poolTickets,
    required this.diprosesTickets,
    required this.helpdesks,
    this.isLoading = false,
    this.onAssign,
    this.onReassign,
    this.onUnassign,
    this.onTapTiket,
  });

  List<HelpdeskAvailability> get _freeHelpdesks =>
      helpdesks.where((h) => !h.sibuk).toList();

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
          _sectionHeader(context, isTablet),
          SizedBox(height: isTablet ? 20 : 16),
          if (isLoading)
            _buildSkeleton(isDark, isTablet)
          else ...[
            _subsectionTitle(context, 'Pool Tiket (Terbuka)', isTablet),
            const SizedBox(height: 8),
            if (poolTickets.isEmpty)
              _emptyBox(context, isDark, isTablet, 'Tidak ada tiket di pool')
            else
              ...poolTickets.take(5).map(
                    (t) => _AdminTicketRow(
                      tiket: t,
                      isTablet: isTablet,
                      primaryLabel: 'Tugaskan',
                      onPrimary: onAssign != null
                          ? () => _showHelpdeskPicker(
                                context,
                                title: 'Tugaskan ke Helpdesk',
                                onSelected: (id) => onAssign!(t, id),
                              )
                          : null,
                      onTap: onTapTiket != null ? () => onTapTiket!(t) : null,
                    ),
                  ),
            SizedBox(height: isTablet ? 20 : 16),
            _subsectionTitle(context, 'Sedang Diproses', isTablet),
            const SizedBox(height: 8),
            if (diprosesTickets.isEmpty)
              _emptyBox(context, isDark, isTablet, 'Tidak ada tiket diproses')
            else
              ...diprosesTickets.take(5).map(
                    (t) => _AdminTicketRow(
                      tiket: t,
                      isTablet: isTablet,
                      primaryLabel: 'Pindahkan',
                      secondaryLabel: 'Tarik',
                      onPrimary: onReassign != null
                          ? () => _showHelpdeskPicker(
                                context,
                                title: 'Pindahkan ke Helpdesk',
                                onSelected: (id) => onReassign!(t, id),
                              )
                          : null,
                      onSecondary: onUnassign != null
                          ? () => onUnassign!(t)
                          : null,
                      onTap: onTapTiket != null ? () => onTapTiket!(t) : null,
                    ),
                  ),
            if (_freeHelpdesks.isEmpty && helpdesks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Semua helpdesk sedang sibuk — tunggu hingga ada yang kosong.',
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showHelpdeskPicker(
    BuildContext context, {
    required String title,
    required void Function(String helpdeskId) onSelected,
  }) {
    final free = _freeHelpdesks;
    if (free.isEmpty) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Helpdesk tidak tersedia'),
          description: const Text(
            'Semua helpdesk sedang menangani tiket. Coba lagi nanti.',
          ),
        ),
      );
      return;
    }

    showShadDialog<void>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: Text(title),
        description: const Text('Pilih helpdesk yang sedang kosong:'),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: free
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ShadButton.outline(
                      width: double.infinity,
                      onPressed: () {
                        Navigator.pop(ctx);
                        onSelected(h.id);
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  h.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ShadTheme.of(ctx)
                                        .colorScheme
                                        .mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ShadcnTheme.statusDone
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Kosong',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ShadcnTheme.statusDone,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, bool isTablet) {
    return Row(
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
            Icons.assignment_turned_in_rounded,
            color: ShadcnTheme.accent,
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Penugasan',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Tugaskan tiket pool ke helpdesk kosong',
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subsectionTitle(BuildContext context, String title, bool isTablet) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 15 : 14,
        fontWeight: FontWeight.w600,
        color: ShadTheme.of(context).colorScheme.foreground,
      ),
    );
  }

  Widget _emptyBox(
    BuildContext context,
    bool isDark,
    bool isTablet,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isTablet ? 14 : 13,
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark, bool isTablet) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: isTablet ? 72 : 64,
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _AdminTicketRow extends StatelessWidget {
  final Tiket tiket;
  final bool isTablet;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback? onTap;

  const _AdminTicketRow({
    required this.tiket,
    required this.isTablet,
    required this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = switch (tiket.status) {
      StatusTiket.terbuka => ShadcnTheme.statusOpen,
      StatusTiket.diproses => ShadcnTheme.statusInProgress,
      StatusTiket.selesai => ShadcnTheme.statusDone,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
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
                                color: ShadTheme.of(context)
                                    .colorScheme
                                    .foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (tiket.namaPembuat != null)
                              Text(
                                'Oleh: ${tiket.namaPembuat}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ShadTheme.of(context)
                                      .colorScheme
                                      .mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onSecondary != null) ...[
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          onPressed: onSecondary,
                          child: Text(secondaryLabel ?? 'Tarik'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onPrimary != null)
                        ShadButton(
                          size: ShadButtonSize.sm,
                          backgroundColor: ShadcnTheme.accent,
                          onPressed: onPrimary,
                          child: Text(
                            primaryLabel,
                            style: const TextStyle(color: Colors.white),
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
    );
  }
}
