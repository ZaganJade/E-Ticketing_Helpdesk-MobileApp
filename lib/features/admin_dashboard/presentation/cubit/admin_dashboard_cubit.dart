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

  Future<void> loadDashboard() async {
    emit(const AdminDashboardLoading());

    final result = await _repository.getAdminDashboardStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) => _fetchAdditionalData(stats),
    );
  }

  Future<void> _fetchAdditionalData(AdminDashboardStats stats) async {
    final recentResult = await _repository.getRecentTickets(limit: 10);
    final ticketStatsResult = await _repository.getTicketStatsByStatus();
    final poolResult = await _repository.getPoolTickets();
    final diprosesResult = await _repository.getDiprosesTickets();
    final helpdesksResult = await _repository.getAvailableHelpdesks();

    emit(AdminDashboardLoaded(
      stats: stats,
      greeting: _getGreeting(),
      recentTickets: recentResult.getOrElse(() => []),
      ticketStatsByStatus: ticketStatsResult.getOrElse(() => {}),
      poolTickets: poolResult.getOrElse(() => []),
      diprosesTickets: diprosesResult.getOrElse(() => []),
      helpdesks: helpdesksResult.getOrElse(() => []),
    ));
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    final result = await _repository.getAdminDashboardStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) async => _fetchAdditionalData(stats),
    );
  }

  Future<void> assignTicket(String tiketId, String helpdeskId) async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    emit(currentState.copyWith(isLoadingPool: true));

    final result = await _repository.assignTicket(tiketId, helpdeskId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingPool: false,
          errorMessage: failure.message,
        ));
      },
      (_) => _reloadPoolData(currentState),
    );
  }

  Future<void> unassignTicket(String tiketId) async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    emit(currentState.copyWith(isLoadingPool: true));

    final result = await _repository.unassignTicket(tiketId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingPool: false,
          errorMessage: failure.message,
        ));
      },
      (_) => _reloadPoolData(currentState),
    );
  }

  Future<void> _reloadPoolData(AdminDashboardLoaded currentState) async {
    final statsResult = await _repository.getAdminDashboardStats();
    final poolResult = await _repository.getPoolTickets();
    final diprosesResult = await _repository.getDiprosesTickets();
    final helpdesksResult = await _repository.getAvailableHelpdesks();

    statsResult.fold(
      (failure) => emit(currentState.copyWith(
        isLoadingPool: false,
        errorMessage: failure.message,
      )),
      (stats) {
        emit(currentState.copyWith(
          stats: stats,
          poolTickets: poolResult.getOrElse(() => []),
          diprosesTickets: diprosesResult.getOrElse(() => []),
          helpdesks: helpdesksResult.getOrElse(() => []),
          isLoadingPool: false,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> reassignTicket(String tiketId, String? helpdeskId) async {
    if (helpdeskId == null) return;
    await assignTicket(tiketId, helpdeskId);
  }

  Future<void> loadHelpdeskPerformance() async {
    final currentState = state;
    if (currentState is! AdminDashboardLoaded) return;

    final result = await _repository.getHelpdeskPerformance();

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (performances) {
        emit(currentState.copyWith(
          stats: currentState.stats.copyWith(
            helpdeskPerformances: performances,
          ),
        ));
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi, Admin';
    if (hour < 15) return 'Selamat siang, Admin';
    if (hour < 18) return 'Selamat sore, Admin';
    return 'Selamat malam, Admin';
  }

  void clearError() {
    final currentState = state;
    if (currentState is AdminDashboardLoaded) {
      emit(currentState.copyWith(errorMessage: null));
    }
  }
}
