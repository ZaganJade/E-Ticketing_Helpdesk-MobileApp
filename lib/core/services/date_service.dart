import 'package:intl/intl.dart';

enum Timezone {
  utc,
  jakarta,
}

class DateService {
  final Timezone _timezone;
  final String _locale;
  final Duration _jakartaOffset = const Duration(hours: 7);

  DateService({
    Timezone timezone = Timezone.jakarta,
    String locale = 'id_ID',
  })  : _timezone = timezone,
        _locale = locale;

  /// Get current time in configured timezone
  DateTime getCurrentTime() {
    if (_timezone == Timezone.jakarta) {
      return DateTime.now().add(_jakartaOffset);
    }
    return DateTime.now().toUtc();
  }

  /// Convert DateTime to Jakarta timezone
  DateTime toJakartaTime(DateTime dateTime) {
    return dateTime.add(_jakartaOffset);
  }

  /// Format relative time in Indonesian
  String formatRelativeTime(DateTime dateTime) {
    final now = getCurrentTime();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} hari lalu';
    } else {
      // Fall back to absolute format for older dates
      return formatAbsoluteTime(dateTime);
    }
  }

  /// Format absolute time in Indonesian with WIB indicator
  String formatAbsoluteTime(DateTime dateTime) {
    final jakartaTime = toJakartaTime(dateTime);
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', _locale);
    return '${formatter.format(jakartaTime)} WIB';
  }

  /// Format date only in Indonesian
  String formatDate(DateTime dateTime) {
    final jakartaTime = toJakartaTime(dateTime);
    final formatter = DateFormat('dd MMMM yyyy', _locale);
    return formatter.format(jakartaTime);
  }

  /// Format time only with WIB indicator
  String formatTime(DateTime dateTime) {
    final jakartaTime = toJakartaTime(dateTime);
    final formatter = DateFormat('HH:mm', _locale);
    return '${formatter.format(jakartaTime)} WIB';
  }

  /// Format date/time in short format
  String formatDateTimeShort(DateTime dateTime) {
    final jakartaTime = toJakartaTime(dateTime);
    final formatter = DateFormat('dd/MM/yy HH:mm', _locale);
    return formatter.format(jakartaTime);
  }

  /// Format DateTime for database storage (ISO8601)
  String formatForDatabase(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse DateTime from database storage
  DateTime parseFromDatabase(String isoString) {
    return DateTime.parse(isoString);
  }
}