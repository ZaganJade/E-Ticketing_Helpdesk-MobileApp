part of 'dashboard_cubit.dart';

/// Base class for all dashboard states
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with dashboard data
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final String greeting;
  final bool isRefreshing;
  final List<Tiket> tiketTerbuka;
  final List<Tiket> tiketSaya;
  final bool isLoadingTiketTerbuka;
  final bool isLoadingTiketSaya;
  final bool isTakingTiket;
  final String? errorMessage;

  const DashboardLoaded({
    required this.stats,
    required this.greeting,
    this.isRefreshing = false,
    this.tiketTerbuka = const [],
    this.tiketSaya = const [],
    this.isLoadingTiketTerbuka = false,
    this.isLoadingTiketSaya = false,
    this.isTakingTiket = false,
    this.errorMessage,
  });

  /// Check if there are open tickets
  bool get hasTiketTerbuka => tiketTerbuka.isNotEmpty;

  /// Check if there are my tickets
  bool get hasTiketSaya => tiketSaya.isNotEmpty;

  DashboardLoaded copyWith({
    DashboardStats? stats,
    String? greeting,
    bool? isRefreshing,
    List<Tiket>? tiketTerbuka,
    List<Tiket>? tiketSaya,
    bool? isLoadingTiketTerbuka,
    bool? isLoadingTiketSaya,
    bool? isTakingTiket,
    String? errorMessage,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      greeting: greeting ?? this.greeting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      tiketTerbuka: tiketTerbuka ?? this.tiketTerbuka,
      tiketSaya: tiketSaya ?? this.tiketSaya,
      isLoadingTiketTerbuka: isLoadingTiketTerbuka ?? this.isLoadingTiketTerbuka,
      isLoadingTiketSaya: isLoadingTiketSaya ?? this.isLoadingTiketSaya,
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
        isLoadingTiketTerbuka,
        isLoadingTiketSaya,
        isTakingTiket,
        errorMessage,
      ];
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
