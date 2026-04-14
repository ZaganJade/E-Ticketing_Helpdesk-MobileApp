# E-Ticketing Helpdesk UI Design Guide

## Overview
This document establishes the UI design standards for the E-Ticketing Helpdesk Flutter application. All UI redesigns must follow these patterns to ensure consistency across the entire application.

## Core Design Principles

### 1. Design System: "Refined Glassmorphism"
- **Aesthetic**: Clean, professional appearance with subtle depth
- **Philosophy**: Soft gradients, consistent spacing, intuitive visual hierarchy
- **Key Characteristics**:
  - Soft gradient backgrounds with subtle transparency (0.1-0.2 alpha)
  - Consistent rounded corners (12px cards, 6-8px badges, 12-20px buttons)
  - Soft shadows for depth (avoid harsh borders)
  - Status colors as accent indicators, not overwhelming
  - Clean typography with clear hierarchy

### 2. Library Requirements
**MANDATORY**: Use `shadcn_ui` (version 0.53.5+) for all UI components.

```yaml
dependencies:
  shadcn_ui: ^0.53.5
```

**Key shadcn_ui Components to Use**:
- `ShadCard` - Primary container component
- `ShadButton`, `ShadButton.outline`, `ShadButton.ghost` - All button variants
- `ShadBadge` - Status indicators (optional, can use custom containers)
- `ShadInput`, `ShadSelect`, `ShadDialog` - Forms and overlays

**Important shadcn_ui 0.53.5+ API Notes**:
- Use `ShadApp.router` instead of deprecated `ShadApp.materialRouter`
- `ShadBorder` uses `ShadBorderSide` for each edge (not `color` parameter directly)
- Button sizes: `ShadButtonSize.sm`, `ShadButtonSize.lg` (no `defaultSize`)

## Design System Specifications

### Color Palette

