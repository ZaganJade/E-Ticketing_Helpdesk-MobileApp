import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/shadcn_theme.dart';
import '../models/notifikasi_model.dart';

class NotifikasiCard extends StatelessWidget {
  final NotifikasiModel notifikasi;
  final VoidCallback? onTap;

  const NotifikasiCard({
    super.key,
    required this.notifikasi,
    this.onTap,
  });

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notifikasi.getIconConfig();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        backgroundColor: notifikasi.sudahDibaca
            ? null
            : (isDark
                ? ShadcnTheme.accent.withValues(alpha: 0.05)
                : ShadcnTheme.accent.withValues(alpha: 0.03)),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            width: isTablet ? 48 : 44,
            height: isTablet ? 48 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 24 : 22,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notifikasi.judul,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 15,
                          fontWeight: notifikasi.sudahDibaca
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: ShadTheme.of(context).colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Unread indicator dot
                    if (!notifikasi.sudahDibaca)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: ShadcnTheme.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? ShadcnTheme.darkCard
                                : ShadcnTheme.card,
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  notifikasi.pesan,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: isTablet ? 14 : 13,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRelativeTime(notifikasi.dibuatPada),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
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
