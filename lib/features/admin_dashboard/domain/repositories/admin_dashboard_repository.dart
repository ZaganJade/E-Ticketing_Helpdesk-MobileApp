import 'package:dartz/dartz.dart';

import '../entities/admin_dashboard_stats.dart';
import '../entities/helpdesk_availability.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Failure classes for admin dashboard operations
abstract class AdminDashboardFailure {
  final String message;
  const AdminDashboardFailure(this.message);
}

class AdminServerFailure extends AdminDashboardFailure {
  const AdminServerFailure([super.message = 'Terjadi kesalahan server']);
}

class AdminNetworkFailure extends AdminDashboardFailure {
  const AdminNetworkFailure() : super('Koneksi internet bermasalah');
}

class AdminUnauthorizedFailure extends AdminDashboardFailure {
  const AdminUnauthorizedFailure() : super('Anda tidak memiliki akses');
}

class AdminUnknownFailure extends AdminDashboardFailure {
  const AdminUnknownFailure([super.message = 'Terjadi kesalahan']);
}

/// Interface for admin dashboard repository
abstract class AdminDashboardRepository {
  /// Get admin dashboard statistics
  Future<Either<AdminDashboardFailure, AdminDashboardStats>>
      getAdminDashboardStats();

  /// Get user statistics by role
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getUserStatsByRole();

  /// Get helpdesk performance metrics
  Future<Either<AdminDashboardFailure, List<HelpdeskPerformance>>>
      getHelpdeskPerformance();

  /// Get all tickets (for admin view)
  Future<Either<AdminDashboardFailure, List<Tiket>>> getAllTickets({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  /// Get tickets in the global pool (TERBUKA, unassigned)
  Future<Either<AdminDashboardFailure, List<Tiket>>> getPoolTickets({
    int limit = 50,
  });

  /// Get all DIPROSES tickets (admin monitoring)
  Future<Either<AdminDashboardFailure, List<Tiket>>> getDiprosesTickets({
    int limit = 50,
  });

  /// List helpdesks with busy/free flag
  Future<Either<AdminDashboardFailure, List<HelpdeskAvailability>>>
      getAvailableHelpdesks();

  /// Assign ticket to a free helpdesk
  Future<Either<AdminDashboardFailure, Tiket>> assignTicket(
    String tiketId,
    String helpdeskId,
  );

  /// Pull a DIPROSES ticket back to the pool
  Future<Either<AdminDashboardFailure, void>> unassignTicket(String tiketId);

  /// Get recent tickets (admin view - latest system tickets)
  Future<Either<AdminDashboardFailure, List<Tiket>>> getRecentTickets({
    int limit = 10,
  });

  /// Reassign ticket to different helpdesk (alias for assign)
  Future<Either<AdminDashboardFailure, Tiket>> reassignTicket(
    String tiketId,
    String? helpdeskId,
  );

  /// Get ticket statistics by status
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getTicketStatsByStatus();
}