**Status Colors** (from `ShadcnTheme`):
- `statusOpen` - Rose/Red (#f43f5e) - For "Terbuka" status
- `statusInProgress` - Amber/Orange (#f59e0b) - For "Diproses" status
- `statusDone` - Emerald/Green (#10b981) - For "Selesai" status

**Semantic Colors**:
- `accent` - Primary brand color (Indigo #6366f1)
- `muted` - Light mode card background (#f1f5f9)
- `darkMuted` - Dark mode card background (#1e293b)
- `border` - Light mode borders (#e2e8f0)
- `darkBorder` - Dark mode borders (#334155)

**Usage Patterns**:
- Card backgrounds: `ShadcnTheme.muted` / `darkMuted`
- Borders: `ShadcnTheme.border` / `darkBorder` (1px width)
- Status accents: Use with `withValues(alpha: 0.1)` for subtle backgrounds
- Text: `ShadTheme.of(context).colorScheme.foreground` / `mutedForeground`

### Typography Scale

| Level | Size (Phone) | Size (Tablet) | Weight | Letter Spacing |
|-------|-------------|---------------|--------|----------------|
| Section Title | 16px | 18px | w600 | -0.3 |
| Card Title | 14px | 15px | w600 | - |
| Body | 14px | 15px | w500 | - |
| Muted/Caption | 13px | 14px | w400 | - |
| Small/Badge | 11px | 12px | w500 | - |
| Button Text | 12-14px | 13-16px | w600 | - |

### Spacing Standards

**Page-Level Spacing**:
- Horizontal padding: 16px (phone) / 24px (tablet)
- Section vertical gaps: 8-16px

**Card Internal Spacing**:
- Card padding: 20px (phone) / 24px (tablet)
- Between card sections: 16px (phone) / 20px (tablet)
- Element to element: 8-12px

**Card Margins**:
- Between cards: 8px vertical

### Card Standard Pattern

All cards must follow this structure:

```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
  child: ShadCard(
    padding: EdgeInsets.all(isTablet ? 24 : 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon in gradient circle + title + optional badge
        // Content with consistent spacing
      ],
    ),
  ),
)
```

**Header Pattern (Consistent across all widgets)**:
```dart
Row(
  children: [
    // Icon in gradient circle (40x40 phone, 44x44 tablet)
    Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withValues(alpha: 0.2),
            themeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: themeColor, size: isTablet ? 24 : 20),
    ),
    SizedBox(width: isTablet ? 16 : 12),
    // Title text
    Text(
      'Section Title',
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w600,
        color: ShadTheme.of(context).colorScheme.foreground,
        letterSpacing: -0.3,
      ),
    ),
    const Spacer(),
    // Optional: Count badge or action button
  ],
)
```

### List Item Card Pattern

For ticket lists, notification lists, or any item list:

```dart
Container(
  margin: const EdgeInsets.only(bottom: 8),
  decoration: BoxDecoration(
    color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
      width: 1,
    ),
  ),
  child: IntrinsicHeight(
    child: Row(
      children: [
        // Left accent bar with status color
        Container(
          width: 4,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Column(...),
          ),
        ),
      ],
    ),
  ),
)
```

### Button Patterns

**Primary Action Button**:
```dart
ShadButton(
  backgroundColor: ShadcnTheme.accent,
  onPressed: onAction,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: isTablet ? 20 : 18, color: Colors.white),
      const SizedBox(width: 8),
      Text(
        'Button Text',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  ),
)
```

**Secondary/Outline Button**:
```dart
ShadButton.outline(
  onPressed: onAction,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: isTablet ? 20 : 18),
      const SizedBox(width: 8),
      Text(
        'Button Text',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
```

**Ghost/Link Button**:
```dart
ShadButton.ghost(
  size: ShadButtonSize.sm,
  onPressed: onAction,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Link Text',
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w500,
          color: ShadcnTheme.accent,
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        Icons.arrow_forward_rounded,
        size: isTablet ? 16 : 14,
        color: ShadcnTheme.accent,
      ),
    ],
  ),
)
```

**Responsive Button Layout**:
Use `LayoutBuilder` for adaptive button arrangements:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    // For wider screens, buttons side by side
    if (constraints.maxWidth >= 400) {
      return Row(
        children: [
          Expanded(flex: 2, child: primaryButton),
          const SizedBox(width: 12),
          Expanded(child: secondaryButton),
        ],
      );
    }
    // For narrow screens, stack buttons vertically
    return Column(
      children: [
        SizedBox(width: double.infinity, child: primaryButton),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: secondaryButton),
      ],
    );
  },
)
```

### Status Badge Pattern

```dart
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
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    ],
  ),
)
```

**Status Icons**:
- Terbuka/Open: `Icons.radio_button_unchecked_rounded`
- Diproses/In Progress: `Icons.sync_rounded`
- Selesai/Done: `Icons.check_circle_rounded`

### Count Badge Pattern

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: themeColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    '$count',
    style: TextStyle(
      fontSize: isTablet ? 14 : 12,
      fontWeight: FontWeight.w600,
      color: themeColor,
    ),
  ),
)
```

## Responsive Design Requirements

### Device Breakpoints

```dart
final size = MediaQuery.of(context).size;
final isTablet = size.width >= 600;
final isSmallPhone = size.width < 360;
```

### Responsive Patterns

**Every widget must implement responsive sizing for**:
1. **Padding**: Scale from phone (16-20px) to tablet (24px)
2. **Font sizes**: Increase 1-2px on tablets
3. **Icon sizes**: Scale appropriately (20→24, 12→16, etc.)
4. **Spacing**: Increase gaps on larger screens
5. **Layout**: Use `LayoutBuilder` for complex layouts

**Standard responsive values**:
```dart
// In every widget's build method:
final size = MediaQuery.of(context).size;
final isTablet = size.width >= 600;
final horizontalPadding = isTablet ? 24.0 : 16.0;

// Apply to:
// - Container margins
// - ShadCard padding
// - Text font sizes
// - Icon sizes
// - Internal spacing
```

### Skeleton Loading States

All widgets must have responsive skeleton states that match the final layout:

```dart
Widget _buildSkeletonList(BuildContext context, bool isDark, bool isTablet) {
  return Column(
    children: List.generate(3, (index) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: // Match the exact structure of loaded content
    )),
  );
}
```

## Section-Specific Patterns

### Dashboard Sections (Reference Implementation)

The dashboard widgets serve as the reference implementation:
- `greeting_section.dart` - User greeting with avatar
- `stat_card.dart` - Statistics overview with animated counters
- `quick_actions.dart` - Action buttons
- `progress_indicator.dart` - Donut chart with legend
- `tiket_recent_list.dart` - Recent tickets list
- `tiket_saya_section.dart` - Assigned tickets list
- `tiket_terbuka_section.dart` - Open tickets list

### Ticket Lists Pattern
All ticket lists must:
- Use the same card structure (muted background, left accent bar)
- Show status badge with appropriate color
- Display title with single-line ellipsis
- Show metadata (creator, date) in muted style
- Support tap/click actions with `GestureDetector`

### Forms and Inputs Pattern
```dart
ShadInput(
  placeholder: const Text('Placeholder text'),
  // Use ShadTheme colors for consistency
)
```

### Dialogs Pattern
```dart
ShadDialog(
  title: const Text('Dialog Title'),
  description: const Text('Description text'),
  child: // Content
  actions: [
    ShadButton.outline(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    ShadButton(
      onPressed: onConfirm,
      child: const Text('Confirm'),
    ),
  ],
)
```

## Theme Consistency Requirements

### Light/Dark Mode Support
Every widget must properly handle both themes:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Use appropriate colors:
// Backgrounds: isDark ? darkMuted : muted
// Borders: isDark ? darkBorder : border
// Text: ShadTheme.of(context).colorScheme.foreground
```

### Animation Guidelines
- Use subtle animations (200-800ms duration)
- Prefer `AnimatedCount` for number changes
- Use `AnimatedBuilder` for custom animations
- Card interactions: no hover animations on mobile

## File Naming and Organization

### Naming Conventions
- Widgets: `descriptive_noun.dart` (e.g., `ticket_list.dart`)
- Sections: `feature_section.dart` (e.g., `greeting_section.dart`)
- Pages: `feature_page.dart` (e.g., `dashboard_page.dart`)

### Widget Classes
- Public widgets: `PascalCase` (e.g., `TicketList`)
- Private widgets: `_PascalCase` (e.g., `_TicketCard`)
- Skeleton widgets: `WidgetNameSkeleton` (e.g., `TicketListSkeleton`)

## Implementation Checklist

When redesigning any section, verify:

- [ ] Uses shadcn_ui components exclusively (no raw Material widgets except Icons)
- [ ] Implements `isTablet` responsive sizing
- [ ] Supports light and dark themes
- [ ] Has proper loading skeleton state
- [ ] Has empty state UI
- [ ] Uses correct status colors for ticket states
- [ ] Follows card padding standards (20/24px)
- [ ] Uses correct typography scale
- [ ] Has consistent header pattern with icon + title
- [ ] Buttons follow responsive layout patterns
- [ ] No flutter analyze errors in new code

## Common Mistakes to Avoid

1. **Don't use Material widgets directly**: Use `ShadCard`, not `Card`; `ShadButton`, not `ElevatedButton`
2. **Don't hardcode sizes**: Always check `isTablet` for responsive sizing
3. **Don't forget empty states**: Every list needs an empty state design
4. **Don't ignore skeletons**: Loading states must match the final layout structure
5. **Don't use flat colors**: Use gradient backgrounds for icons/status indicators
6. **Don't use harsh borders**: Prefer 1px subtle borders or no borders

## Reference Files

**Dashboard (Complete Reference)**:
- `lib/features/dashboard/presentation/widgets/greeting_section.dart`
- `lib/features/dashboard/presentation/widgets/stat_card.dart`
- `lib/features/dashboard/presentation/widgets/quick_actions.dart`
- `lib/features/dashboard/presentation/widgets/progress_indicator.dart`
- `lib/features/dashboard/presentation/widgets/tiket_recent_list.dart`
- `lib/features/dashboard/presentation/widgets/tiket_saya_section.dart`
- `lib/features/dashboard/presentation/widgets/tiket_terbuka_section.dart`

**Theme Configuration**:
- `lib/core/theme/shadcn_theme.dart`

---

**Last Updated**: Based on dashboard redesign with shadcn_ui 0.53.5
**Enforced By**: All UI agents must follow this guide
