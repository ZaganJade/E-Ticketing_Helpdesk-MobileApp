import 'package:flutter/material.dart';

class AppSpacing {
  // Base unit is 4px
  static const double xs = 4;    // 4px
  static const double sm = 8;    // 8px
  static const double md = 12;   // 12px
  static const double default_ = 16;  // 16px (renamed to avoid keyword conflict)
  static const double lg = 24;   // 24px
  static const double xl = 32;   // 32px
  static const double xxl = 48;  // 48px

  // EdgeInsets helpers
  static const EdgeInsets xsAll = EdgeInsets.all(xs);
  static const EdgeInsets smAll = EdgeInsets.all(sm);
  static const EdgeInsets mdAll = EdgeInsets.all(md);
  static const EdgeInsets defaultAll = EdgeInsets.all(default_);
  static const EdgeInsets lgAll = EdgeInsets.all(lg);
  static const EdgeInsets xlAll = EdgeInsets.all(xl);

  // Horizontal
  static const EdgeInsets xsHorizontal = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets smHorizontal = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets mdHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets defaultHorizontal = EdgeInsets.symmetric(horizontal: default_);
  static const EdgeInsets lgHorizontal = EdgeInsets.symmetric(horizontal: lg);

  // Vertical
  static const EdgeInsets xsVertical = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets smVertical = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets mdVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets defaultVertical = EdgeInsets.symmetric(vertical: default_);
  static const EdgeInsets lgVertical = EdgeInsets.symmetric(vertical: lg);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: default_);
}
