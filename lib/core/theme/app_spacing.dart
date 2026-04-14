import 'package:flutter/material.dart';

/// App Spacing - Adapted for shadcn_ui
/// Using Shadcn/Tailwind spacing conventions (4px base unit)
/// Based on AGENTS.md guidelines
class AppSpacing {
  // ============================================
  // BASE UNIT (4px)
  // ============================================
  static const double base = 4.0;

  // ============================================
  // SINGLE VALUES (Tailwind/Shadcn style)
  // ============================================
  static const double none = 0;        // 0px
  static const double px = 1;          // 1px
  static const double xs = base;       // 4px
  static const double sm = base * 2;   // 8px
  static const double md = base * 3;   // 12px
  static const double lg = base * 4;   // 16px
  static const double xl = base * 6;   // 24px
  static const double xl2 = base * 8;  // 32px
  static const double xl3 = base * 10; // 40px
  static const double xl4 = base * 12; // 48px

  // Legacy aliases for backward compatibility
  static const double default_ = lg;   // 16px
  static const double xxl = xl4;       // 48px

  // Shadcn/Tailwind specific spacing values
  static const double space0 = none;
  static const double space1 = px;
  static const double space2 = xs;
  static const double space3 = 6;      // 6px (1.5 * base)
  static const double space4 = sm;
  static const double space5 = 10;     // 10px (2.5 * base)
  static const double space6 = md;
  static const double space7 = 14;     // 14px (3.5 * base)
  static const double space8 = lg;
  static const double space9 = 18;     // 18px (4.5 * base)
  static const double space10 = 20;    // 20px (5 * base)
  static const double space11 = 22;    // 22px (5.5 * base)
  static const double space12 = xl;
  static const double space14 = 28;    // 28px (7 * base)
  static const double space16 = xl2;
  static const double space20 = 40;    // 40px (10 * base)
  static const double space24 = xl4;

  // ============================================
  // ALL SIDES PADDING
  // ============================================
  static const EdgeInsets noneAll = EdgeInsets.all(none);
  static const EdgeInsets pxAll = EdgeInsets.all(px);
  static const EdgeInsets xsAll = EdgeInsets.all(xs);
  static const EdgeInsets smAll = EdgeInsets.all(sm);
  static const EdgeInsets mdAll = EdgeInsets.all(md);
  static const EdgeInsets lgAll = EdgeInsets.all(lg);
  static const EdgeInsets xlAll = EdgeInsets.all(xl);
  static const EdgeInsets xl2All = EdgeInsets.all(xl2);
  static const EdgeInsets xl3All = EdgeInsets.all(xl3);
  static const EdgeInsets xl4All = EdgeInsets.all(xl4);

  // Legacy alias
  static const EdgeInsets defaultAll = EdgeInsets.all(default_);

  // ============================================
  // HORIZONTAL PADDING
  // ============================================
  static const EdgeInsets pxHorizontal = EdgeInsets.symmetric(horizontal: px);
  static const EdgeInsets xsHorizontal = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets smHorizontal = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets mdHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets lgHorizontal = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets xlHorizontal = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets xl2Horizontal = EdgeInsets.symmetric(horizontal: xl2);

  // Legacy alias
  static const EdgeInsets defaultHorizontal = EdgeInsets.symmetric(horizontal: default_);

  // ============================================
  // VERTICAL PADDING
  // ============================================
  static const EdgeInsets pxVertical = EdgeInsets.symmetric(vertical: px);
  static const EdgeInsets xsVertical = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets smVertical = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets mdVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets lgVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets xlVertical = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets xl2Vertical = EdgeInsets.symmetric(vertical: xl2);

  // Legacy alias
  static const EdgeInsets defaultVertical = EdgeInsets.symmetric(vertical: default_);

  // ============================================
  // SYMMETRIC PADDING (x, y)
  // ============================================
  static const EdgeInsets smLg = EdgeInsets.symmetric(horizontal: sm, vertical: lg);
  static const EdgeInsets mdLg = EdgeInsets.symmetric(horizontal: md, vertical: lg);
  static const EdgeInsets lgMd = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets xlMd = EdgeInsets.symmetric(horizontal: xl, vertical: md);
  static const EdgeInsets lgSm = EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  // ============================================
  // SCREEN PADDING (AGENTS.md: 16px phone / 24px tablet)
  // ============================================
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets screenPaddingTablet = EdgeInsets.all(xl);

  // ============================================
  // COMPONENT SPECIFIC PADDING
  // ============================================

  // Card padding (AGENTS.md: 20px phone / 24px tablet)
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingTablet = EdgeInsets.all(xl);

  // Input padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);
  static const EdgeInsets inputPaddingSm = EdgeInsets.symmetric(horizontal: md, vertical: xs);

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets buttonPaddingSm = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets buttonPaddingLg = EdgeInsets.symmetric(horizontal: xl, vertical: lg);

  // Badge padding
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(horizontal: sm, vertical: px);
  static const EdgeInsets badgePaddingMd = EdgeInsets.symmetric(horizontal: md, vertical: xs);

  // Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: sm, vertical: xs);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets listItemPaddingTablet = EdgeInsets.all(xl);

  // Dialog/Modal padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl2);
  static const EdgeInsets modalPadding = EdgeInsets.all(lg);

