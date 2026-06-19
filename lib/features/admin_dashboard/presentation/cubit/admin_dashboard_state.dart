import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/helpdesk_availability.dart';
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
  final List<Tiket> poolTickets;
  final List<Tiket> diprosesTickets;
  final List<HelpdeskAvailability> helpdesks;
  final Map<String, int> ticketStatsByStatus;
  final String? errorMessage;
  final bool isLoadingPool;

  const AdminDashboardLoaded({
    required this.stats,
    required this.greeting,
    this.isRefreshing = false,
    this.recentTickets = const [],
    this.poolTickets = const [],
    this.diprosesTickets = const [],
    this.helpdesks = const [],
    this.ticketStatsByStatus = const {},
    this.errorMessage,
    this.isLoadingPool = false,
  });

  AdminDashboardLoaded copyWith({
    AdminDashboardStats? stats,
    String? greeting,
    bool? isRefreshing,
    List<Tiket>? recentTickets,
    List<Tiket>? poolTickets,
    List<Tiket>? diprosesTickets,
    List<HelpdeskAvailability>? helpdesks,
    Map<String, int>? ticketStatsByStatus,
    String? errorMessage,
    bool? isLoadingPool,
  }) {
    return AdminDashboardLoaded(
      stats: stats ?? this.stats,
      greeting: greeting ?? this.greeting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      recentTickets: recentTickets ?? this.recentTickets,
      poolTickets: poolTickets ?? this.poolTickets,
      diprosesTickets: diprosesTickets ?? this.diprosesTickets,
      helpdesks: helpdesks ?? this.helpdesks,
      ticketStatsByStatus: ticketStatsByStatus ?? this.ticketStatsByStatus,
      errorMessage: errorMessage,
      isLoadingPool: isLoadingPool ?? this.isLoadingPool,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        greeting,
        isRefreshing,
        recentTickets,
        poolTickets,
        diprosesTickets,
        helpdesks,
        ticketStatsByStatus,
        errorMessage,
        isLoadingPool,
      ];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
