import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_border_radius.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  /// Light Theme with Shadcn integration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.card,
        onSurface: AppColors.foreground,
        error: AppColors.error,
        onError: AppColors.errorForeground,
        surfaceContainerHighest: AppColors.muted,
        outline: AppColors.border,
        shadow: AppColors.slate900,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.foreground,
        titleTextStyle: AppTextStyles.legacyTitle,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        color: AppColors.card,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.input, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.input, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.legacyLabel,
        hintStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.textMuted),
        errorStyle: AppTextStyles.legacyError,
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton,
          minimumSize: const Size(0, 40),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton.copyWith(color: AppColors.primary),
          minimumSize: const Size(0, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton.copyWith(color: AppColors.primary),
          minimumSize: const Size(0, 40),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
        ),
        contentTextStyle: AppTextStyles.legacyBody.copyWith(color: AppColors.slate50),
        actionTextColor: AppColors.accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary,
        labelStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.secondaryForeground),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.badgeRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.bottomSheetShape.borderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.slate900,
          borderRadius: AppBorderRadius.xsRadius,
        ),
        textStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.slate50),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.buttonRadius,
        ),
      ),
    );
  }

  /// Dark Theme with Shadcn integration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.primaryDarkForeground,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.secondaryDarkForeground,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkForeground,
        error: AppColors.error,
        onError: AppColors.errorForeground,
        surfaceContainerHighest: AppColors.darkMuted,
        outline: AppColors.darkBorder,
        shadow: AppColors.black,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.darkForeground,
        titleTextStyle: AppTextStyles.legacyTitle.copyWith(color: AppColors.darkForeground),
        iconTheme: const IconThemeData(color: AppColors.darkForeground),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        color: AppColors.darkCard,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkInput, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.legacyLabel.copyWith(color: AppColors.darkTextSecondary),
        hintStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.darkTextMuted),
        errorStyle: AppTextStyles.legacyError,
        prefixIconColor: AppColors.darkTextMuted,
        suffixIconColor: AppColors.darkTextMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.primaryDarkForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton,
          minimumSize: const Size(0, 40),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton.copyWith(color: AppColors.primaryDark),
          minimumSize: const Size(0, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.legacyButton.copyWith(color: AppColors.primaryDark),
          minimumSize: const Size(0, 40),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate100,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
        ),
        contentTextStyle: AppTextStyles.legacyBody.copyWith(color: AppColors.slate900),
        actionTextColor: AppColors.accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondaryDark,
        labelStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.secondaryDarkForeground),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.badgeRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.bottomSheetShape.borderRadius,
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: AppBorderRadius.xsRadius,
        ),
        textStyle: AppTextStyles.legacyCaption.copyWith(color: AppColors.slate900),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.primaryDarkForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.buttonRadius,
        ),
      ),
    );
  }

  /// Get ShadThemeData for shadcn_ui components
  static ShadThemeData getShadTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = isDark
        ? ShadColorScheme(
            background: AppColors.darkBackground,
            foreground: AppColors.darkForeground,
            card: AppColors.darkCard,
            cardForeground: AppColors.darkCardForeground,
            popover: AppColors.darkPopover,
            popoverForeground: AppColors.darkPopoverForeground,
            primary: AppColors.primaryDark,
            primaryForeground: AppColors.primaryDarkForeground,
            secondary: AppColors.secondaryDark,
            secondaryForeground: AppColors.secondaryDarkForeground,
            muted: AppColors.darkMuted,
            mutedForeground: AppColors.darkMutedForeground,
            accent: AppColors.accent,
            accentForeground: AppColors.accentForeground,
            destructive: AppColors.destructive,
            destructiveForeground: AppColors.destructiveForeground,
            border: AppColors.darkBorder,
            input: AppColors.darkInput,
            ring: AppColors.primaryDark,
            selection: AppColors.darkSelection,
          )
        : ShadColorScheme(
            background: AppColors.background,
            foreground: AppColors.foreground,
            card: AppColors.card,
            cardForeground: AppColors.cardForeground,
            popover: AppColors.popover,
            popoverForeground: AppColors.popoverForeground,
            primary: AppColors.primary,
            primaryForeground: AppColors.primaryForeground,
            secondary: AppColors.secondary,
            secondaryForeground: AppColors.secondaryForeground,
            muted: AppColors.muted,
            mutedForeground: AppColors.mutedForeground,
            accent: AppColors.accent,
            accentForeground: AppColors.accentForeground,
            destructive: AppColors.destructive,
            destructiveForeground: AppColors.destructiveForeground,
            border: AppColors.border,
            input: AppColors.input,
            ring: AppColors.ring,
            selection: AppColors.selection,
          );

    return ShadThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      radius: BorderRadius.circular(AppBorderRadius.default_),

      // Button themes - using standard ShadButtonTheme
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
        decoration: const ShadDecoration(
          border: ShadBorder.none,
        ),
      ),

      // Card theme
      cardTheme: ShadCardTheme(
        backgroundColor: colorScheme.card,
        padding: const EdgeInsets.all(AppSpacing.lg),
      ),

      // Badge themes - without shape parameter (not available in this version)
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

      // Input theme
      inputTheme: ShadInputTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: colorScheme.border),
            right: ShadBorderSide(color: colorScheme.border),
            bottom: ShadBorderSide(color: colorScheme.border),
            left: ShadBorderSide(color: colorScheme.border),
            radius: AppBorderRadius.defaultRadius,
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: AppBorderRadius.defaultRadius,
          ),
          color: colorScheme.background,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
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
            radius: AppBorderRadius.smRadius,
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: AppBorderRadius.smRadius,
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
      switchTheme: ShadSwitchTheme(
        decoration: const ShadDecoration(
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
            radius: AppBorderRadius.defaultRadius,
          ),
          focusedBorder: ShadBorder(
            top: ShadBorderSide(color: colorScheme.ring, width: 2),
            right: ShadBorderSide(color: colorScheme.ring, width: 2),
            bottom: ShadBorderSide(color: colorScheme.ring, width: 2),
            left: ShadBorderSide(color: colorScheme.ring, width: 2),
            radius: AppBorderRadius.defaultRadius,
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
            radius: AppBorderRadius.mdRadius,
          ),
        ),
      ),

      // Tooltip theme
      tooltipTheme: ShadTooltipTheme(
        decoration: ShadDecoration(
          color: isDark ? AppColors.slate100 : AppColors.slate900,
          border: ShadBorder.none,
        ),
      ),
    );
  }
}
