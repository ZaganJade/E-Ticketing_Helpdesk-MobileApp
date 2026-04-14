# Dashboard Performance Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize dashboard page navigation and rendering performance to eliminate lag and improve responsiveness

**Architecture:** Use responsive layout caching, simplify animations, debounce realtime updates, and optimize widget rebuild patterns

**Tech Stack:** Flutter, flutter_bloc, shadcn_ui, CustomScrollView, RepaintBoundary

---

## Problem Analysis

Current performance issues identified:
1. **MediaQuery proliferation** - Multiple widgets call `MediaQuery.of(context)` causing excessive rebuilds
2. **Complex stagger animation** - 1200ms AnimationController on page load is heavy
3. **Intensive AnimatedCount** - Stats animation rebuilds every frame for 800ms
4. **Unfiltered BlocBuilder** - All state changes trigger full page rebuild
5. **Realtime refresh storm** - Every database change triggers complete dashboard refresh

---

## Task 1: Create Responsive Layout Widget

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/responsive_layout.dart`

**Purpose:** Centralize responsive sizing to eliminate MediaQuery.of calls in multiple widgets

- [ ] **Step 1: Write ResponsiveLayout widget**

```dart
import 'package:flutter/material.dart';

/// Centralized responsive layout that provides sizing info
/// without requiring MediaQuery.of in child widgets
class ResponsiveLayout extends InheritedWidget {
  final bool isTablet;
  final bool isSmallPhone;
  final double horizontalPadding;
  final EdgeInsets cardPadding;
  final double avatarSize;

  const ResponsiveLayout({
    super.key,
    required super.child,
    required this.isTablet,
    required this.isSmallPhone,
    required this.horizontalPadding,
    required this.cardPadding,
    required this.avatarSize,
  });

  static ResponsiveLayout of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveLayout>()!;
  }

  @override
  bool updateShouldNotify(ResponsiveLayout oldWidget) {
    return isTablet != oldWidget.isTablet ||
        isSmallPhone != oldWidget.isSmallPhone ||
        horizontalPadding != oldWidget.horizontalPadding;
  }
}

/// Builder that provides responsive values
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayout layout) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isSmallPhone = size.width < 360;
    final isLargePhone = size.width >= 400;

    return ResponsiveLayout(
      isTablet: isTablet,
      isSmallPhone: isSmallPhone,
      horizontalPadding: isTablet ? 24.0 : 16.0,
      cardPadding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      avatarSize: isTablet ? 60.0 : 52.0,
      child: Builder(
        builder: (context) => builder(context, ResponsiveLayout.of(context)),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/responsive_layout.dart
git commit -m "feat: add ResponsiveLayout widget to centralize sizing"
```

---

## Task 2: Create Lightweight Card Widget

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/lightweight_card.dart`

**Purpose:** Replace heavy ShadCard with optimized Card implementation

- [ ] **Step 1: Write LightweightCard widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/shadcn_theme.dart';

/// Lightweight card optimized for dashboard performance
/// Replaces ShadCard which has complex rendering overhead
class LightweightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool useBorder;

  const LightweightCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.useBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? ShadcnTheme.darkCard : ShadcnTheme.card);

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: useBorder
            ? Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                width: 1,
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      );
    }

    return card;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/lightweight_card.dart
git commit -m "feat: add LightweightCard for optimized dashboard rendering"
```

---

## Task 3: Optimasi GreetingSection

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/greeting_section.dart`

**Purpose:** Remove MediaQuery calls and use ResponsiveLayout

