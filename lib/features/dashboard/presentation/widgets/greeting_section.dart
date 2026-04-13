import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/pengguna.dart';

/// Greeting section with user info
class GreetingSection extends StatelessWidget {
  final String greeting;
  final Pengguna user;

  const GreetingSection({
    super.key,
    required this.greeting,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: user.peran == Peran.admin
                  ? [AppColors.error, AppColors.error]
                  : user.peran == Peran.helpdesk
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [AppColors.secondary, AppColors.secondaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(user.nama),
              style: AppTextStyles.title.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.default_),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user.nama,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Role Badge
              _RoleBadge(peran: user.peran),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }
}

/// Role badge widget
class _RoleBadge extends StatelessWidget {
  final Peran peran;

  const _RoleBadge({required this.peran});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getRoleConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _getRoleConfig() {
    switch (peran) {
      case Peran.admin:
        return (peran.displayName, AppColors.error);
      case Peran.helpdesk:
        return (peran.displayName, AppColors.primary);
      case Peran.pengguna:
        return (peran.displayName, AppColors.secondary);
    }
  }
}

int min(int a, int b) => a < b ? a : b;

/// Skeleton version of greeting section
class GreetingSectionSkeleton extends StatelessWidget {
  const GreetingSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.shimmerBase,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.default_),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppBorderRadius.badgeRadius,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
