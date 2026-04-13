import 'package:flutter/material.dart';

/// App Border Radius Constants
/// Defines consistent border radius values across the app
class AppBorderRadius {
  // Small radius - for small elements like chips, badges
  static const double xs = 4.0;
  static final BorderRadius xsRadius = BorderRadius.circular(xs);

  // Default radius - for buttons, inputs
  static const double default_ = 8.0;
  static final BorderRadius defaultRadius = BorderRadius.circular(default_);

  // Button radius - for all button types
  static const double button = 8.0;
  static final BorderRadius buttonRadius = BorderRadius.circular(button);

  // Input radius - for text fields
  static const double input = 8.0;
  static final BorderRadius inputRadius = BorderRadius.circular(input);

  // Card radius - for cards
  static const double card = 12.0;
  static final BorderRadius cardRadius = BorderRadius.circular(card);

  // Medium radius - for modals, dialogs
  static const double md = 12.0;
  static final BorderRadius mdRadius = BorderRadius.circular(md);

  // Large radius - for bottom sheets, larger cards
  static const double lg = 16.0;
  static final BorderRadius lgRadius = BorderRadius.circular(lg);

  // Modal radius - for dialogs, modals
  static const double modal = 16.0;
  static final BorderRadius modalRadius = BorderRadius.circular(modal);

  // Badge radius - for badges, pills
  static const double badge = 16.0;
  static final BorderRadius badgeRadius = BorderRadius.circular(badge);

  // Extra large radius - for large containers
  static const double xl = 20.0;
  static final BorderRadius xlRadius = BorderRadius.circular(xl);

  // Full radius - for circular elements
  static const double full = 999.0;
  static final BorderRadius fullRadius = BorderRadius.circular(full);

  // Specific shape borders
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: cardRadius,
  );

  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: buttonRadius,
  );

  static final RoundedRectangleBorder inputShape = RoundedRectangleBorder(
    borderRadius: inputRadius,
  );

  static final RoundedRectangleBorder modalShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: const Radius.circular(modal),
    ),
  );

  static final RoundedRectangleBorder bottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: const Radius.circular(lg),
    ),
  );
}
