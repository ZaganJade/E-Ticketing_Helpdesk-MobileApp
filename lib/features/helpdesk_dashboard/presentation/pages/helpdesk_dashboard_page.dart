import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../cubit/helpdesk_dashboard_cubit.dart';
import '../cubit/helpdesk_dashboard_state.dart';
import '../widgets/helpdesk_greeting_section.dart';
import '../widgets/helpdesk_status_overview.dart';
import '../widgets/helpdesk_progress_chart.dart';
import '../widgets/helpdesk_quick_actions.dart';
import '../widgets/helpdesk_tiket_monitoring.dart';

class HelpdeskDashboardPage extends StatefulWidget {
  const HelpdeskDashboardPage({super.key});

  @override
  State<HelpdeskDashboardPage> createState() => _HelpdeskDashboardPageState();
}

class _HelpdeskDashboardPageState extends State<HelpdeskDashboardPage> {
  late final HelpdeskDashboardCubit _helpdeskCubit;

  @override
  void initState() {
    super.initState();
    _helpdeskCubit = getIt<HelpdeskDashboardCubit>();
    _helpdeskCubit.loadDashboard();
  }

  @override
  void dispose() {
    _helpdeskCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _helpdeskCubit.refresh();
  }

  void _onTapTiket(Tiket tiket) {
    context.push('/tiket/${tiket.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return BlocProvider.value(
      value: _helpdeskCubit,
      child: Scaffold(
        backgroundColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
        body: SafeArea(
          child: BlocBuilder<HelpdeskDashboardCubit, HelpdeskDashboardState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType != current.runtimeType) return true;
              if (current is HelpdeskDashboardLoaded &&
                  previous is HelpdeskDashboardLoaded) {
                return current.stats.tiketTerbuka !=
                        previous.stats.tiketTerbuka ||
                    current.stats.tiketSaya != previous.stats.tiketSaya ||
                    current.stats.tiketSelesai != previous.stats.tiketSelesai ||
                    current.tiketTerbuka != previous.tiketTerbuka ||
                    current.tiketSaya != previous.tiketSaya ||
                    current.tiketSelesai != previous.tiketSelesai ||
                    current.isRefreshing != previous.isRefreshing;
              }
              return true;
            },
            builder: (context, state) {
              if (state is HelpdeskDashboardInitial ||
                  (state is HelpdeskDashboardLoading)) {
                return _buildSkeletonLoading(isDark, isTablet, horizontalPadding);
              }

              if (state is HelpdeskDashboardError) {
                return ErrorState.server(
                  onRetry: _onRefresh,
                );
              }

              if (state is HelpdeskDashboardLoaded) {
                return _buildDashboardContent(
                  context: context,
                  state: state,
                  isDark: isDark,
                  isTablet: isTablet,
                  horizontalPadding: horizontalPadding,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(
    bool isDark,
    bool isTablet,
    double horizontalPadding,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Greeting skeleton
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
          sliver: SliverToBoxAdapter(
            child: HelpdeskGreetingSectionSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        // Status overview skeleton
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: HelpdeskStatusOverviewSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        // Chart skeleton
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: HelpdeskProgressChart(
              perluDitangani: 0,
              diproses: 0,
              selesai: 0,
              isLoading: true,
            ),
          ),
        ),
        // Quick actions skeleton
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: HelpdeskQuickActionsSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        // Monitoring skeleton
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: HelpdeskTiketMonitoringSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent({
    required BuildContext context,
    required HelpdeskDashboardLoaded state,
    required bool isDark,
    required bool isTablet,
    required double horizontalPadding,
  }) {
    final authState = context.watch<AuthCubit>().state;
    Pengguna? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: isDark ? ShadcnTheme.primaryForeground : ShadcnTheme.primary,
      backgroundColor: isDark ? ShadcnTheme.darkCard : ShadcnTheme.card,
      strokeWidth: 3,
      edgeOffset: 80,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Greeting Section
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
            sliver: SliverToBoxAdapter(
              child: HelpdeskGreetingSection(
                greeting: state.greeting,
                user: currentUser,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          // 2. Status Overview (3-column stat cards + summary bar)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
            sliver: SliverToBoxAdapter(
              child: HelpdeskStatusOverview(
                perluDitangani: state.stats.tiketSaya,
                diproses: state.stats.tiketSelesai,
                selesai: state.stats.totalTiketDitangani,
                totalDitangani: state.stats.totalTiketDitangani,
                rataRataWaktu: state.stats.rataRataWaktuSelesai,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          // 3. Progress Chart (donut chart with legend)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
            sliver: SliverToBoxAdapter(
              child: HelpdeskProgressChart(
                perluDitangani: state.stats.tiketSaya,
                diproses: state.stats.tiketSelesai,
                selesai: state.stats.totalTiketDitangani,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          // 4. Quick Actions
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
            sliver: SliverToBoxAdapter(
              child: HelpdeskQuickActions(
                onLihatSemuaTiket: () => context.push('/tiket'),
              ),
            ),
          ),

          // 5. Ticket Monitoring (unified tabbed view)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
            sliver: SliverToBoxAdapter(
              child: ShadToaster(
                child: HelpdeskTiketMonitoring(
                  tiketSaya: state.tiketSaya,
                  tiketSelesai: state.tiketSelesai,
                  onTapTiket: _onTapTiket,
                  isLoading: state.isLoadingTiketSaya,
                ),
              ),
            ),
          ),

          // Bottom padding
          SliverPadding(padding: EdgeInsets.only(bottom: horizontalPadding + 8)),
        ],
      ),
    );
  }
}
