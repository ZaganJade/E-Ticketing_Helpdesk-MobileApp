import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/shadcn_theme.dart';
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
    showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Tandai Semua Dibaca'),
        description: const Text(
          'Apakah Anda yakin ingin menandai semua notifikasi sebagai sudah dibaca?',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ShadButton(
            backgroundColor: ShadcnTheme.accent,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Ya, Tandai',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: ShadTheme.of(context).colorScheme.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent.withValues(alpha: 0.2),
                      ShadcnTheme.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<NotifikasiCubit, NotifikasiState>(
              bloc: _cubit,
              builder: (context, state) {
                final hasUnread = state is NotifikasiListLoaded &&
                    state.unreadCount > 0;

                if (!hasUnread) return const SizedBox.shrink();

                return ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: _onMarkAllAsRead,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: isTablet ? 18 : 16,
                        color: ShadcnTheme.accent,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        isTablet ? 'Tandai Semua' : 'Semua',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: ShadcnTheme.accent,
                        ),
                      ),
                    ],
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 12 : 8,
                  ),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected: state is! NotifikasiListLoaded ||
                            !state.showUnreadOnly,
                        onTap: () => _cubit.toggleFilter(false),
                        isTablet: isTablet,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      _FilterChip(
                        label: 'Belum Dibaca',
                        isSelected: state is NotifikasiListLoaded &&
                            state.showUnreadOnly,
                        count: state is NotifikasiListLoaded
                            ? state.unreadCount
                            : null,
                        onTap: () => _cubit.toggleFilter(true),
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(state, isDark, isTablet),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(NotifikasiState state, bool isDark, bool isTablet) {
    // Show loading for initial state or explicit loading state
    if (state is NotifikasiLoading || state is NotifikasiInitial) {
      return _buildLoadingList(isDark, isTablet);
    }

    if (state is NotifikasiError) {
      return _buildErrorState(state.message, isTablet);
    }

    // Show refreshing animation with current data
    if (state is NotifikasiRefreshing) {
      return Stack(
        children: [
          // Show current list dimmed
          Opacity(
            opacity: 0.5,
            child: _buildNotifikasiList(
              state.currentList, false, false, isTablet),
          ),
          // Show animated loading indicator at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ShadcnTheme.accent.withValues(alpha: 0.1),
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
                        child: Icon(
                          Icons.sync_rounded,
                          color: ShadcnTheme.accent,
                          size: isTablet ? 22 : 20,
                        ),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Memperbarui data...',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: ShadcnTheme.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  LinearProgressIndicator(
                    backgroundColor: ShadcnTheme.accent.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ShadcnTheme.accent,
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
            _cubit.resetHasNewData();
          });
      }

      if (state.notifikasiList.isEmpty) {
        return _buildEmptyState(isDark, isTablet);
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildNotifikasiList(
          state.notifikasiList,
          state.hasMore,
          state.isLoadingMore,
          isTablet,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingList(bool isDark, bool isTablet) {
    return ListView.separated(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: isTablet ? 16 : 12),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon skeleton
              Container(
                width: isTablet ? 44 : 40,
                height: isTablet ? 44 : 40,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: isTablet ? 16 : 14,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 8),
                    Container(
                      width: double.infinity,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, bool isTablet) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 24 : 16),
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: ShadcnTheme.statusOpen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ShadcnTheme.statusOpen.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isTablet ? 56 : 48,
              color: ShadcnTheme.statusOpen,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Gagal memuat notifikasi',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ShadButton(
              backgroundColor: ShadcnTheme.accent,
              onPressed: () => _cubit.refresh(),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isTablet) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 24 : 16),
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: isTablet ? 56 : 48,
              color: isDark
                  ? ShadcnTheme.darkMutedForeground
                  : ShadcnTheme.mutedForeground,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini',
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ShadButton.outline(
              onPressed: () => _cubit.refresh(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: isTablet ? 18 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifikasiList(
    List<NotifikasiModel> notifikasiList,
    bool hasMore,
    bool isLoadingMore,
    bool isTablet,
  ) {
    return RefreshIndicator(
      onRefresh: () => _cubit.refresh(),
      color: ShadcnTheme.accent,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        itemCount: notifikasiList.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: isTablet ? 12 : 8),
        itemBuilder: (context, index) {
          if (index == notifikasiList.length) {
            return isLoadingMore
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ShadcnTheme.accent,
                        ),
                      ),
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
  final bool isTablet;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ShadcnTheme.accent.withValues(alpha: 0.1)
              : (isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ShadcnTheme.accent
                : (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? ShadcnTheme.accent
                    : ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            if (count != null && count! > 0) ...[
              SizedBox(width: isTablet ? 10 : 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: ShadcnTheme.statusOpen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count! > 99 ? '99+' : count!.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
