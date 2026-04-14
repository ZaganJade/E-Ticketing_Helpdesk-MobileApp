import 'package:flutter/material.dart';

/// App Border Radius - Adapted for shadcn_ui
/// Using Shadcn/Tailwind border radius conventions
/// Based on AGENTS.md guidelines
class AppBorderRadius {
  // ============================================
  // BASE RADIUS VALUES (Tailwind/Shadcn style)
  // ============================================
  static const double none = 0;
  static const double sm = 2;       // 2px
  static const double default_ = 4; // 4px (renamed to avoid keyword conflict)
  static const double md = 6;       // 6px
  static const double lg = 8;       // 8px
  static const double xl = 12;      // 12px
  static const double xl2 = 16;     // 16px
  static const double xl3 = 20;     // 20px
  static const double full = 9999;  // Fully rounded

  // Legacy aliases for backward compatibility
  static const double xs = sm;
  static const double button = lg;
  static const double input = lg;
  static const double card = xl;
  static const double modal = xl2;
  static const double badge = full;

  // Shadcn specific radii
  static const double radiusNone = none;
  static const double radiusSm = sm;
  static const double radiusDefault = default_;
  static const double radiusMd = md;
  static const double radiusLg = lg;
  static const double radiusXl = xl;
  static const double radiusXl2 = xl2;
  static const double radiusXl3 = xl3;
  static const double radiusFull = full;

  // ============================================
  // BorderRadius OBJECTS
  // ============================================

  // None
  static final BorderRadius noneRadius = BorderRadius.circular(none);

  // Small
  static final BorderRadius smRadius = BorderRadius.circular(sm);

  // Default (Shadcn default)
  static final BorderRadius defaultRadius = BorderRadius.circular(default_);

  // Medium
  static final BorderRadius mdRadius = BorderRadius.circular(md);

  // Large (buttons, inputs)
  static final BorderRadius lgRadius = BorderRadius.circular(lg);

  // Extra large (cards)
  static final BorderRadius xlRadius = BorderRadius.circular(xl);

  // 2XL (modals, dialogs)
  static final BorderRadius xl2Radius = BorderRadius.circular(xl2);

  // 3XL (large containers)
  static final BorderRadius xl3Radius = BorderRadius.circular(xl3);

  // Full (pills, badges, avatars)
  static final BorderRadius fullRadius = BorderRadius.circular(full);

  // Legacy aliases
  static final BorderRadius xsRadius = smRadius;
  static final BorderRadius buttonRadius = lgRadius;
  static final BorderRadius inputRadius = lgRadius;
  static final BorderRadius cardRadius = xlRadius;
  static final BorderRadius modalRadius = xl2Radius;
  static final BorderRadius badgeRadius = fullRadius;

  // Shadcn named radii
  static final BorderRadius radiusNoneValue = noneRadius;
  static final BorderRadius radiusSmValue = smRadius;
  static final BorderRadius radiusDefaultValue = defaultRadius;
  static final BorderRadius radiusMdValue = mdRadius;
  static final BorderRadius radiusLgValue = lgRadius;
  static final BorderRadius radiusXlValue = xlRadius;
  static final BorderRadius radiusXl2Value = xl2Radius;
  static final BorderRadius radiusXl3Value = xl3Radius;
  static final BorderRadius radiusFullValue = fullRadius;

  // ============================================
  // DIRECTIONAL RADII
  // ============================================

  // Top only
  static final BorderRadius topRadius = BorderRadius.vertical(
    top: const Radius.circular(default_),
  );

  static final BorderRadius topSmRadius = BorderRadius.vertical(
    top: const Radius.circular(sm),
  );

  static final BorderRadius topLgRadius = BorderRadius.vertical(
    top: const Radius.circular(lg),
  );

  static final BorderRadius topXlRadius = BorderRadius.vertical(
    top: const Radius.circular(xl),
  );

  static final BorderRadius topXl2Radius = BorderRadius.vertical(
    top: const Radius.circular(xl2),
  );

  // Bottom only
  static final BorderRadius bottomRadius = BorderRadius.vertical(
    bottom: const Radius.circular(default_),
  );

  static final BorderRadius bottomSmRadius = BorderRadius.vertical(
    bottom: const Radius.circular(sm),
  );

  static final BorderRadius bottomLgRadius = BorderRadius.vertical(
    bottom: const Radius.circular(lg),
  );

  static final BorderRadius bottomXlRadius = BorderRadius.vertical(
    bottom: const Radius.circular(xl),
  );

  static final BorderRadius bottomXl2Radius = BorderRadius.vertical(
    bottom: const Radius.circular(xl2),
  );

  // Left only
  static final BorderRadius leftRadius = BorderRadius.horizontal(
    left: const Radius.circular(default_),
  );

  static final BorderRadius leftLgRadius = BorderRadius.horizontal(
    left: const Radius.circular(lg),
  );

  // Right only
  static final BorderRadius rightRadius = BorderRadius.horizontal(
    right: const Radius.circular(default_),
  );

  static final BorderRadius rightLgRadius = BorderRadius.horizontal(
    right: const Radius.circular(lg),
  );

  // ============================================
  // SHAPE BORDERS (Material style with Shadcn radii)
  // ============================================

  static final RoundedRectangleBorder smShape = RoundedRectangleBorder(
    borderRadius: smRadius,
  );

  static final RoundedRectangleBorder defaultShape = RoundedRectangleBorder(
    borderRadius: defaultRadius,
  );

