import 'package:dartz/dartz.dart';

import '../entities/admin_dashboard_stats.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Failure classes for admin dashboard operations
abstract class AdminDashboardFailure {
  final String message;
  const AdminDashboardFailure(this.message);
}

class AdminServerFailure extends AdminDashboardFailure {
  const AdminServerFailure([String message = 'Terjadi kesalahan server'])
      : super(message);
}

class AdminNetworkFailure extends AdminDashboardFailure {
  const AdminNetworkFailure() : super('Koneksi internet bermasalah');
}

class AdminUnauthorizedFailure extends AdminDashboardFailure {
  const AdminUnauthorizedFailure() : super('Anda tidak memiliki akses');
}

class AdminUnknownFailure extends AdminDashboardFailure {
  const AdminUnknownFailure([String message = 'Terjadi kesalahan'])
      : super(message);
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

  /// Get recent tickets (admin view - latest system tickets)
  Future<Either<AdminDashboardFailure, List<Tiket>>> getRecentTickets({
    int limit = 10,
  });

  /// Reassign ticket to different helpdesk
  Future<Either<AdminDashboardFailure, Tiket>> reassignTicket(
    String tiketId,
    String? helpdeskId,
  );

  /// Get ticket statistics by status
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getTicketStatsByStatus();
}
