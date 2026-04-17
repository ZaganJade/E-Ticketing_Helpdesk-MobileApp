import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_state.dart';

/// Cubit for managing admin dashboard state
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminDashboardRepository _repository;

  AdminDashboardCubit({required AdminDashboardRepository repository})
      : _repository = repository,
        super(const AdminDashboardInitial());

  /// Load admin dashboard data
  Future<void> loadDashboard() async {
    emit(const AdminDashboardLoading());

    final result = await _repository.getAdminDashboardStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) {
        // Also fetch recent tickets and ticket stats
        _fetchAdditionalData(stats);
      },
    );
  }

  /// Fetch additional data (recent tickets, ticket stats)
  Future<void> _fetchAdditionalData(AdminDashboardStats stats) async {
    final recentResult = await _repository.getRecentTickets(limit: 10);
    final ticketStatsResult = await _repository.getTicketStatsByStatus();

    final recentTickets = recentResult.getOrElse(() => []);
    final ticketStats = ticketStatsResult.getOrElse(() => {});

    emit(AdminDashboardLoaded(
      stats: stats,
      greeting: _getGreeting(),
      recentTickets: recentTickets,
      ticketStatsByStatus: ticketStats,
    ));
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    final result = await _repository.getAdminDashboardStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) async {
        await _fetchAdditionalData(stats);
      },
    );
  }

  /// Reassign ticket to different helpdesk
  Future<void> reassignTicket(String tiketId, String? helpdeskId) async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    final result = await _repository.reassignTicket(tiketId, helpdeskId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (tiket) {
        // Update recent tickets list
        final updatedRecent = currentState.recentTickets.map((t) {
          return t.id == tiketId ? tiket : t;
        }).toList();

        emit(currentState.copyWith(
          recentTickets: updatedRecent,
          errorMessage: null,
        ));
      },
    );
  }

  /// Load helpdesk performance
  Future<void> loadHelpdeskPerformance() async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    final result = await _repository.getHelpdeskPerformance();

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (performances) {
        final updatedStats = currentState.stats.copyWith(
          helpdeskPerformances: performances,
        );

        emit(currentState.copyWith(stats: updatedStats));
      },
    );
  }

  /// Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi, Admin';
    if (hour < 15) return 'Selamat siang, Admin';
    if (hour < 18) return 'Selamat sore, Admin';
    return 'Selamat malam, Admin';
  }

  /// Clear error message
  void clearError() {
    final currentState = state;
    if (currentState is AdminDashboardLoaded) {
      emit(currentState.copyWith(errorMessage: null));
    }
  }
}
