import 'package:flutter/material.dart';
import '../../core/theme/shadcn_theme.dart';

/// Tiket Status - Enum for ticket status
enum TiketStatus {
  terbuka,
  diproses,
  selesai,
}

/// Status Badge - Redesigned with shadcn_ui
/// A reusable component for displaying status badges
class StatusBadge extends StatelessWidget {
  final TiketStatus status;
  final bool showIcon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _getStatusConfig();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? (isTablet ? 12 : 10) : (isTablet ? 10 : 8),
        vertical: isLarge ? (isTablet ? 8 : 6) : (isTablet ? 6 : 4),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: isLarge ? (isTablet ? 18 : 16) : (isTablet ? 14 : 12),
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? (isTablet ? 14 : 13) : (isTablet ? 12 : 11),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusConfig() {
    switch (status) {
      case TiketStatus.terbuka:
        return (
          'Terbuka',
          ShadcnTheme.statusOpen,
          Icons.radio_button_unchecked_rounded,
        );
      case TiketStatus.diproses:
        return (
          'Diproses',
          ShadcnTheme.statusInProgress,
          Icons.sync_rounded,
        );
      case TiketStatus.selesai:
        return (
          'Selesai',
          ShadcnTheme.statusDone,
          Icons.check_circle_rounded,
        );
    }
  }
}

/// Status Badge From String - Create a status badge from a string value
class StatusBadgeFromString extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool isLarge;

  const StatusBadgeFromString({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _getStatusConfig();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? (isTablet ? 12 : 10) : (isTablet ? 10 : 8),
        vertical: isLarge ? (isTablet ? 8 : 6) : (isTablet ? 6 : 4),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: isLarge ? (isTablet ? 18 : 16) : (isTablet ? 14 : 12),
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? (isTablet ? 14 : 13) : (isTablet ? 12 : 11),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusConfig() {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return (
          'Terbuka',
          ShadcnTheme.statusOpen,
          Icons.radio_button_unchecked_rounded,
        );
      case 'DIPROSES':
        return (
          'Diproses',
          ShadcnTheme.statusInProgress,
          Icons.sync_rounded,
        );
      case 'SELESAI':
        return (
          'Selesai',
          ShadcnTheme.statusDone,
          Icons.check_circle_rounded,
        );
      default:
        return (
          status,
          ShadcnTheme.zinc500,
          Icons.help_outline_rounded,
        );
    }
  }
}

/// Role Badge - Badge for displaying user roles
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getRoleConfig();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 13 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _getRoleConfig() {
    switch (role.toLowerCase()) {
      case 'admin':
        return ('Admin', ShadcnTheme.statusOpen);
      case 'helpdesk':
        return ('Helpdesk', ShadcnTheme.accent);
      case 'pengguna':
      default:
        return ('Pengguna', ShadcnTheme.statusDone);
    }
  }
}
