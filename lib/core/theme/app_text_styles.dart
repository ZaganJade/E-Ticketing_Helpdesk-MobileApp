import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_colors.dart';

/// App Text Styles - Adapted for shadcn_ui
/// Using AGENTS.md typography guidelines
class AppTextStyles {
  // ============================================
  // HEADLINES
  // ============================================
  static TextStyle headline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  // ============================================
  // TITLES (AGENTS.md: Section Title 16-18px, w600, -0.3)
  // ============================================
  static TextStyle title(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 18 : 16,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  static TextStyle titleSmall(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.3,
    );
  }

  // ============================================
  // SUBTITLES
  // ============================================
  static TextStyle subtitle(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 14 : 13,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.4,
    );
  }

  static TextStyle subtitleSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.4,
    );
  }

  // ============================================
  // BODY (AGENTS.md: Body 14-15px, w500)
  // ============================================
  static TextStyle body(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 14 : 13,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.5,
    );
  }

  // ============================================
  // CAPTION / MUTED (AGENTS.md: 13-14px, w400)
  // ============================================
  static TextStyle caption(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
      height: 1.4,
    );
  }

  static TextStyle captionSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
      height: 1.4,
    );
  }

  // ============================================
  // MUTED TEXT (AGENTS.md muted style)
  // ============================================
  static TextStyle muted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground,
      height: 1.5,
    );
  }

  static TextStyle mutedSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground,
      height: 1.5,
    );
  }

  // ============================================
  // BUTTON (AGENTS.md: 12-16px, w600)
  // ============================================
  static TextStyle button(BuildContext context, {bool isTablet = false}) {
    return TextStyle(
      fontSize: isTablet ? 14 : 13,
      fontWeight: FontWeight.w600,
      height: 1.0,
      letterSpacing: 0.2,
    );
  }

  static TextStyle buttonSmall(BuildContext context, {bool isTablet = false}) {
    return TextStyle(
      fontSize: isTablet ? 13 : 12,
      fontWeight: FontWeight.w600,
      height: 1.0,
      letterSpacing: 0.2,
    );
  }

  // ============================================
  // LABEL
  // ============================================
  static TextStyle label(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.0,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.0,
    );
  }

  // ============================================
  // ERROR
  // ============================================
  static TextStyle error(BuildContext context) {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.destructive,
      height: 1.5,
    );
  }

  // ============================================
  // LINK
  // ============================================
  static TextStyle link(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ShadTheme.of(context).colorScheme.primary,
      height: 1.5,
      decoration: TextDecoration.underline,
    );
  }

  // ============================================
  // CODE / MONOSPACE
  // ============================================
  static TextStyle code(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontFamily: 'monospace',
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.5,
      backgroundColor: isDark ? AppColors.darkMuted : AppColors.muted,
    );
  }

  // ============================================
  // LEAD TEXT
  // ============================================
  static TextStyle lead(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.6,
    );
  }

  // ============================================
  // SMALL TEXT
  // ============================================
  static TextStyle small(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
      height: 1.5,
    );
  }

  // ============================================
  // LIST ITEM
  // ============================================
  static TextStyle listItem(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.5,
    );
  }

  // ============================================
  // TABLE
  // ============================================
  static TextStyle tableHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.0,
    );
  }

  static TextStyle tableCell(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.5,
    );
  }

  // ============================================
  // TOAST
  // ============================================
  static TextStyle toastTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.3,
    );
  }

  static TextStyle toastDescription(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.5,
    );
  }

  // ============================================
  // FORM
  // ============================================
  static TextStyle formLabel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.0,
    );
  }

  static TextStyle formDescription(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.5,
    );
  }

  static TextStyle formError(BuildContext context) {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.destructive,
      height: 1.5,
    );
  }

  // ============================================
  // BADGE (AGENTS.md: Small/Badge 11-12px, w500)
  // ============================================
  static TextStyle badge(BuildContext context, {bool isTablet = false}) {
    return TextStyle(
      fontSize: isTablet ? 12 : 11,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );
  }

  static TextStyle badgeSmall(BuildContext context) {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.0,
    );
  }

  // ============================================
  // NAVIGATION
  // ============================================
  static TextStyle navigation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.0,
    );
  }

  // ============================================
  // TAB
  // ============================================
  static TextStyle tab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.0,
    );
  }

  static TextStyle tabActive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.0,
    );
  }

  // ============================================
  // EMPTY STATE
  // ============================================
  static TextStyle emptyStateTitle(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 18 : 16,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.3,
    );
  }

  static TextStyle emptyStateDescription(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      height: 1.5,
    );
  }

  // ============================================
  // CARD TITLE (AGENTS.md: Card Title 14-15px, w600)
  // ============================================
  static TextStyle cardTitle(BuildContext context, {bool isTablet = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkForeground : AppColors.foreground,
      height: 1.3,
    );
  }

  // ============================================
  // STATUS TEXT
  // ============================================
  static TextStyle statusText(BuildContext context, Color statusColor) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: statusColor,
      height: 1.0,
    );
  }

  // ============================================
  // COUNT BADGE
  // ============================================
  static TextStyle countBadge(BuildContext context, Color themeColor, {bool isTablet = false}) {
    return TextStyle(
      fontSize: isTablet ? 14 : 12,
      fontWeight: FontWeight.w600,
      color: themeColor,
      height: 1.0,
    );
  }

  // ============================================
  // LEGACY CONSTANTS (for backward compatibility)
  // ============================================
  static const TextStyle legacyHeadline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle legacyTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle legacyBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle legacyCaption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    height: 1.3,
  );

  static const TextStyle legacyButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.0,
  );

  static const TextStyle legacyLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.0,
  );

  static const TextStyle legacyError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.3,
  );
}
