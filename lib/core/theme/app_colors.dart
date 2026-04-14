import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// App Colors - Adapted for shadcn_ui
/// Using Shadcn color system with "Refined Glassmorphism" design
/// Based on AGENTS.md guidelines
class AppColors {
  // Shadcn Color Scheme Access
  static ShadColorScheme shadcnColorScheme(BuildContext context) {
    return ShadTheme.of(context).colorScheme;
  }

  // ============================================
  // PRIMARY COLORS
  // ============================================
  static const Color primary = Color(0xFF6366F1); // Indigo accent
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color primaryDarkForeground = Color(0xFF18181B);

  // ============================================
  // SECONDARY COLORS
  // ============================================
  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryForeground = Color(0xFF1E293B);
  static const Color secondaryDark = Color(0xFF334155);
  static const Color secondaryDarkForeground = Color(0xFFF1F5F9);

  // ============================================
  // MUTED COLORS (AGENTS.md specification)
  // ============================================
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color darkMuted = Color(0xFF1E293B);
  static const Color darkMutedForeground = Color(0xFF94A3B8);

  // ============================================
  // STATUS COLORS (AGENTS.md specification)
  // ============================================
  static const Color statusOpen = Color(0xFFF43F5E);      // Rose - Terbuka
  static const Color statusInProgress = Color(0xFFF59E0B); // Amber - Diproses
  static const Color statusDone = Color(0xFF10B981);      // Emerald - Selesai

  // Legacy status aliases
  static const Color statusTerbuka = Color(0xFFF43F5E);
  static const Color statusDiproses = Color(0xFFF59E0B);
  static const Color statusSelesai = Color(0xFF10B981);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color errorForeground = Color(0xFFFFFFFF);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF6366F1);
  static const Color infoForeground = Color(0xFFFFFFFF);

  // ============================================
  // ACCENT COLOR (AGENTS.md specification)
  // ============================================
  static const Color accent = Color(0xFF6366F1); // Indigo
  static const Color accentForeground = Color(0xFFFFFFFF);

  // ============================================
  // ZINC SCALE
  // ============================================
  static const zinc50 = Color(0xFFFAFAFA);
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc400 = Color(0xFFA1A1AA);
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);
  static const zinc950 = Color(0xFF09090B);

  // ============================================
  // SLATE SCALE (for text and backgrounds)
  // ============================================
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const slate950 = Color(0xFF020617);

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  static const Color background = Color(0xFFF8FAFC);
  static const Color foreground = Color(0xFF0F172A);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkForeground = Color(0xFFF8FAFC);

  // ============================================
  // CARD COLORS
  // ============================================
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardForeground = Color(0xFFF8FAFC);

  // ============================================
  // POPOVER COLORS
  // ============================================
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF0F172A);
  static const Color darkPopover = Color(0xFF1E293B);
  static const Color darkPopoverForeground = Color(0xFFF8FAFC);

  // ============================================
  // BORDER & INPUT (AGENTS.md specification)
  // ============================================
  static const Color border = Color(0xFFE2E8F0);
  static const Color input = Color(0xFFE2E8F0);
  static const Color ring = Color(0xFF6366F1);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkInput = Color(0xFF334155);
  static const Color darkRing = Color(0xFF818CF8);

  // ============================================
  // SURFACE COLORS (Legacy compatibility)
  // ============================================
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E293B);

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // ============================================
  // UTILITY COLORS
  // ============================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ============================================
  // OVERLAY & EFFECTS
  // ============================================
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // ============================================
  // SELECTION COLORS
  // ============================================
  static Color get selection => accent.withValues(alpha: 0.2);
  static Color get darkSelection => accent.withValues(alpha: 0.3);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terbuka':
      case 'open':
        return statusOpen;
      case 'diproses':
      case 'in_progress':
      case 'progress':
        return statusInProgress;
      case 'selesai':
      case 'done':
      case 'completed':
        return statusDone;
      default:
        return zinc500;
    }
  }

  /// Get status foreground color (always white for status badges)
  static Color getStatusForegroundColor(String status) {
    return Colors.white;
  }

  /// Get status icon based on status string
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'terbuka':
      case 'open':
        return Icons.radio_button_unchecked_rounded;
      case 'diproses':
      case 'in_progress':
      case 'progress':
        return Icons.sync_rounded;
      case 'selesai':
      case 'done':
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Get status badge style (background with alpha, foreground color, icon)
  static ({Color background, Color foreground, IconData icon}) getStatusBadgeStyle(String status) {
    final color = getStatusColor(status);
    return (
      background: color.withValues(alpha: 0.1),
      foreground: color,
      icon: getStatusIcon(status),
    );
  }

  /// Get theme-aware color
  static Color getThemeColor(BuildContext context, Color lightColor, Color darkColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }

  /// Get muted color for current theme
  static Color getMuted(BuildContext context) {
    return getThemeColor(context, muted, darkMuted);
  }

  /// Get muted foreground color for current theme
  static Color getMutedForeground(BuildContext context) {
    return getThemeColor(context, mutedForeground, darkMutedForeground);
  }

  /// Get border color for current theme
  static Color getBorder(BuildContext context) {
    return getThemeColor(context, border, darkBorder);
  }

  /// Get card background for current theme
  static Color getCardBackground(BuildContext context) {
    return getThemeColor(context, card, darkCard);
  }

  /// Get card foreground for current theme
  static Color getCardForeground(BuildContext context) {
    return getThemeColor(context, cardForeground, darkCardForeground);
  }
}
