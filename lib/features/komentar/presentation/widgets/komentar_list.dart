import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../cubit/komentar_cubit.dart';
import 'komentar_card.dart';

/// Widget for displaying a list of komentar with realtime updates - Redesigned with shadcn_ui
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

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
            return _buildLoadingSliver(isDark, isTablet);
          }

          if (state is KomentarError) {
            return _buildErrorSliver(context, state.message, isTablet);
          }

          if (state is KomentarLoaded) {
            if (state.isEmpty) {
              return _buildEmptySliver(isDark, isTablet);
            }
            return _buildKomentarSliverList(state, isTablet);
          }

          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }

  Widget _buildLoadingSliver(bool isDark, bool isTablet) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar skeleton
                Container(
                  width: isTablet ? 40 : 36,
                  height: isTablet ? 40 : 36,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name skeleton
                      Container(
                        width: 120,
                        height: isTablet ? 16 : 14,
                        decoration: BoxDecoration(
                          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Message skeleton
                      Container(
                        width: double.infinity,
                        height: isTablet ? 70 : 60,
                        decoration: BoxDecoration(
                          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                          ),
                        ),
                      ),
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

  Widget _buildErrorSliver(BuildContext context, String message, bool isTablet) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
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
                'Gagal memuat komentar',
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
                onPressed: () => context.read<KomentarCubit>().refresh(),
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
      ),
    );
  }

  Widget _buildEmptySliver(bool isDark, bool isTablet) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
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
                Icons.chat_bubble_outline_rounded,
                size: isTablet ? 56 : 48,
                color: isDark
                    ? ShadcnTheme.darkMutedForeground
                    : ShadcnTheme.mutedForeground,
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                'Belum ada komentar',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jadilah yang pertama memberikan komentar',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 20),
              ShadButton.outline(
                onPressed: () => context.read<KomentarCubit>().refresh(),
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
      ),
    );
  }

  Widget _buildKomentarSliverList(KomentarLoaded state, bool isTablet) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final komentar = state.komentarList[index];
            final isCurrentUser = komentar.penulisId == widget.currentUserId;
            final isNew = komentar.id == state.newKomentarId;

            return Padding(
              padding: EdgeInsets.only(
                bottom: isTablet ? 16 : 12,
              ),
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
