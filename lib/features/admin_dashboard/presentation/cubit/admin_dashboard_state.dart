import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_dashboard_stats.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Base class for all admin dashboard states
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Loaded state with admin dashboard data
class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardStats stats;
  final String greeting;
  final bool isRefreshing;
  final List<Tiket> recentTickets;
  final Map<String, int> ticketStatsByStatus;
  final String? errorMessage;

  const AdminDashboardLoaded({
    required this.stats,
    required this.greeting,
    this.isRefreshing = false,
    this.recentTickets = const [],
    this.ticketStatsByStatus = const {},
    this.errorMessage,
  });

  AdminDashboardLoaded copyWith({
    AdminDashboardStats? stats,
    String? greeting,
    bool? isRefreshing,
    List<Tiket>? recentTickets,
    Map<String, int>? ticketStatsByStatus,
    String? errorMessage,
  }) {
    return AdminDashboardLoaded(
      stats: stats ?? this.stats,
      greeting: greeting ?? this.greeting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      recentTickets: recentTickets ?? this.recentTickets,
      ticketStatsByStatus: ticketStatsByStatus ?? this.ticketStatsByStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        greeting,
        isRefreshing,
        recentTickets,
        ticketStatsByStatus,
        errorMessage,
      ];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
