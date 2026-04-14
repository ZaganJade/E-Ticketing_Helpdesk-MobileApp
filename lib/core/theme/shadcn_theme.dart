import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Shadcn Theme Configuration
/// Following "Refined Glassmorphism" design system from AGENTS.md
/// Uses shadcn_ui 0.53.5+ API
class ShadcnTheme {
  // ============================================
  // STATUS COLORS (AGENTS.md specification)
  // ============================================
  static const statusOpen = Color(0xFFF43F5E);      // Rose - Terbuka
  static const statusInProgress = Color(0xFFF59E0B); // Amber - Diproses
  static const statusDone = Color(0xFF10B981);      // Emerald - Selesai

  // ============================================
  // PRIMARY COLORS
  // ============================================
  static const primary = Color(0xFF6366F1);         // Indigo accent
  static const primaryForeground = Color(0xFFFFFFFF);
  static const primaryDark = Color(0xFF818CF8);
  static const primaryDarkForeground = Color(0xFF18181B);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const accent = Color(0xFF6366F1);          // Indigo
  static const accentForeground = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);

  // ============================================
  // MUTED COLORS (AGENTS.md specification)
  // ============================================
  static const muted = Color(0xFFF1F5F9);         // Light mode card bg
  static const mutedForeground = Color(0xFF64748B);
  static const darkMuted = Color(0xFF1E293B);     // Dark mode card bg
  static const darkMutedForeground = Color(0xFF94A3B8);

  // ============================================
  // BORDER COLORS (AGENTS.md specification)
  // ============================================
  static const border = Color(0xFFE2E8F0);        // Light borders
  static const darkBorder = Color(0xFF334155);  // Dark borders
  static const input = Color(0xFFE2E8F0);
  static const darkInput = Color(0xFF334155);
  static const ring = Color(0xFF6366F1);
  static const darkRing = Color(0xFF818CF8);

  // ============================================
  // SLATE SCALE (for backgrounds and text)
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
  // ZINC SCALE (for neutral elements)
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
  // BACKGROUND COLORS
  // ============================================
  static const background = Color(0xFFF8FAFC);
  static const foreground = Color(0xFF0F172A);
  static const darkBackground = Color(0xFF0F172A);
  static const darkForeground = Color(0xFFF8FAFC);

  // ============================================
  // CARD COLORS
  // ============================================
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkCardForeground = Color(0xFFF8FAFC);

  // ============================================
  // POPOVER COLORS
  // ============================================
  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF0F172A);
  static const darkPopover = Color(0xFF1E293B);
  static const darkPopoverForeground = Color(0xFFF8FAFC);

  // ============================================
  // SECONDARY COLORS
  // ============================================
  static const secondary = Color(0xFFF1F5F9);
  static const secondaryForeground = Color(0xFF1E293B);
  static const darkSecondary = Color(0xFF334155);
  static const darkSecondaryForeground = Color(0xFFF1F5F9);

  // ============================================
  // UTILITY COLORS
  // ============================================
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ============================================
  // SELECTION
  // ============================================
  static Color get selection => accent.withValues(alpha: 0.2);
  static Color get darkSelection => accent.withValues(alpha: 0.3);

  // ============================================
  // THEME DATA
  // ============================================

  /// Get ShadThemeData for the app
  static ShadThemeData themeData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = isDark
        ? ShadColorScheme(
            background: darkBackground,
            foreground: darkForeground,
            card: darkCard,
            cardForeground: darkCardForeground,
            popover: darkCard,
            popoverForeground: darkCardForeground,
            primary: primaryDark,
            primaryForeground: primaryDarkForeground,
            secondary: darkSecondary,
            secondaryForeground: darkSecondaryForeground,
            muted: darkMuted,
            mutedForeground: darkMutedForeground,
            accent: accent,
            accentForeground: accentForeground,
            destructive: destructive,
            destructiveForeground: destructiveForeground,
            border: darkBorder,
            input: darkInput,
            ring: primaryDark,
            selection: darkSelection,
          )
        : ShadColorScheme(
            background: background,
            foreground: foreground,
            card: card,
            cardForeground: cardForeground,
            popover: popover,
            popoverForeground: popoverForeground,
            primary: primary,
            primaryForeground: primaryForeground,
            secondary: secondary,
            secondaryForeground: secondaryForeground,
            muted: muted,
            mutedForeground: mutedForeground,
            accent: accent,
            accentForeground: accentForeground,
            destructive: destructive,
            destructiveForeground: destructiveForeground,
            border: border,
            input: input,
            ring: ring,
            selection: selection,
          );

    return ShadThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      radius: BorderRadius.circular(6),

      // Button themes
      primaryButtonTheme: ShadButtonTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.primaryForeground,
      ),
      secondaryButtonTheme: ShadButtonTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.secondaryForeground,
      ),
      destructiveButtonTheme: ShadButtonTheme(
        backgroundColor: colorScheme.destructive,
        foregroundColor: colorScheme.destructiveForeground,
      ),
      outlineButtonTheme: ShadButtonTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.foreground,
      ),
      ghostButtonTheme: ShadButtonTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.foreground,
        hoverBackgroundColor: colorScheme.muted,
      ),
      linkButtonTheme: ShadButtonTheme(
        foregroundColor: colorScheme.primary,
      ),

      // Badge themes
      primaryBadgeTheme: ShadBadgeTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.primaryForeground,
      ),
      secondaryBadgeTheme: ShadBadgeTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.secondaryForeground,
      ),
      outlineBadgeTheme: ShadBadgeTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.foreground,
      ),
      destructiveBadgeTheme: ShadBadgeTheme(
        backgroundColor: colorScheme.destructive,
        foregroundColor: colorScheme.destructiveForeground,
      ),

      // Card theme
      cardTheme: ShadCardTheme(
        backgroundColor: colorScheme.card,
        padding: const EdgeInsets.all(20),
      ),

      // Input theme
      inputTheme: ShadInputTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
            radius: BorderRadius.circular(8),
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Checkbox theme
      checkboxTheme: ShadCheckboxTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
            radius: BorderRadius.circular(4),
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: BorderRadius.circular(4),
          ),
        ),
      ),

      // Radio theme
      radioTheme: ShadRadioTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
          ),
        ),
      ),

      // Switch theme
      switchTheme: const ShadSwitchTheme(
        decoration: ShadDecoration(
          border: ShadBorder.none,
        ),
      ),

      // Select theme
      selectTheme: ShadSelectTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
            radius: BorderRadius.circular(8),
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Option theme
      optionTheme: const ShadOptionTheme(),

      // Avatar theme
      avatarTheme: ShadAvatarTheme(
        backgroundColor: colorScheme.muted,
      ),

      // Popover theme
      popoverTheme: ShadPopoverTheme(
        decoration: ShadDecoration(
          color: colorScheme.popover,
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
            radius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Tooltip theme
      tooltipTheme: ShadTooltipTheme(
        decoration: ShadDecoration(
          color: isDark ? slate100 : slate900,
          border: ShadBorder.none,
        ),
      ),
    );
  }

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
