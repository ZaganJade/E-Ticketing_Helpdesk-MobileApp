import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';

/// Widget for displaying a single komentar in chat-style bubble - Redesigned with shadcn_ui
class KomentarCard extends StatelessWidget {
  final Komentar komentar;
  final bool isCurrentUser;
  final bool isNew;
  final VoidCallback? onReply;

  const KomentarCard({
    super.key,
    required this.komentar,
    this.isCurrentUser = false,
    this.isNew = false,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isStaff = komentar.isFromStaff;
    final foregroundColor = ShadTheme.of(context).colorScheme.foreground;
    final mutedForegroundColor = ShadTheme.of(context).colorScheme.mutedForeground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isNew
            ? ShadcnTheme.accent.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar on left for staff, spacer for user
          if (isStaff) ...[
            _buildAvatar(isStaff, isTablet),
            SizedBox(width: isTablet ? 16 : 12),
          ] else
            SizedBox(width: isTablet ? 48 : 40),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Author info row
                _buildAuthorInfo(isStaff, isTablet, foregroundColor),
                const SizedBox(height: 4),

                // Message bubble
                _buildBubble(isStaff, isDark, isTablet, foregroundColor),

                // Timestamp below bubble
                const SizedBox(height: 4),
                _buildTimestamp(isStaff, isTablet, mutedForegroundColor, context),

                // New indicator
                if (isNew) ...[
                  const SizedBox(height: 4),
                  _buildNewIndicator(),
                ],
              ],
            ),
          ),

          // Spacer for staff, avatar on right for user
          if (!isStaff) ...[
            SizedBox(width: isTablet ? 16 : 12),
            _buildAvatar(isStaff, isTablet),
          ] else
            SizedBox(width: isTablet ? 48 : 40),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isStaff, bool isTablet) {
    final initials = _getInitials(komentar.namaPenulis);
    final avatarColor = isStaff ? ShadcnTheme.accent : ShadcnTheme.statusInProgress;

    return Container(
      width: isTablet ? 40 : 36,
      height: isTablet ? 40 : 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            avatarColor.withValues(alpha: 0.8),
            avatarColor,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(bool isStaff, bool isTablet, Color foregroundColor) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        // Name
        Text(
          komentar.namaPenulis,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
        // Role badge
        _buildRoleBadge(isTablet),
      ],
    );
  }

  Widget _buildRoleBadge(bool isTablet) {
    final (label, color) = _getRoleConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 11 : 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _getRoleConfig() {
    switch (komentar.peranPenulis) {
      case Peran.admin:
        return ('Admin', ShadcnTheme.statusOpen);
      case Peran.helpdesk:
        return ('Helpdesk', ShadcnTheme.accent);
      case Peran.pengguna:
        return ('Pengguna', ShadcnTheme.statusDone);
    }
  }

  Widget _buildBubble(bool isStaff, bool isDark, bool isTablet, Color foregroundColor) {
    final bubbleColor = isStaff
        ? (isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted)
        : ShadcnTheme.accent;
    final textColor = isStaff
        ? foregroundColor
        : Colors.white;
    final borderColor = isStaff
        ? (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
        : Colors.transparent;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isTablet ? 400 : 280,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isStaff ? 4 : 16),
          bottomRight: Radius.circular(isStaff ? 16 : 4),
        ),
        border: Border.all(
          color: borderColor,
          width: isStaff ? 1 : 0,
        ),
      ),
      child: Text(
        komentar.isiPesan,
        style: TextStyle(
          fontSize: isTablet ? 15 : 14,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTimestamp(bool isStaff, bool isTablet, Color mutedForegroundColor, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatRelativeTime(komentar.dibuatPada),
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: mutedForegroundColor,
          ),
        ),
        // Reply button
        if (onReply != null) ...[
          const SizedBox(width: 8),
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: onReply,
            child: Text(
              'Balas',
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: ShadcnTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNewIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ShadcnTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: ShadcnTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Komentar baru',
            style: TextStyle(
              fontSize: 11,
              color: ShadcnTheme.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }
}
