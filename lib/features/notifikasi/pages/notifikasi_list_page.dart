import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../cubits/notifikasi_cubit.dart';
import '../models/notifikasi_model.dart';
import '../widgets/notifikasi_card.dart';

class NotifikasiListPage extends StatefulWidget {
  const NotifikasiListPage({super.key});

  @override
  State<NotifikasiListPage> createState() => _NotifikasiListPageState();
}

class _NotifikasiListPageState extends State<NotifikasiListPage>
    with TickerProviderStateMixin {
  final NotifikasiCubit _cubit = NotifikasiCubit();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _cubit.loadNotifikasi();
    _cubit.getUnreadCount();
    _cubit.subscribeToRealtimeUpdates();
    _scrollController.addListener(_onScroll);
  }

  void _initAnimation() {
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _cubit.unsubscribeFromRealtimeUpdates();
    _cubit.close();
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  void _onNotifikasiTap(String notifikasiId, String? referensiId) {
    _cubit.markAsRead(notifikasiId);

    if (referensiId != null) {
      context.push('/tiket/$referensiId');
    }
  }

  void _onMarkAllAsRead() {
    AppModal.showConfirmation(
      context: context,
      title: 'Tandai Semua Dibaca',
      message: 'Apakah Anda yakin ingin menandai semua notifikasi sebagai sudah dibaca?',
      confirmText: 'Ya, Tandai',
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Notifikasi',
          actions: [
            BlocBuilder<NotifikasiCubit, NotifikasiState>(
              bloc: _cubit,
              builder: (context, state) {
                final hasUnread = state is NotifikasiListLoaded &&
                    state.unreadCount > 0;

                if (!hasUnread) return const SizedBox.shrink();

                return TextButton.icon(
                  onPressed: _onMarkAllAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Tandai Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotifikasiCubit, NotifikasiState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                // Filter tabs
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.default_,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected: state is! NotifikasiListLoaded ||
                            !state.showUnreadOnly,
                        onTap: () => _cubit.toggleFilter(false),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(
                        label: 'Belum Dibaca',
                        isSelected: state is NotifikasiListLoaded &&
                            state.showUnreadOnly,
                        count: state is NotifikasiListLoaded
                            ? state.unreadCount
                            : null,
                        onTap: () => _cubit.toggleFilter(true),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(NotifikasiState state) {
    if (state is NotifikasiLoading) {
      return const ListSkeleton(itemCount: 5);
    }

    if (state is NotifikasiError) {
      return ErrorState.server(
        onRetry: () => _cubit.refresh(),
      );
    }

    // Show refreshing animation with current data
    if (state is NotifikasiRefreshing) {
      return Stack(
        children: [
          // Show current list dimmed
          Opacity(
            opacity: 0.5,
            child: _buildNotifikasiList(state.currentList, false, false),
          ),
          // Show animated loading indicator at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.default_),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _refreshAnimationController,
                        child: const Icon(
                          Icons.sync,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Memperbarui data...',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state is NotifikasiListLoaded) {
      // Animate on new data arrival
      if (state.hasNewData) {
        _refreshAnimationController
          ..reset()
          ..forward().then((_) {
            // Reset hasNewData after animation via cubit method
            _cubit.resetHasNewData();
          });
      }

      if (state.notifikasiList.isEmpty) {
        return EmptyState.notifications();
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildNotifikasiList(
          state.notifikasiList,
          state.hasMore,
          state.isLoadingMore,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNotifikasiList(
    List<NotifikasiModel> notifikasiList,
    bool hasMore,
    bool isLoadingMore,
  ) {
    return AppRefreshWrapper(
      onRefresh: () => _cubit.refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.default_),
        itemCount: notifikasiList.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.default_),
        itemBuilder: (context, index) {
          if (index == notifikasiList.length) {
            return isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.default_),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final notifikasi = notifikasiList[index];
          return NotifikasiCard(
            notifikasi: notifikasi,
            onTap: () => _onNotifikasiTap(
              notifikasi.id,
              notifikasi.referensiId,
            ),
            onDismiss: () => _cubit.markAsRead(notifikasi.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.buttonRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: AppBorderRadius.buttonRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count! > 99 ? '99+' : count!.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
