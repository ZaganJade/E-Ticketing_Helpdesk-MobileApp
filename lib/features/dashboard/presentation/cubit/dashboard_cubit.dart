import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

/// Cubit for managing dashboard state
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final ApiService _apiService;
  final SupabaseClient? _supabaseClient;
  final Logger _logger;

  RealtimeChannel? _tiketChannel;
  Timer? _debounceTimer;

  DashboardCubit({
    required DashboardRepository dashboardRepository,
    required ApiService apiService,
    SupabaseClient? supabaseClient,
    Logger? logger,
  })  : _dashboardRepository = dashboardRepository,
        _apiService = apiService,
        _supabaseClient = supabaseClient,
        _logger = logger ?? Logger(),
        super(const DashboardInitial());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    emit(const DashboardLoading());

    final result = await _dashboardRepository.getDashboardStats();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (stats) {
        emit(DashboardLoaded(
          stats: stats,
          greeting: _getGreeting(),
        ));
        _subscribeToRealtimeUpdates();
      },
    );
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardLoaded(
        stats: currentState.stats,
        greeting: currentState.greeting,
        isRefreshing: true,
      ));
    }

    final result = await _dashboardRepository.getDashboardStats();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (stats) {
        emit(DashboardLoaded(
          stats: stats,
          greeting: _getGreeting(),
        ));
      },
    );
  }

  /// Load tiket terbuka (for helpdesk)
  Future<void> loadTiketTerbuka() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isLoadingTiketTerbuka: true));

    final result = await _dashboardRepository.getTiketTerbuka();

    result.fold(
      (failure) {
        _logger.e('Failed to load tiket terbuka: ${failure.message}');
        emit(currentState.copyWith(isLoadingTiketTerbuka: false));
      },
      (tiketList) {
        emit(currentState.copyWith(
          tiketTerbuka: tiketList,
          isLoadingTiketTerbuka: false,
        ));
      },
    );
  }

  /// Load tiket saya (for helpdesk)
  Future<void> loadTiketSaya() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isLoadingTiketSaya: true));

    final result = await _dashboardRepository.getTiketSaya();

    result.fold(
      (failure) {
        _logger.e('Failed to load tiket saya: ${failure.message}');
        emit(currentState.copyWith(isLoadingTiketSaya: false));
      },
      (tiketList) {
        emit(currentState.copyWith(
          tiketSaya: tiketList,
          isLoadingTiketSaya: false,
        ));
      },
    );
  }

  /// Take/assign a ticket (for helpdesk)
  Future<void> ambilTiket(String tiketId) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isTakingTiket: true));

    final result = await _dashboardRepository.ambilTiket(tiketId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isTakingTiket: false,
          errorMessage: failure.message,
        ));
      },
      (tiket) {
        // Update tiket terbuka list
        final updatedTiketTerbuka = currentState.tiketTerbuka
            .where((t) => t.id != tiketId)
            .toList();

        // Add to tiket saya list
        final updatedTiketSaya = [tiket, ...currentState.tiketSaya];

        emit(currentState.copyWith(
          tiketTerbuka: updatedTiketTerbuka,
          tiketSaya: updatedTiketSaya,
          isTakingTiket: false,
        ));
      },
    );
  }

  /// Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  /// Subscribe to realtime updates (only if Supabase is available)
  void _subscribeToRealtimeUpdates() {
    if (_supabaseClient == null) {
      _logger.i('Realtime updates disabled - Supabase client not available');
      return;
    }

    _logger.i('Subscribing to realtime updates');

    _tiketChannel = _supabaseClient
        .channel('dashboard_tiket_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tiket',
          callback: (payload, [ref]) {
            _logger.i('Realtime update received: ${payload.eventType}');
            // Debounce: cancel previous timer and wait 2 seconds before refreshing
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(seconds: 2), () {
              refresh();
            });
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    if (_tiketChannel != null && _supabaseClient != null) {
      _supabaseClient.removeChannel(_tiketChannel!);
    }
    return super.close();
  }
}
