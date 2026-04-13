import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/app_refresh.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/tiket_status_stats.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/greeting_section.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/quick_actions.dart';
import '../widgets/stat_card.dart';
import '../widgets/tiket_recent_list.dart';
import '../widgets/tiket_saya_section.dart';
import '../widgets/tiket_terbuka_section.dart';

/// Main dashboard page for the application
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = getIt<DashboardCubit>();
    _dashboardCubit.loadDashboard();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _dashboardCubit.refresh();
  }

  void _onBuatTiket() {
    // Navigate to create ticket page
    context.push('/tiket/create');
  }

  void _onLihatSemuaTiket() {
    // Navigate to ticket list page - handled by bottom nav
  }

  void _onTapTiket(Tiket tiket) {
    context.push('/tiket/${tiket.id}');
  }

  void _onAmbilTiket(String tiketId) {
    _dashboardCubit.ambilTiket(tiketId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(DashboardState state) {
    // Get current user from auth cubit
    final authState = context.watch<AuthCubit>().state;
    Pengguna? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    if (state is DashboardInitial || (state is DashboardLoading && currentUser == null)) {
      return _buildSkeletonLoading(currentUser);
    }

    if (state is DashboardError) {
      return ErrorState(
        title: 'Gagal memuat dashboard',
        subtitle: state.message,
        onRetry: () => _onRefresh(),
      );
    }

    if (state is DashboardLoaded) {
      return _buildDashboardContent(
        stats: state.stats,
        greeting: state.greeting,
        user: currentUser,
        state: state,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkeletonLoading(Pengguna? user) {
    return AppRefreshWrapper(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.default_),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting skeleton
            const GreetingSectionSkeleton(),
            const SizedBox(height: AppSpacing.xl),

            // Stats skeleton
            const StatCard(total: 0, isLoading: true),
            const SizedBox(height: AppSpacing.default_),
            const StatusStatsRow(
              stats: TiketStatusStats(terbuka: 0, diproses: 0, selesai: 0),
              isLoading: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Progress indicator skeleton
            const StatusProgressIndicator(
              stats: TiketStatusStats(terbuka: 0, diproses: 0, selesai: 0),
              isLoading: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Recent tickets skeleton
            TiketRecentList(
              tiketList: const [],
              isLoading: true,
              onViewAll: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent({
    required DashboardStats stats,
    required String greeting,
    required Pengguna? user,
    required DashboardLoaded state,
  }) {
    return AppRefreshWrapper(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.default_),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section (13.4, 13.5)
            if (user != null) ...[
              GreetingSection(
                greeting: greeting,
                user: user,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Total Tiket Stat Card (13.6)
            StatCard(
              total: stats.totalTiket,
              isLoading: state.isRefreshing,
            ),
            const SizedBox(height: AppSpacing.default_),

            // Status Breakdown Row (13.7)
            StatusStatsRow(
              stats: stats.statusStats,
              isLoading: state.isRefreshing,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Progress Indicator / Chart (13.8)
            StatusProgressIndicator(
              stats: stats.statusStats,
              isLoading: state.isRefreshing,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quick Actions (13.14, 13.15)
            QuickActions(
              onBuatTiket: _onBuatTiket,
              onLihatSemuaTiket: _onLihatSemuaTiket,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Helpdesk specific: Tiket Terbuka Section (13.16)
            if (user?.peran == Peran.helpdesk || user?.peran == Peran.admin) ...[
              TiketTerbukaSection(
                tiketList: state.tiketTerbuka,
                isLoading: state.isLoadingTiketTerbuka,
                onAmbilTiket: _onAmbilTiket,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tiket Saya Section (13.17)
              TiketSayaSection(
                tiketList: state.tiketSaya,
                isLoading: state.isLoadingTiketSaya,
                onTapTiket: _onTapTiket,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Tiket Terbaru Section (13.11, 13.12, 13.13)
            TiketRecentList(
              tiketList: stats.tiketTerbaru,
              isLoading: state.isRefreshing,
              onViewAll: _onLihatSemuaTiket,
              onTapTiket: _onTapTiket,
            ),
          ],
        ),
      ),
    );
  }
}