  // Snackbar padding
  static const EdgeInsets snackbarPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Tooltip padding
  static const EdgeInsets tooltipPadding = EdgeInsets.symmetric(horizontal: sm, vertical: xs);

  // Avatar padding
  static const EdgeInsets avatarPadding = EdgeInsets.all(xs);

  // Icon button padding
  static const EdgeInsets iconButtonPadding = EdgeInsets.all(sm);

  // ============================================
  // GAP HELPERS
  // ============================================
  static const double gapXs = xs;
  static const double gapSm = sm;
  static const double gapMd = md;
  static const double gapLg = lg;
  static const double gapXl = xl;
  static const double gapXl2 = xl2;
  static const double gapXl3 = xl3;
  static const double gapXl4 = xl4;

  // Shadcn/Tailwind gap names
  static const double gap0 = space0;
  static const double gap1 = space1;
  static const double gap2 = space2;
  static const double gap3 = space3;
  static const double gap4 = space4;
  static const double gap5 = space5;
  static const double gap6 = space6;
  static const double gap7 = space7;
  static const double gap8 = space8;
  static const double gap9 = space9;
  static const double gap10 = space10;
  static const double gap11 = space11;
  static const double gap12 = space12;

  // ============================================
  // SIZE HELPERS
  // ============================================

  // Icon sizes (AGENTS.md: scale appropriately)
  static const double iconSizeXs = 12;
  static const double iconSizeSm = 16;
  static const double iconSizeMd = 20;
  static const double iconSizeLg = 24;
  static const double iconSizeXl = 32;
  static const double iconSizeXl2 = 40;

  // Avatar sizes
  static const double avatarSizeXs = 24;
  static const double avatarSizeSm = 32;
  static const double avatarSizeMd = 40;
  static const double avatarSizeLg = 48;
  static const double avatarSizeXl = 64;
  static const double avatarSizeXl2 = 80;

  // Button heights (Shadcn style)
  static const double buttonHeightSm = 32;
  static const double buttonHeightMd = 40;
  static const double buttonHeightLg = 48;

  // Input heights
  static const double inputHeightSm = 32;
  static const double inputHeightMd = 40;
  static const double inputHeightLg = 48;

  // Min touch target (accessibility)
  static const double minTouchTarget = 44;

  // ============================================
  // MAX CONTENT WIDTHS (Shadcn/Tailwind)
  // ============================================
  static const double maxWidthXs = 320;
  static const double maxWidthSm = 384;
  static const double maxWidthMd = 448;
  static const double maxWidthLg = 512;
  static const double maxWidthXl = 576;
  static const double maxWidthXl2 = 672;
  static const double maxWidthXl3 = 768;
  static const double maxWidthXl4 = 896;
  static const double maxWidthXl5 = 1024;
  static const double maxWidthXl6 = 1152;
  static const double maxWidthXl7 = 1280;

  // ============================================
  // CONTAINER PADDING
  // ============================================
  static const double containerPaddingSm = sm;
  static const double containerPaddingMd = lg;
  static const double containerPaddingLg = xl;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create EdgeInsets with custom value
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Create EdgeInsets with symmetric values
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Create EdgeInsets with only specific sides
  static EdgeInsets only({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  /// Create SizedBox with square gap
  static SizedBox gap(double value) => SizedBox(width: value, height: value);

  /// Create SizedBox with horizontal gap
  static SizedBox gapX(double value) => SizedBox(width: value);

  /// Create SizedBox with vertical gap
  static SizedBox gapY(double value) => SizedBox(height: value);

  // ============================================
  // PREDEFINED GAP WIDGETS (Horizontal)
  // ============================================
  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wXl = SizedBox(width: xl);
  static const SizedBox wXl2 = SizedBox(width: xl2);
  static const SizedBox wXl3 = SizedBox(width: xl3);
  static const SizedBox wXl4 = SizedBox(width: xl4);

  // ============================================
  // PREDEFINED GAP WIDGETS (Vertical)
  // ============================================
  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXl2 = SizedBox(height: xl2);
  static const SizedBox hXl3 = SizedBox(height: xl3);
  static const SizedBox hXl4 = SizedBox(height: xl4);

  // ============================================
  // DIVIDER & SECTION SPACING
  // ============================================
  static const SizedBox dividerSpace = SizedBox(height: md);
  static const SizedBox sectionSpace = SizedBox(height: lg);
  static const SizedBox sectionSpaceLg = SizedBox(height: xl);
  static const SizedBox pageSpace = SizedBox(height: xl2);

  // ============================================
  // RESPONSIVE HELPERS
  // ============================================

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding({required bool isTablet, double phone = 16, double tablet = 24}) {
    return EdgeInsets.all(isTablet ? tablet : phone);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontal({required bool isTablet, double phone = 16, double tablet = 24}) {
    return EdgeInsets.symmetric(horizontal: isTablet ? tablet : phone);
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVertical({required bool isTablet, double phone = 16, double tablet = 24}) {
    return EdgeInsets.symmetric(vertical: isTablet ? tablet : phone);
  }

  /// Get responsive value
  static double getResponsive({required bool isTablet, required double phone, required double tablet}) {
    return isTablet ? tablet : phone;
  }
}
