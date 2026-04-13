import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../cubit/komentar_cubit.dart';
import 'komentar_card.dart';

/// Widget for displaying a list of komentar with realtime updates
class KomentarList extends StatefulWidget {
  final String tiketId;
  final String currentUserId;

  const KomentarList({
    super.key,
    required this.tiketId,
    required this.currentUserId,
  });

  @override
  State<KomentarList> createState() => _KomentarListState();
}

class _KomentarListState extends State<KomentarList> {
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoScroll = true;
  String? _lastKomentarId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user is near bottom (within 100 pixels)
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isNearBottom = (maxScroll - currentScroll) < 100;

    setState(() {
      _shouldAutoScroll = isNearBottom;
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    if (animate) {
      _scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(maxScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KomentarCubit(
        komentarRepository: getIt<KomentarRepository>(),
      )..loadKomentar(widget.tiketId)
        ..subscribeToRealtimeUpdates(widget.tiketId),
      child: BlocConsumer<KomentarCubit, KomentarState>(
        listener: (context, state) {
          if (state is KomentarLoaded) {
            // Check if there are new komentar
            if (state.komentarList.isNotEmpty) {
              final lastKomentar = state.komentarList.last;

              // If new komentar added
              if (_lastKomentarId != null &&
                  lastKomentar.id != _lastKomentarId &&
                  _shouldAutoScroll) {
                // Scroll to show new komentar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }

              // If there are new unread komentar and we're at bottom
              if (state.hasNewKomentar && _shouldAutoScroll) {
                context.read<KomentarCubit>().markNewKomentarAsSeen();
              }

              _lastKomentarId = lastKomentar.id;
            }
          }
        },
        builder: (context, state) {
          if (state is KomentarLoading) {
            return _buildLoadingState();
          }

          if (state is KomentarError) {
            return _buildErrorState(context, state.message);
          }

          if (state is KomentarLoaded) {
            if (state.isEmpty) {
              return _buildEmptyState();
            }
            return _buildKomentarList(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.default_),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.default_),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoading(width: 36, height: 36, borderRadius: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoading(width: 120, height: 14),
                    const SizedBox(height: AppSpacing.xs),
                    const SkeletonLoading(width: double.infinity, height: 60),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorState(
      title: 'Gagal memuat komentar',
      subtitle: message,
      onRetry: () {
        context.read<KomentarCubit>().refresh();
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Belum ada komentar',
      subtitle: 'Jadilah yang pertama memberikan komentar pada tiket ini',
      actionLabel: 'Refresh',
      onAction: () {
        context.read<KomentarCubit>().refresh();
      },
    );
  }

  Widget _buildKomentarList(KomentarLoaded state) {
    // Initial scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastKomentarId == null) {
        _scrollToBottom(animate: false);
        if (state.komentarList.isNotEmpty) {
          _lastKomentarId = state.komentarList.last.id;
        }
      }
    });

    return Column(
      children: [
        // New komentar indicator (when not at bottom)
        if (state.hasNewKomentar && !_shouldAutoScroll)
          _buildNewKomentarIndicator(context),

        // Komentar list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.default_,
              vertical: AppSpacing.sm,
            ),
            itemCount: state.komentarList.length,
            itemBuilder: (context, index) {
              final komentar = state.komentarList[index];
              final isCurrentUser = komentar.penulisId == widget.currentUserId;
              final isNew = komentar.id == state.newKomentarId;

              return AnimatedSlide(
                offset: isNew ? const Offset(0, 0.5) : Offset.zero,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: KomentarCard(
                  komentar: komentar,
                  isCurrentUser: isCurrentUser,
                  isNew: isNew,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewKomentarIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _scrollToBottom();
        context.read<KomentarCubit>().markNewKomentarAsSeen();
      },
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.default_),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.default_,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_downward,
              color: AppColors.white,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Komentar baru',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