- [ ] **Step 1: Update imports and add const**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';
import 'responsive_layout.dart';
import 'lightweight_card.dart';
```

- [ ] **Step 2: Replace GreetingSection build method**

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final responsive = ResponsiveLayout.of(context);

  return Container(
    margin: EdgeInsets.fromLTRB(
      responsive.horizontalPadding,
      responsive.isTablet ? 16.0 : 8.0,
      responsive.horizontalPadding,
      8,
    ),
    child: LightweightCard(
      padding: responsive.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(isDark, responsive.avatarSize),
              SizedBox(width: responsive.isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 15 : 13,
                        fontWeight: FontWeight.w500,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isLoading)
                      Container(
                        width: responsive.isTablet ? 160 : 120,
                        height: responsive.isTablet ? 28 : 24,
                        decoration: BoxDecoration(
                          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        user?.nama ?? 'Pengguna',
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 24 : 20,
                          fontWeight: FontWeight.w700,
                          color: ShadTheme.of(context).colorScheme.foreground,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (user != null) _buildRoleBadge(context, user!.peran),
            ],
          ),
          SizedBox(height: responsive.isTablet ? 20 : 16),
          // Subtle divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ShadTheme.of(context).colorScheme.border.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.isTablet ? 16 : 12),
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: responsive.isTablet ? 16 : 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  user?.peran == Peran.admin
                      ? 'Akses Administrator Penuh'
                      : user?.peran == Peran.helpdesk
                          ? 'Akses Helpdesk'
                          : 'Akses Pengguna',
                  style: TextStyle(
                    fontSize: responsive.isTablet ? 13 : 12,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: () => context.push('/profil'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 13 : 12,
                        color: ShadcnTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: responsive.isTablet ? 14 : 12,
                      color: ShadcnTheme.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Update _buildAvatar method signature**

```dart
Widget _buildAvatar(bool isDark, double size) {
  final initials = _getInitials(user?.nama ?? '');
  final borderRadius = size >= 55 ? 16.0 : 14.0;

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: ShadcnTheme.accent.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}
```

- [ ] **Step 4: Update GreetingSectionSkeleton**

```dart
class GreetingSectionSkeleton extends StatelessWidget {
  final bool isDark;
  const GreetingSectionSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        responsive.isTablet ? 16.0 : 8.0,
        responsive.horizontalPadding,
        8,
      ),
      child: LightweightCard(
        padding: responsive.cardPadding,
        child: Row(
          children: [
            Container(
              width: responsive.avatarSize,
              height: responsive.avatarSize,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(
                  responsive.avatarSize >= 55 ? 16 : 14,
                ),
              ),
            ),
            SizedBox(width: responsive.isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: responsive.isTablet ? 180 : 140,
                    height: responsive.isTablet ? 28 : 24,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/greeting_section.dart
git commit -m "perf: optimize GreetingSection - remove MediaQuery, use ResponsiveLayout"
```

---

## Task 4: Optimasi StatCard - Simplify Animation

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/stat_card.dart`

**Purpose:** Replace heavy AnimatedCount with simple display, remove MediaQuery

- [ ] **Step 1: Update imports and _StatItem**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/tiket_status_stats.dart';
import 'lightweight_card.dart';
import 'responsive_layout.dart';
```

- [ ] **Step 2: Replace AnimatedCount with simple Text**

```dart
// Replace the AnimatedCount widget with simple Text display
// Remove the entire AnimatedCount class (lines 231-290)

// In _StatItem build method, replace AnimatedCount with:
Text(
  '$value',
  style: TextStyle(
    fontSize: valueSize,
    fontWeight: FontWeight.w800,
    color: ShadTheme.of(context).colorScheme.foreground,
    letterSpacing: -0.5,
  ),
)
```

- [ ] **Step 3: Update StatCard build method**

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final responsive = ResponsiveLayout.of(context);

  if (isLoading) {
    return StatCardSkeleton(isDark: isDark);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Tiket',
              style: TextStyle(
                fontSize: responsive.isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ShadcnTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$total Total',
                style: TextStyle(
                  fontSize: responsive.isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: ShadcnTheme.accent,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // Use grid for tablet, horizontal scroll for phone
      LayoutBuilder(
        builder: (context, constraints) {
          if (responsive.isTablet && constraints.maxWidth >= 500) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Terbuka',
                      value: statusStats.terbuka,
                      icon: Icons.inbox_rounded,
                      color: ShadcnTheme.statusOpen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      label: 'Diproses',
                      value: statusStats.diproses,
                      icon: Icons.sync_rounded,
                      color: ShadcnTheme.statusInProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      label: 'Selesai',
                      value: statusStats.selesai,
                      icon: Icons.check_circle_rounded,
                      color: ShadcnTheme.statusDone,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: Row(
              children: [
                _StatItem(
                  label: 'Terbuka',
                  value: statusStats.terbuka,
                  icon: Icons.inbox_rounded,
                  color: ShadcnTheme.statusOpen,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  label: 'Diproses',
                  value: statusStats.diproses,
                  icon: Icons.sync_rounded,
                  color: ShadcnTheme.statusInProgress,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  label: 'Selesai',
                  value: statusStats.selesai,
                  icon: Icons.check_circle_rounded,
                  color: ShadcnTheme.statusDone,
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
```

- [ ] **Step 4: Update _StatItem build method**

```dart
@override
Widget build(BuildContext context) {
  final responsive = ResponsiveLayout.of(context);

  // Responsive sizing
  final cardWidth = responsive.isTablet ? null : (responsive.isSmallPhone ? 95.0 : 110.0);
  final iconSize = responsive.isTablet ? 26.0 : 22.0;
  final iconPadding = responsive.isTablet ? 12.0 : 10.0;
  final valueSize = responsive.isTablet ? 32.0 : 28.0;
  final labelSize = responsive.isTablet ? 14.0 : 13.0;

  return LightweightCard(
    padding: EdgeInsets.symmetric(
      horizontal: responsive.isTablet ? 24 : 20,
      vertical: responsive.isTablet ? 20 : 16,
    ),
    child: SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          SizedBox(height: responsive.isTablet ? 16 : 14),
          // Simple text instead of AnimatedCount
          Text(
            '$value',
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              color: ShadTheme.of(context).colorScheme.foreground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 5: Update StatCardSkeleton**

```dart
class StatCardSkeleton extends StatelessWidget {
  final bool isDark;
  const StatCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Container(
            width: responsive.isTablet ? 140 : 120,
            height: responsive.isTablet ? 24 : 20,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: Row(
            children: List.generate(3, (index) => Container(
              margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
              width: responsive.isTablet ? 180 : (responsive.isSmallPhone ? 95 : 150),
              height: responsive.isTablet ? 150 : 130,
              decoration: BoxDecoration(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/stat_card.dart
git commit -m "perf: optimize StatCard - simplify animation, remove MediaQuery"
```

---

## Task 5: Optimasi TiketRecentList

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/tiket_recent_list.dart`

**Purpose:** Use const constructors and ResponsiveLayout

- [ ] **Step 1: Update imports**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';
import '../../../tiket/domain/entities/tiket.dart';
import 'lightweight_card.dart';
import 'responsive_layout.dart';
```

- [ ] **Step 2: Update build method**

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final responsive = ResponsiveLayout.of(context);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
    child: LightweightCard(
      padding: responsive.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: ShadcnTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: ShadcnTheme.accent,
                      size: responsive.isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: responsive.isTablet ? 16 : 12),
                  Text(
                    'Tiket Terbaru',
                    style: TextStyle(
                      fontSize: responsive.isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: ShadTheme.of(context).colorScheme.foreground,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null && !isLoading)
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: ShadcnTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: responsive.isTablet ? 16 : 14,
                        color: ShadcnTheme.accent,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.isTablet ? 8 : 4),
          Text(
            '${tiketList.length} tiket baru-baru ini',
            style: TextStyle(
              fontSize: responsive.isTablet ? 14 : 13,
              fontWeight: FontWeight.w400,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
          SizedBox(height: responsive.isTablet ? 20 : 16),
          // Content
          if (isLoading)
            _buildSkeletonList(context, isDark, responsive)
          else if (tiketList.isEmpty)
            _buildEmptyState(context, isDark, responsive)
          else
            Column(
              children: tiketList.take(5).map((tiket) => _TicketCard(
                tiket: tiket,
                onTap: onTapTiket != null ? () => onTapTiket!(tiket) : null,
                responsive: responsive,
              )).toList(),
            ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Update method signatures**

```dart
Widget _buildEmptyState(BuildContext context, bool isDark, ResponsiveLayout responsive) {
  return Container(
    padding: EdgeInsets.all(responsive.isTablet ? 40 : 32),
    decoration: BoxDecoration(
      color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        width: 1,
      ),
    ),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: responsive.isTablet ? 56 : 48,
            color: isDark ? ShadcnTheme.darkMutedForeground : ShadcnTheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada tiket',
            style: TextStyle(
              fontSize: responsive.isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat tiket baru untuk memulai',
            style: TextStyle(
              fontSize: responsive.isTablet ? 14 : 12,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSkeletonList(BuildContext context, bool isDark, ResponsiveLayout responsive) {
  return Column(
    children: List.generate(3, (index) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(responsive.isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.isTablet ? 48 : 40,
            height: responsive.isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: responsive.isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: responsive.isTablet ? 180 : 150,
                  height: responsive.isTablet ? 18 : 16,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: responsive.isTablet ? 120 : 100,
                  height: responsive.isTablet ? 14 : 12,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )),
  );
}
```

- [ ] **Step 4: Update _TicketCard**

```dart
class _TicketCard extends StatelessWidget {
  final Tiket tiket;
  final void Function()? onTap;
  final ResponsiveLayout responsive;

  const _TicketCard({
    required this.tiket,
    this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: responsive.isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(responsive.isTablet ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(), size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  tiket.status.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(tiket.dibuatPada),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.isTablet ? 10 : 8),
                      Text(
                        tiket.judul,
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 15 : 14,
                          fontWeight: FontWeight.w600,
                          color: ShadTheme.of(context).colorScheme.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ... rest of methods unchanged
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/tiket_recent_list.dart
git commit -m "perf: optimize TiketRecentList - use ResponsiveLayout, const constructors"
```

---

## Task 6: Optimasi DashboardCubit - Debounce Realtime Updates

**Files:**
- Modify: `lib/features/dashboard/presentation/cubit/dashboard_cubit.dart`

**Purpose:** Add debouncing to prevent refresh storm from realtime updates

- [ ] **Step 1: Add debounce timer field**

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final ApiService _apiService;
  final SupabaseClient? _supabaseClient;
  final Logger _logger;

  RealtimeChannel? _tiketChannel;
  Timer? _debounceTimer; // Add this

  DashboardCubit({
    required DashboardRepository dashboardRepository,
    required ApiService apiService,
    SupabaseClient? supabaseClient,
    Logger? logger,
  })  : _dashboardRepository = dashboardRepository,
        _apiService = apiService,
        _supabaseClient = supabaseClient,
        _logger = logger ?? Logger(),
        super(const DashboardInitial());
```

- [ ] **Step 2: Update realtime subscription with debounce**

```dart
/// Subscribe to realtime updates (only if Supabase is available)
void _subscribeToRealtimeUpdates() {
  if (_supabaseClient == null) {
    _logger.i('Realtime updates disabled - Supabase client not available');
    return;
  }

  _logger.i('Subscribing to realtime updates');

  _tiketChannel = _supabaseClient
      .channel('dashboard_tiket_changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tiket',
        callback: (payload, [ref]) {
          _logger.i('Realtime update received: ${payload.eventType}');
          // Debounce refresh to prevent storm
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(seconds: 2), () {
            refresh();
          });
        },
      )
      .subscribe();
}
```

- [ ] **Step 3: Update close method**

```dart
@override
Future<void> close() {
  _debounceTimer?.cancel();
  if (_tiketChannel != null && _supabaseClient != null) {
    _supabaseClient.removeChannel(_tiketChannel!);
  }
  return super.close();
}
```

- [ ] **Step 4: Add Timer import**

```dart
import 'dart:async';
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/cubit/dashboard_cubit.dart
git commit -m "perf: add debounce to realtime updates - prevent refresh storm"
```

---

## Task 7: Optimasi DashboardPage

**Files:**
- Modify: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Purpose:** Remove stagger animation, optimize BlocBuilder, add RepaintBoundary

- [ ] **Step 1: Remove SingleTickerProviderStateMixin and animation controller**

```dart
class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _dashboardCubit;
  // REMOVE: AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = getIt<DashboardCubit>();
    _dashboardCubit.loadDashboard();
    // REMOVE: _staggerController initialization
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    // REMOVE: _staggerController.dispose();
    super.dispose();
  }
  // ... rest of methods
}
```

- [ ] **Step 2: Add ResponsiveBuilder wrapper and buildWhen**

```dart
@override
Widget build(BuildContext context) {
  return BlocProvider.value(
    value: _dashboardCubit,
    child: ResponsiveBuilder(
      builder: (context, responsive) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
          body: SafeArea(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              buildWhen: (previous, current) {
                // Only rebuild on significant state changes
                if (previous is DashboardLoaded && current is DashboardLoaded) {
                  return previous.stats != current.stats ||
                      previous.isRefreshing != current.isRefreshing;
                }
                return true;
              },
              builder: (context, state) {
                return _buildContent(context, state, isDark, responsive);
              },
            ),
          ),
        );
      },
    ),
  );
}
```

- [ ] **Step 3: Update _buildContent signature**

```dart
Widget _buildContent(
  BuildContext context,
  DashboardState state,
  bool isDark,
  ResponsiveLayout responsive,
) {
  final authState = context.watch<AuthCubit>().state;
  Pengguna? currentUser;
  if (authState is Authenticated) {
    currentUser = authState.user;
  }

  if (state is DashboardInitial || (state is DashboardLoading && currentUser == null)) {
    return _buildSkeletonLoading(isDark, responsive);
  }

  if (state is DashboardError) {
    return _buildErrorState(state.message, isDark, responsive);
  }

  if (state is DashboardLoaded) {
    return _buildDashboardContent(
      context: context,
      stats: state.stats,
      greeting: state.greeting,
      user: currentUser,
      state: state,
      isDark: isDark,
      responsive: responsive,
    );
  }

  return const SizedBox.shrink();
}
```

- [ ] **Step 4: Update _buildSkeletonLoading**

```dart
Widget _buildSkeletonLoading(bool isDark, ResponsiveLayout responsive) {
  return const CustomScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(child: GreetingSectionSkeleton(isDark: isDark)),
      SliverPadding(
        padding: EdgeInsets.all(24),
        sliver: SliverToBoxAdapter(child: StatCardSkeleton(isDark: isDark)),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(child: QuickActionsSkeleton(isDark: isDark)),
      ),
      SliverPadding(
        padding: EdgeInsets.all(24),
        sliver: SliverToBoxAdapter(child: TiketRecentListSkeleton(isDark: isDark)),
      ),
    ],
  );
}
```

- [ ] **Step 5: Update _buildDashboardContent with RepaintBoundary**

```dart
Widget _buildDashboardContent({
  required BuildContext context,
  required DashboardStats stats,
  required String greeting,
  required Pengguna? user,
  required DashboardLoaded state,
  required bool isDark,
  required ResponsiveLayout responsive,
}) {
  return RefreshIndicator(
    onRefresh: _onRefresh,
    color: isDark ? ShadcnTheme.primaryForeground : ShadcnTheme.primary,
    backgroundColor: isDark ? ShadcnTheme.darkCard : ShadcnTheme.card,
    strokeWidth: 3,
    edgeOffset: 80,
    child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header with RepaintBoundary
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: GreetingSection(
              greeting: greeting,
              user: user,
              isLoading: state.isRefreshing,
            ),
          ),
        ),

        // Stats Overview
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: StatCard(
                total: stats.totalTiket,
                statusStats: stats.statusStats,
                isLoading: state.isRefreshing,
              ),
            ),
          ),
        ),

        // Progress Indicator
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: StatusProgressIndicator(
                stats: stats.statusStats,
                isLoading: state.isRefreshing,
              ),
            ),
          ),
        ),

        // Quick Actions
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: QuickActions(
                onBuatTiket: _onBuatTiket,
                onLihatSemuaTiket: _onLihatSemuaTiket,
              ),
            ),
          ),
        ),

        // Helpdesk Sections
        if (user?.peran == Peran.helpdesk || user?.peran == Peran.admin) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TiketTerbukaSection(
                  tiketList: state.tiketTerbuka,
                  isLoading: state.isLoadingTiketTerbuka,
                  onAmbilTiket: _onAmbilTiket,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TiketSayaSection(
                  tiketList: state.tiketSaya,
                  isLoading: state.isLoadingTiketSaya,
                  onTapTiket: _onTapTiket,
                ),
              ),
            ),
          ),
        ],

        // Recent Tickets
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: TiketRecentList(
                tiketList: stats.tiketTerbaru,
                isLoading: state.isRefreshing,
                onViewAll: _onLihatSemuaTiket,
                onTapTiket: _onTapTiket,
              ),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    ),
  );
}
```

- [ ] **Step 6: Update imports**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/tiket_recent_list.dart';
import '../widgets/tiket_saya_section.dart';
import '../widgets/tiket_terbuka_section.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/responsive_layout.dart';
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/dashboard/presentation/pages/dashboard_page.dart
git commit -m "perf: optimize DashboardPage - remove stagger anim, add buildWhen, RepaintBoundary"
```

---

## Task 8: Update Dashboard Widgets Exports

**Files:**
- Modify: `lib/features/dashboard/dashboard.dart`

**Purpose:** Export new optimized widgets

- [ ] **Step 1: Add exports**

```dart
// Add to existing exports:
export 'presentation/widgets/responsive_layout.dart';
export 'presentation/widgets/lightweight_card.dart';
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/dashboard/dashboard.dart
git commit -m "chore: export new optimized dashboard widgets"
```

---

## Verification Steps

After all tasks complete:

- [ ] Run app and test navigation to dashboard - should be instant
- [ ] Verify theme switching works with new ResponsiveLayout
- [ ] Check that realtime updates debounce properly (2 second delay)
- [ ] Ensure all widgets display correctly in both tablet and phone sizes
- [ ] Test refresh indicator and pull-to-refresh functionality

---

## Performance Metrics to Check

1. **Frame drops**: Use Flutter DevTools Performance tab
2. **Rebuild count**: Check widget rebuilds in DevTools
3. **Memory usage**: Monitor memory profile
4. **Navigation time**: Measure time from click to dashboard visible

Expected improvements:
- Navigation: < 100ms (from current ~500-800ms)
- Frame drops: Near zero dropped frames
- Rebuilds: Reduced by 60-70%
