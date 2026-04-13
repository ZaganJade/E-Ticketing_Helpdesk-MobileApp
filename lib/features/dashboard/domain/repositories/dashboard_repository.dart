import 'package:dartz/dartz.dart';

import '../entities/dashboard_stats.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Failure classes for dashboard operations
abstract class DashboardFailure {
  final String message;
  const DashboardFailure(this.message);
}

class ServerFailure extends DashboardFailure {
  const ServerFailure([String message = 'Terjadi kesalahan server']) : super(message);
}

class NetworkFailure extends DashboardFailure {
  const NetworkFailure() : super('Koneksi internet bermasalah');
}

class UnauthorizedFailure extends DashboardFailure {
  const UnauthorizedFailure() : super('Anda tidak memiliki akses');
}

class UnknownDashboardFailure extends DashboardFailure {
  const UnknownDashboardFailure([String message = 'Terjadi kesalahan']) : super(message);
}

/// Interface for dashboard repository
abstract class DashboardRepository {
  /// Get dashboard statistics for the current user
  Future<Either<DashboardFailure, DashboardStats>> getDashboardStats();

  /// Get recent tickets (limit to 5)
  Future<Either<DashboardFailure, List<Tiket>>> getRecentTiket({int limit = 5});

  /// Get open tickets that need to be handled (for helpdesk)
  Future<Either<DashboardFailure, List<Tiket>>> getTiketTerbuka();

  /// Get tickets assigned to current helpdesk
  Future<Either<DashboardFailure, List<Tiket>>> getTiketSaya();

  /// Take/assign an open ticket (for helpdesk)
  Future<Either<DashboardFailure, Tiket>> ambilTiket(String tiketId);

  /// Get user statistics (for admin)
  Future<Either<DashboardFailure, Map<String, int>>> getUserStats();
}
