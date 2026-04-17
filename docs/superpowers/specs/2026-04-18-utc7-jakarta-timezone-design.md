# UTC+7 Jakarta Timezone Global Implementation

## Overview
Implement UTC+7 (Jakarta timezone) as the global timezone setting for the entire e-ticketing helpdesk application. All dates will be stored and displayed in Jakarta time with both relative and absolute formatting options.

## Architecture

### Core Components
- **DateService Interface**: Contract for all date/time operations
- **DateServiceImpl**: Main implementation with Jakarta timezone configuration
- **Timezone Enum**: Support for future timezone expansion
- **Jakarta Timezone Constants**: UTC+7 offset, WIB indicator

### Dependency Injection
- Register DateService as singleton in GetIt DI container
- Constructor injection in Cubits and services
- Direct access via `getIt<DateService>()` in widgets

## Date Formatting Capabilities

### Relative Time Formatting (Indonesian)
```dart
formatRelativeTime(DateTime dateTime)
// Returns:
// - "Baru saja" (less than 1 minute)
// - "X menit lalu" (1-59 minutes)  
// - "X jam lalu" (1-23 hours)
// - "X hari lalu" (1-29 days)
// - Falls back to absolute format for 30+ days
```

### Absolute Time Formatting (Indonesian with WIB)
```dart
formatAbsoluteTime(DateTime dateTime)
// Returns: "18 April 2026, 14:30 WIB"
// Format: "DD Month YYYY, HH:MM WIB"
// Month in Indonesian (Januari, Februari, etc.)
```

### Additional Utility Methods
- `formatDate(DateTime)` - "18 April 2026"
- `formatTime(DateTime)` - "14:30 WIB"  
- `formatDateTimeShort(DateTime)` - "18/04/26 14:30"
- `toJakartaTime(DateTime)` - Convert any DateTime to Jakarta timezone
- `fromJakartaTime(DateTime)` - Convert Jakarta time back if needed
- `getCurrentJakartaTime()` - Current time in Jakarta timezone

## Database Storage

### Storage Strategy
- All DateTime objects stored as ISO8601 strings in Supabase
- Stored times interpreted as Jakarta timezone (UTC+7)
- No timezone conversion during storage - times stored as-is

### Storage Methods
- `formatForDatabase(DateTime)` - "2026-04-18T14:30:00"
- `parseFromDatabase(String)` - Parse ISO8601 string as Jakarta time

### Model Updates Required
- TiketModel: Update dibuatPada field handling
- NotifikasiModel: Update dibuatPada field handling
- KomentarModel: Update dibuatPada field handling
- All other models with DateTime fields

## UI Components Requiring Updates

### Ticket Components
- TiketCard: Replace _getRelativeTime() and _formatDate()
- TiketCardCompact: Replace date/time formatting
- TiketDetailPage: Update all date displays

### Notification Components  
- NotifikasiCard: Replace _getRelativeTime()

### Comment Components
- KomentarCard: Replace _formatRelativeTime()

### Dashboard Components
- TiketRecentList: Update date formatting
- RecentTicketsSection: Update date formatting
- All other components with date/time displays

## Implementation Plan

### Phase 1: Core Infrastructure
1. Create DateService interface
2. Implement DateServiceImpl with Jakarta timezone
3. Add Indonesian locale configuration
4. Create timezone enum and constants

### Phase 2: DI Integration  
1. Update lib/core/di/injection.dart
2. Register DateService as singleton
3. Test DI registration

### Phase 3: Model Updates
1. Update TiketModel fromJson/toJson methods
2. Update NotifikasiModel fromJson/toJson methods  
3. Update KomentarModel fromJson/toJson methods
4. Update any other models with DateTime fields

### Phase 4: Widget Updates
1. Update TiketCard widget
2. Update TiketCardCompact widget
3. Update NotifikasiCard widget
4. Update KomentarCard widget
5. Update TiketDetailPage
6. Update all dashboard widgets with dates
7. Update any other widgets with date displays

### Phase 5: Testing & Validation
1. Test timezone conversion accuracy
2. Test relative time formatting edge cases
3. Test absolute time formatting
4. Verify database storage/retrieval
5. Test with existing data
6. UI testing for all updated components

## Configuration

### Jakarta Timezone Settings
- Offset: UTC+7
- Timezone Name: "WIB" (Waktu Indonesia Barat)
- Locale: "id_ID" (Indonesian)
- Date Format: "dd MMMM yyyy, HH:mm WIB"
- Relative Time Threshold: 30 days

## Dependencies
- `intl: ^0.20.2` (already in pubspec.yaml)
- `get_it: ^9.2.1` (already in pubspec.yaml)

## Backward Compatibility
- Existing ISO8601 strings in database will be interpreted as Jakarta time
- No data migration required
- UI will display same times with consistent Jakarta timezone

## Future Extensibility
- Timezone enum allows easy addition of other timezones
- Service-based architecture allows easy implementation changes
- Configuration can be externalized if needed
- Supports multi-timezone applications if requirements change