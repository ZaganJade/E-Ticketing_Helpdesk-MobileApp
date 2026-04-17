import 'package:dartz/dartz.dart';

import '../entities/helpdesk_dashboard_stats.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Failure classes for helpdesk dashboard operations
abstract class HelpdeskDashboardFailure {
  final String message;
  const HelpdeskDashboardFailure(this.message);
}

class HelpdeskServerFailure extends HelpdeskDashboardFailure {
  const HelpdeskServerFailure([String message = 'Terjadi kesalahan server'])
      : super(message);
}

class HelpdeskNetworkFailure extends HelpdeskDashboardFailure {
  const HelpdeskNetworkFailure() : super('Koneksi internet bermasalah');
}

class HelpdeskUnauthorizedFailure extends HelpdeskDashboardFailure {
  const HelpdeskUnauthorizedFailure() : super('Anda tidak memiliki akses');
}

class HelpdeskUnknownFailure extends HelpdeskDashboardFailure {
  const HelpdeskUnknownFailure([String message = 'Terjadi kesalahan'])
      : super(message);
}

/// Interface for helpdesk dashboard repository
abstract class HelpdeskDashboardRepository {
  /// Get helpdesk dashboard statistics
  Future<Either<HelpdeskDashboardFailure, HelpdeskDashboardStats>>
      getHelpdeskDashboardStats();

  /// Get open tickets that need to be handled
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getTiketTerbuka();

  /// Get tickets assigned to current helpdesk
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getTiketSaya();

  /// Take/assign an open ticket
  Future<Either<HelpdeskDashboardFailure, Tiket>> ambilTiket(
    String tiketId,
  );

  /// Get recent tickets (for helpdesk view)
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getRecentTiket({
    int limit = 5,
  });

  /// Get helpdesk performance metrics
  Future<Either<HelpdeskDashboardFailure, Map<String, dynamic>>>
      getHelpdeskPerformance();
}
