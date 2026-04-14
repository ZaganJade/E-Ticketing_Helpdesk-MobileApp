# UI Redesign Task List

## Overview
Redesign all UI sections, menus, and theme according to AGENTS.md design guidelines using shadcn_ui library.

## Active Tasks

### 1. Login Page Redesign
**Status**: ✅ Completed  
**File**: `lib/features/auth/presentation/pages/login_page.dart`

**Requirements**:
- [ ] Replace AppInput with ShadInput
- [ ] Replace AppButton with ShadButton
- [ ] Replace AppColors with ShadcnTheme
- [ ] Add responsive sizing with isTablet detection
- [ ] Use gradient icon header pattern
- [ ] Apply card-based layout with ShadCard
- [ ] Use consistent typography scale
- [ ] Add proper loading states

**Reference**: AGENTS.md - Auth Patterns Section

---

### 2. Register Page Redesign
**Status**: ✅ Completed  
**File**: `lib/features/auth/presentation/pages/register_page.dart`

**Requirements**:
- [ ] Replace AppInput/AppPasswordInput with ShadInput
- [ ] Replace AppButton with ShadButton
- [ ] Use ShadcnTheme colors
- [ ] Add responsive sizing with isTablet
- [ ] Apply consistent card patterns
- [ ] Redesign password strength indicator
- [ ] Use gradient icon header

**Reference**: AGENTS.md - Auth Patterns Section

---

### 3. Splash Page Redesign
**Status**: ✅ Completed  
**File**: `lib/features/auth/presentation/pages/splash_page.dart`

**Requirements**:
- [ ] Use ShadcnTheme colors instead of AppColors
- [ ] Apply gradient icon pattern for logo
- [ ] Use ShadTheme text styles
- [ ] Keep animations but use consistent colors
- [ ] Use gradient background for logo icon

**Reference**: AGENTS.md - Typography & Color Usage

---

### 4. Komentar Input Redesign
**Status**: ✅ Completed  
**File**: `lib/features/komentar/presentation/widgets/komentar_input.dart`

**Requirements**:
- [ ] Replace custom input container with ShadInput
- [ ] Replace custom send button with ShadButton
- [ ] Use ShadcnTheme colors
- [ ] Add responsive sizing
- [ ] Redesign KomentarSection header with gradient icon
- [ ] Use ShadCard for container

**Reference**: AGENTS.md - Input & Button Patterns

---

### 5. Komentar Card Redesign
**Status**: ✅ Completed  
**File**: `lib/features/komentar/presentation/widgets/komentar_card.dart`

**Requirements**:
- [ ] Replace chat bubble with ShadCard or custom styled container
- [ ] Use ShadcnTheme colors for bubbles
- [ ] Apply gradient avatar pattern
- [ ] Use status badge pattern for role badges
- [ ] Add responsive sizing
- [ ] Use consistent typography

**Reference**: AGENTS.md - Card & Badge Patterns

---

### 6. Komentar List Redesign
**Status**: ✅ Completed  
**File**: `lib/features/komentar/presentation/widgets/komentar_list.dart`

**Requirements**:
- [ ] Replace skeleton loading with responsive version
- [ ] Use ShadcnTheme colors for empty/error states
- [ ] Ensure consistency with komentar_card styling
- [ ] Add responsive padding

**Reference**: AGENTS.md - Skeleton Loading & List Patterns

---

### 7. Notifikasi List Page Redesign
**Status**: ✅ Completed  
**File**: `lib/features/notifikasi/pages/notifikasi_list_page.dart`

**Requirements**:
- [ ] Replace AppAppBar with shadcn_ui equivalent
- [ ] Replace _FilterChip with ShadButton or styled container
- [ ] Use ShadcnTheme colors throughout
- [ ] Add responsive sizing
- [ ] Redesign loading states with Shadcn patterns

**Reference**: AGENTS.md - Button & Filter Patterns

---

### 8. Notifikasi Card Redesign
**Status**: ✅ Completed  
**File**: `lib/features/notifikasi/widgets/notifikasi_card.dart`

**Requirements**:
- [ ] Replace AppCard with ShadCard
- [ ] Use gradient icon pattern
- [ ] Apply muted background pattern for unread items
- [ ] Use ShadcnTheme colors
- [ ] Add responsive sizing
- [ ] Use consistent typography

**Reference**: AGENTS.md - Card Patterns & List Items

---

### 9. Notifikasi Badge Redesign
**Status**: ✅ Completed  
**File**: `lib/features/notifikasi/widgets/notifikasi_badge.dart`

**Requirements**:
- [ ] Use ShadcnTheme.statusOpen for badge color
- [ ] Apply consistent badge sizing
- [ ] Use ShadcnTheme colors for toast

**Reference**: AGENTS.md - Badge Patterns

---

## Design Guidelines Reference

### Key Requirements for All Files:
1. **shadcn_ui Components Only**: Use ShadCard, ShadButton, ShadInput (no Material widgets)
2. **Responsive Sizing**: Implement `isTablet = size.width >= 600` in all widgets
3. **Theme Colors**: Use `ShadcnTheme` colors (statusOpen, statusInProgress, statusDone, accent)
4. **Typography**: Follow size scale (phone vs tablet)
5. **Spacing**: 16px (phone) / 24px (tablet) padding
6. **Header Pattern**: Icon in gradient circle + title + optional badge
7. **Card Pattern**: Muted background, 12px radius, optional left accent bar
8. **Skeleton States**: Must match final layout structure
9. **Empty States**: Consistent empty state UI for all lists

### Color Mapping:
- `AppColors.primary` → `ShadcnTheme.accent`
- `AppColors.background` → `ShadTheme.of(context).colorScheme.background`
- `AppColors.surface` → `isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted`
- `AppColors.border` → `isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border`
- `AppColors.textPrimary` → `ShadTheme.of(context).colorScheme.foreground`
- `AppColors.textSecondary` → `ShadTheme.of(context).colorScheme.mutedForeground`
- `AppColors.error` → `ShadcnTheme.statusOpen`

### Responsive Values:
```dart
final size = MediaQuery.of(context).size;
final isTablet = size.width >= 600;
final horizontalPadding = isTablet ? 24.0 : 16.0;
```

## Verification Checklist
- [ ] No flutter analyze errors
- [ ] All Material widgets replaced with shadcn_ui
- [ ] Responsive sizing implemented
- [ ] Light/dark theme support
- [ ] Skeleton states match final layout
- [ ] Empty states implemented
- [ ] Typography follows scale
- [ ] Colors use ShadcnTheme

## Notes
- Keep all BLoC/Cubit logic intact - only redesign UI
- Maintain existing functionality and behavior
- Test on both light and dark themes
- Test responsive layout on different screen sizes
