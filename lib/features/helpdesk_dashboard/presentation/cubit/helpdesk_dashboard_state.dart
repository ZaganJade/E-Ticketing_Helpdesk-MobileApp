import 'package:equatable/equatable.dart';

import '../../domain/entities/helpdesk_dashboard_stats.dart';
import '../../../tiket/domain/entities/tiket.dart';

/// Base class for all helpdesk dashboard states
abstract class HelpdeskDashboardState extends Equatable {
  const HelpdeskDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HelpdeskDashboardInitial extends HelpdeskDashboardState {
  const HelpdeskDashboardInitial();
}

/// Loading state
class HelpdeskDashboardLoading extends HelpdeskDashboardState {
  const HelpdeskDashboardLoading();
}

/// Loaded state with helpdesk dashboard data
class HelpdeskDashboardLoaded extends HelpdeskDashboardState {
  final HelpdeskDashboardStats stats;
  final String greeting;
  final bool isRefreshing;
  final List<Tiket> tiketTerbuka;
  final List<Tiket> tiketSaya;
  final List<Tiket> tiketSelesai;
  final bool isLoadingTiketTerbuka;
  final bool isLoadingTiketSaya;
  final bool isLoadingTiketSelesai;
  final bool isTakingTiket;
  final String? errorMessage;

  const HelpdeskDashboardLoaded({
    required this.stats,
    required this.greeting,
    this.isRefreshing = false,
    this.tiketTerbuka = const [],
    this.tiketSaya = const [],
    this.tiketSelesai = const [],
    this.isLoadingTiketTerbuka = false,
    this.isLoadingTiketSaya = false,
    this.isLoadingTiketSelesai = false,
    this.isTakingTiket = false,
    this.errorMessage,
  });

  HelpdeskDashboardLoaded copyWith({
    HelpdeskDashboardStats? stats,
    String? greeting,
    bool? isRefreshing,
    List<Tiket>? tiketTerbuka,
    List<Tiket>? tiketSaya,
    List<Tiket>? tiketSelesai,
    bool? isLoadingTiketTerbuka,
    bool? isLoadingTiketSaya,
    bool? isLoadingTiketSelesai,
    bool? isTakingTiket,
    String? errorMessage,
  }) {
    return HelpdeskDashboardLoaded(
      stats: stats ?? this.stats,
      greeting: greeting ?? this.greeting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      tiketTerbuka: tiketTerbuka ?? this.tiketTerbuka,
      tiketSaya: tiketSaya ?? this.tiketSaya,
      tiketSelesai: tiketSelesai ?? this.tiketSelesai,
      isLoadingTiketTerbuka: isLoadingTiketTerbuka ?? this.isLoadingTiketTerbuka,
      isLoadingTiketSaya: isLoadingTiketSaya ?? this.isLoadingTiketSaya,
      isLoadingTiketSelesai: isLoadingTiketSelesai ?? this.isLoadingTiketSelesai,
      isTakingTiket: isTakingTiket ?? this.isTakingTiket,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        greeting,
        isRefreshing,
        tiketTerbuka,
        tiketSaya,
        tiketSelesai,
        isLoadingTiketTerbuka,
        isLoadingTiketSaya,
        isLoadingTiketSelesai,
        isTakingTiket,
        errorMessage,
      ];
}

/// Error state
class HelpdeskDashboardError extends HelpdeskDashboardState {
  final String message;

  const HelpdeskDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
