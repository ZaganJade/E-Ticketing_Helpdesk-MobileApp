import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../cubit/komentar_cubit.dart';
import 'komentar_card.dart';

/// Widget for displaying a list of komentar with realtime updates
/// Returns a SliverList for use inside CustomScrollView
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
  String? _lastKomentarId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KomentarCubit(
        komentarRepository: getIt<KomentarRepository>(),
      )..loadKomentar(widget.tiketId)
        ..subscribeToRealtimeUpdates(widget.tiketId),
      child: BlocConsumer<KomentarCubit, KomentarState>(
        listener: (context, state) {
          if (state is KomentarLoaded && state.komentarList.isNotEmpty) {
            final lastKomentar = state.komentarList.last;
            _lastKomentarId ??= lastKomentar.id;
          }
        },
        builder: (context, state) {
          if (state is KomentarLoading) {
            return _buildLoadingSliver();
          }

          if (state is KomentarError) {
            return _buildErrorSliver(context, state.message);
          }

          if (state is KomentarLoaded) {
            if (state.isEmpty) {
              return _buildEmptySliver();
            }
            return _buildKomentarSliverList(state);
          }

          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.default_,
              right: AppSpacing.default_,
              bottom: AppSpacing.default_,
            ),
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
        childCount: 3,
      ),
    );
  }

  Widget _buildErrorSliver(BuildContext context, String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorState(
        title: 'Gagal memuat komentar',
        subtitle: message,
        onRetry: () {
          context.read<KomentarCubit>().refresh();
        },
      ),
    );
  }

  Widget _buildEmptySliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Belum ada komentar',
        subtitle: 'Jadilah yang pertama memberikan komentar pada tiket ini',
        actionLabel: 'Refresh',
        onAction: () {
          context.read<KomentarCubit>().refresh();
        },
      ),
    );
  }

  Widget _buildKomentarSliverList(KomentarLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.default_,
        vertical: AppSpacing.sm,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final komentar = state.komentarList[index];
            final isCurrentUser = komentar.penulisId == widget.currentUserId;
            final isNew = komentar.id == state.newKomentarId;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.default_),
              child: KomentarCard(
                komentar: komentar,
                isCurrentUser: isCurrentUser,
                isNew: isNew,
              ),
            );
          },
          childCount: state.komentarList.length,
        ),
      ),
    );
  }
}
