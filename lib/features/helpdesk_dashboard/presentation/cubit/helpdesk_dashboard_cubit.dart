import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/helpdesk_dashboard_repository.dart';
import 'helpdesk_dashboard_state.dart';

/// Cubit for managing helpdesk dashboard state
class HelpdeskDashboardCubit extends Cubit<HelpdeskDashboardState> {
  final HelpdeskDashboardRepository _repository;

  HelpdeskDashboardCubit({required HelpdeskDashboardRepository repository})
      : _repository = repository,
        super(const HelpdeskDashboardInitial());

  /// Load helpdesk dashboard data
  Future<void> loadDashboard() async {
    emit(const HelpdeskDashboardLoading());

    final result = await _repository.getHelpdeskDashboardStats();

    result.fold(
      (failure) => emit(HelpdeskDashboardError(failure.message)),
      (stats) async {
        // Load additional data after stats
        final tiketTerbukaResult = await _repository.getTiketTerbuka();
        final tiketSayaResult = await _repository.getTiketSaya();

        final tiketTerbuka = tiketTerbukaResult.getOrElse(() => []);
        final tiketSaya = tiketSayaResult.getOrElse(() => []);

        emit(HelpdeskDashboardLoaded(
          stats: stats,
          greeting: _getGreeting(),
          tiketTerbuka: tiketTerbuka,
          tiketSaya: tiketSaya,
        ));
      },
    );
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is! HelpdeskDashboardLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    final result = await _repository.getHelpdeskDashboardStats();

    result.fold(
      (failure) => emit(HelpdeskDashboardError(failure.message)),
      (stats) {
        emit(currentState.copyWith(
          stats: stats,
          isRefreshing: false,
        ));
      },
    );
  }

  /// Load tiket terbuka
  Future<void> loadTiketTerbuka() async {
    final currentState = state;
    if (currentState is! HelpdeskDashboardLoaded) return;

    emit(currentState.copyWith(isLoadingTiketTerbuka: true));

    final result = await _repository.getTiketTerbuka();

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingTiketTerbuka: false,
          errorMessage: failure.message,
        ));
      },
      (tiketList) {
        emit(currentState.copyWith(
          tiketTerbuka: tiketList,
          isLoadingTiketTerbuka: false,
          errorMessage: null,
        ));
      },
    );
  }

  /// Load tiket saya
  Future<void> loadTiketSaya() async {
    final currentState = state;
    if (currentState is! HelpdeskDashboardLoaded) return;

    emit(currentState.copyWith(isLoadingTiketSaya: true));

    final result = await _repository.getTiketSaya();

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingTiketSaya: false,
          errorMessage: failure.message,
        ));
      },
      (tiketList) {
        emit(currentState.copyWith(
          tiketSaya: tiketList,
          isLoadingTiketSaya: false,
          errorMessage: null,
        ));
      },
    );
  }

  /// Take/assign a ticket
  Future<void> ambilTiket(String tiketId) async {
    final currentState = state;
    if (currentState is! HelpdeskDashboardLoaded) return;

    emit(currentState.copyWith(isTakingTiket: true));

    final result = await _repository.ambilTiket(tiketId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isTakingTiket: false,
          errorMessage: failure.message,
        ));
      },
      (tiket) {
        // Update tiket terbuka list (remove the taken ticket)
        final updatedTiketTerbuka = currentState.tiketTerbuka
            .where((t) => t.id != tiketId)
            .toList();

        // Add to tiket saya list
        final updatedTiketSaya = [tiket, ...currentState.tiketSaya];

        // Update stats
        final updatedStats = currentState.stats.copyWith(
          tiketTerbuka: currentState.stats.tiketTerbuka - 1,
          tiketSaya: currentState.stats.tiketSaya + 1,
        );

        emit(currentState.copyWith(
          tiketTerbuka: updatedTiketTerbuka,
          tiketSaya: updatedTiketSaya,
          stats: updatedStats,
          isTakingTiket: false,
          errorMessage: null,
        ));
      },
    );
  }

  /// Clear error message
  void clearError() {
    final currentState = state;
    if (currentState is HelpdeskDashboardLoaded) {
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  /// Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi, Helpdesk';
    if (hour < 15) return 'Selamat siang, Helpdesk';
    if (hour < 18) return 'Selamat sore, Helpdesk';
    return 'Selamat malam, Helpdesk';
  }
}
