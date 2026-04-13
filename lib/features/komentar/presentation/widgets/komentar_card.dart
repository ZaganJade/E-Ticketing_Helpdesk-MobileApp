import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';

/// Widget for displaying a single komentar in chat-style bubble
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
    final isStaff = komentar.isFromStaff;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: AppBorderRadius.cardRadius,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar on left for staff, spacer for user
          if (isStaff) ...[
            _buildAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ] else
            const SizedBox(width: 48),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Author info row
                _buildAuthorInfo(isStaff),
                const SizedBox(height: AppSpacing.xs),

                // Message bubble
                _buildBubble(isStaff),

                // Timestamp below bubble
                const SizedBox(height: AppSpacing.xs),
                _buildTimestamp(isStaff),

                // New indicator
                if (isNew) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildNewIndicator(),
                ],
              ],
            ),
          ),

          // Spacer for staff, avatar on right for user
          if (!isStaff) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildAvatar(),
          ] else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = _getInitials(komentar.namaPenulis);
    final isStaff = komentar.isFromStaff;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isStaff ? AppColors.primary : AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(bool isStaff) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        // Name
        Text(
          komentar.namaPenulis,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // Role badge
        _buildRoleBadge(),
      ],
    );
  }

  Widget _buildRoleBadge() {
    final (label, color) = _getRoleConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  (String, Color) _getRoleConfig() {
    switch (komentar.peranPenulis) {
      case Peran.admin:
        return ('Admin', AppColors.error);
      case Peran.helpdesk:
        return ('Helpdesk', AppColors.primary);
      case Peran.pengguna:
        return ('Pengguna', AppColors.secondary);
    }
  }

  Widget _buildBubble(bool isStaff) {
    final bubbleColor = isStaff
        ? AppColors.surface
        : AppColors.primary;
    final textColor = isStaff
        ? AppColors.textPrimary
        : AppColors.white;
    final borderColor = isStaff
        ? AppColors.border
        : AppColors.primary;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 280,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.default_,
        vertical: AppSpacing.md,
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
        style: AppTextStyles.body.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTimestamp(bool isStaff) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatRelativeTime(komentar.dibuatPada),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        // Reply button
        if (onReply != null) ...[
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onReply,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Text(
                'Balas',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNewIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Komentar baru',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
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
