import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/helpdesk_stats_card.dart';
import '../../../dashboard/presentation/widgets/tiket_terbuka_section.dart';
import '../../../dashboard/presentation/widgets/tiket_saya_section.dart';

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

  void _onAmbilTiket(String tiketId) {
    HapticFeedback.mediumImpact();
    _helpdeskCubit.ambilTiket(tiketId);
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
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
          sliver: SliverToBoxAdapter(
            child: HelpdeskGreetingSectionSkeleton(
              isDark: isDark,
              isTablet: isTablet,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: HelpdeskStatsCardSkeleton(
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

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: HelpdeskStatsCard(
                totalDitangani: state.stats.totalTiketDitangani,
                tiketTerbuka: state.stats.tiketTerbuka,
                tiketSaya: state.stats.tiketSaya,
                rataRataWaktu: state.stats.rataRataWaktuSelesai,
                isLoading: state.isRefreshing,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: ShadToaster(
                child: TiketTerbukaSection(
                  tiketList: state.tiketTerbuka,
                  isLoading: state.isLoadingTiketTerbuka,
                  onAmbilTiket: _onAmbilTiket,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: TiketSayaSection(
                tiketList: state.tiketSaya,
                isLoading: state.isLoadingTiketSaya,
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
