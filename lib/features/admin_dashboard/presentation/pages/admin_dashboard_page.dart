import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';
import '../widgets/admin_greeting_section.dart';
import '../widgets/admin_progress_indicator.dart';
import '../widgets/ticket_stats_card.dart';
import '../widgets/user_stats_card.dart';
import '../widgets/helpdesk_performance_card.dart';
import '../widgets/recent_tickets_section.dart';
import '../widgets/admin_skeletons.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminDashboardCubit _adminCubit;

  @override
  void initState() {
    super.initState();
    _adminCubit = getIt<AdminDashboardCubit>();
    _adminCubit.loadDashboard();
  }

  @override
  void dispose() {
    _adminCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _adminCubit.refresh();
  }

  void _onLihatSemuaTiket() {
    HapticFeedback.mediumImpact();
    context.push('/tiket');
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
      value: _adminCubit,
      child: Scaffold(
        backgroundColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
        body: SafeArea(
          child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType != current.runtimeType) return true;
              if (current is AdminDashboardLoaded && previous is AdminDashboardLoaded) {
                return current.stats.totalTiket != previous.stats.totalTiket ||
                    current.recentTickets.length != previous.recentTickets.length ||
                    current.isRefreshing != previous.isRefreshing;
              }
              return true;
            },
            builder: (context, state) {
              if (state is AdminDashboardInitial ||
                  (state is AdminDashboardLoading)) {
                return _buildSkeletonLoading(isDark, isTablet, horizontalPadding);
              }

              if (state is AdminDashboardError) {
                return ErrorState.server(
                  onRetry: _onRefresh,
                );
              }

              if (state is AdminDashboardLoaded) {
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
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
          sliver: SliverToBoxAdapter(
            child: AdminGreetingSectionSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: TicketStatsCardSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: UserStatsCardSkeleton(
              isDark: isDark,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: AdminProgressIndicatorSkeleton(
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
    required AdminDashboardLoaded state,
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
            sliver: SliverToBoxAdapter(
              child: AdminGreetingSection(
                greeting: state.greeting,
                user: currentUser,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: TicketStatsCard(
                total: state.stats.totalTiket,
                terbuka: state.stats.tiketTerbuka,
                diproses: state.stats.tiketDiproses,
                selesai: state.stats.tiketSelesai,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: UserStatsCard(
                pengguna: state.stats.userStats.pengguna,
                helpdesk: state.stats.userStats.helpdesk,
                admin: state.stats.userStats.admin,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: AdminProgressIndicator(
                total: state.stats.totalTiket,
                terbuka: state.stats.tiketTerbuka,
                diproses: state.stats.tiketDiproses,
                selesai: state.stats.tiketSelesai,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: HelpdeskPerformanceCard(
                performances: state.stats.helpdeskPerformances,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: RecentTicketsSection(
                tiketList: state.recentTickets,
                isLoading: state.isRefreshing,
                onViewAll: _onLihatSemuaTiket,
                onTapTiket: _onTapTiket,
              ),
            ),
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: horizontalPadding)),
        ],
      ),
    );
  }
}
