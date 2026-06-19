import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/widgets.dart' hide StatCard;
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/tiket_recent_list.dart';
import '../widgets/tiket_saya_section.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/responsive_layout.dart';

/// Brutalist Modern Dashboard using shadcn_ui
/// Optimized: Removed stagger animations, added RepaintBoundary, ResponsiveBuilder
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
    HapticFeedback.mediumImpact();
    context.push('/tiket/create');
  }

  void _onLihatSemuaTiket() {
    context.push('/tiket');
  }

  void _onTapTiket(Tiket tiket) {
    context.push('/tiket/${tiket.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        backgroundColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
        body: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, responsive) {
              return BlocBuilder<DashboardCubit, DashboardState>(
                buildWhen: (previous, current) {
                  // Only rebuild when major state changes, not for every refresh tick
                  if (previous.runtimeType != current.runtimeType) return true;
                  if (current is DashboardLoaded && previous is DashboardLoaded) {
                    // Compare meaningful data changes
                    return current.stats.totalTiket != previous.stats.totalTiket ||
                        current.stats.tiketTerbaru.length != previous.stats.tiketTerbaru.length ||
                        current.tiketTerbuka.length != previous.tiketTerbuka.length ||
                        current.tiketSaya.length != previous.tiketSaya.length ||
                        current.isRefreshing != previous.isRefreshing;
                  }
                  return true;
                },
                builder: (context, state) {
                  return _buildContent(context, state, isDark, responsive);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state, bool isDark, ResponsiveLayout responsive) {
    final authState = context.watch<AuthCubit>().state;
    Pengguna? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    if (state is DashboardInitial || (state is DashboardLoading && currentUser == null)) {
      return _buildSkeletonLoading(isDark, responsive);
    }

    if (state is DashboardError) {
      return ErrorState.server(
        onRetry: _onRefresh,
      );
    }

    if (state is DashboardLoaded) {
      return _buildDashboardContent(
        context: context,
        stats: state.stats,
        greeting: state.greeting,
        user: currentUser,
        state: state,
        isDark: isDark,
        responsive: responsive,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkeletonLoading(bool isDark, ResponsiveLayout responsive) {
    final isTablet = responsive.isTablet;
    final hp = responsive.horizontalPadding;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Greeting skeleton
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: GreetingSectionSkeleton(isDark: isDark),
          ),
        ),
        // Stat card skeleton
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: StatCardSkeleton(isDark: isDark),
            ),
          ),
        ),
        // Progress indicator skeleton
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: StatusProgressSkeleton(
                isDark: isDark,
                isTablet: isTablet,
                horizontalPadding: hp,
              ),
            ),
          ),
        ),
        // Quick actions skeleton
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: QuickActionsSkeleton(isDark: isDark),
            ),
          ),
        ),
        // Recent tickets skeleton
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: TiketRecentListSkeleton(isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent({
    required BuildContext context,
    required DashboardStats stats,
    required String greeting,
    required Pengguna? user,
    required DashboardLoaded state,
    required bool isDark,
    required ResponsiveLayout responsive,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: isDark ? ShadcnTheme.primaryForeground : ShadcnTheme.primary,
      backgroundColor: isDark ? ShadcnTheme.darkCard : ShadcnTheme.card,
      strokeWidth: 3,
      edgeOffset: 80,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: GreetingSection(
                greeting: greeting,
                user: user,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          // Stats Overview
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: StatCard(
                  total: stats.totalTiket,
                  statusStats: stats.statusStats,
                  isLoading: state.isRefreshing,
                ),
              ),
            ),
          ),

          // Progress Indicator
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: StatusProgressIndicator(
                  stats: stats.statusStats,
                  isLoading: state.isRefreshing,
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: QuickActions(
                  onBuatTiket: _onBuatTiket,
                  onLihatSemuaTiket: _onLihatSemuaTiket,
                ),
              ),
            ),
          ),

          // Helpdesk: only assigned tickets (no pool/self-assign)
          if (user?.peran == Peran.helpdesk) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              sliver: SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: TiketSayaSection(
                    tiketList: state.tiketSaya,
                    isLoading: state.isLoadingTiketSaya,
                    onTapTiket: _onTapTiket,
                  ),
                ),
              ),
            ),
          ],

          // Recent Tickets
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TiketRecentList(
                  tiketList: stats.tiketTerbaru,
                  isLoading: state.isRefreshing,
                  onViewAll: _onLihatSemuaTiket,
                  onTapTiket: _onTapTiket,
                ),
              ),
            ),
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: responsive.horizontalPadding)),
        ],
      ),
    );
  }
}

// Text style helpers
class TextStyles {
  static TextStyle h4(BuildContext context) => TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3,
    color: ShadTheme.of(context).colorScheme.foreground);
  static TextStyle muted(BuildContext context) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.4,
    color: ShadTheme.of(context).colorScheme.mutedForeground);
}