  static final RoundedRectangleBorder mdShape = RoundedRectangleBorder(
    borderRadius: mdRadius,
  );

  static final RoundedRectangleBorder lgShape = RoundedRectangleBorder(
    borderRadius: lgRadius,
  );

  static final RoundedRectangleBorder xlShape = RoundedRectangleBorder(
    borderRadius: xlRadius,
  );

  static final RoundedRectangleBorder xl2Shape = RoundedRectangleBorder(
    borderRadius: xl2Radius,
  );

  static final RoundedRectangleBorder xl3Shape = RoundedRectangleBorder(
    borderRadius: xl3Radius,
  );

  static final RoundedRectangleBorder fullShape = RoundedRectangleBorder(
    borderRadius: fullRadius,
  );

  // Legacy shape aliases
  static final RoundedRectangleBorder xsShape = smShape;
  static final RoundedRectangleBorder buttonShape = lgShape;
  static final RoundedRectangleBorder inputShape = lgShape;
  static final RoundedRectangleBorder cardShape = xlShape;
  static final RoundedRectangleBorder modalShape = xl2Shape;

  // ============================================
  // COMPONENT SPECIFIC SHAPES
  // ============================================

  // Bottom sheet shape (top rounded only)
  static final RoundedRectangleBorder bottomSheetShape = RoundedRectangleBorder(
    borderRadius: topXl2Radius,
  );

  // Dialog shape
  static final RoundedRectangleBorder dialogShape = xl2Shape;

  // Snackbar shape
  static final RoundedRectangleBorder snackbarShape = mdShape;

  // Tooltip shape
  static final RoundedRectangleBorder tooltipShape = defaultShape;

  // Chip shape
  static final RoundedRectangleBorder chipShape = fullShape;

  // Badge shape
  static final RoundedRectangleBorder badgeShape = fullShape;

  // Avatar shape (circle)
  static final RoundedRectangleBorder avatarShape = fullShape;

  // Pill shape
  static final RoundedRectangleBorder pillShape = fullShape;

  // ============================================
  // OUTLINED SHAPE VARIATIONS
  // ============================================

  static RoundedRectangleBorder outlinedShape({
    Color color = Colors.grey,
    double width = 1,
    BorderRadius? borderRadius,
  }) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? defaultRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  static RoundedRectangleBorder smOutlinedShape({Color color = Colors.grey, double width = 1}) {
    return RoundedRectangleBorder(
      borderRadius: smRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  static RoundedRectangleBorder defaultOutlinedShape({Color color = Colors.grey, double width = 1}) {
    return RoundedRectangleBorder(
      borderRadius: defaultRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  static RoundedRectangleBorder lgOutlinedShape({Color color = Colors.grey, double width = 1}) {
    return RoundedRectangleBorder(
      borderRadius: lgRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  static RoundedRectangleBorder xlOutlinedShape({Color color = Colors.grey, double width = 1}) {
    return RoundedRectangleBorder(
      borderRadius: xlRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  static RoundedRectangleBorder fullOutlinedShape({Color color = Colors.grey, double width = 1}) {
    return RoundedRectangleBorder(
      borderRadius: fullRadius,
      side: BorderSide(color: color, width: width),
    );
  }

  // ============================================
  // DECORATED SHAPES
  // ============================================

  /// Circle decoration
  static const BoxDecoration circleDecoration = BoxDecoration(
    shape: BoxShape.circle,
  );

  /// Pill decoration with optional color
  static BoxDecoration pillDecoration({Color? color}) {
    return BoxDecoration(
      borderRadius: fullRadius,
      color: color,
    );
  }

  /// Card decoration with border
  static BoxDecoration cardDecoration({
    Color? color,
    Color borderColor = Colors.grey,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      borderRadius: cardRadius,
      color: color,
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }

  /// Gradient circle decoration (AGENTS.md header pattern)
  static BoxDecoration gradientCircleDecoration({
    required Color themeColor,
    List<Color>? colors,
  }) {
    final gradientColors = colors ?? [
      themeColor.withValues(alpha: 0.2),
      themeColor.withValues(alpha: 0.1),
    ];

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: xlRadius,
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create BorderRadius with custom value
  static BorderRadius custom(double value) => BorderRadius.circular(value);

  /// Create BorderRadius with custom radii for each corner
  static BorderRadius customOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  // ============================================
  // COMPONENT-SPECIFIC RADIUS HELPERS
  // ============================================

  static double getButtonRadius(bool small) => small ? md : lg;
  static double getInputRadius(bool small) => small ? md : lg;
  static double getCardRadius(bool small) => small ? lg : xl;
  static double getAvatarRadius(bool small) => small ? md : lg;
  static double getBadgeRadius(bool pill) => pill ? full : sm;
  static double getChipRadius(bool pill) => pill ? full : sm;
  static double getModalRadius(bool fullScreen) => fullScreen ? none : xl2;
  static double getDialogRadius() => xl2;
  static double getBottomSheetRadius(bool fullScreen) => fullScreen ? none : xl2;
  static double getSnackbarRadius() => md;
  static double getTooltipRadius() => default_;
  static double getMenuRadius() => md;
  static double getPopoverRadius() => md;

  // AGENTS.md specific helpers
  static double getCardCornerRadius() => xl;     // 12px cards
  static double getBadgeCornerRadius() => md;    // 6-8px badges
  static double getButtonCornerRadius() => lg;   // 8px buttons
  static double getLargeButtonCornerRadius() => xl; // 12-20px large buttons
}
