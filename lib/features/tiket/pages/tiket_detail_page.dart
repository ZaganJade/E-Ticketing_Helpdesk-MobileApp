import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/widgets/widgets.dart';
import '../../komentar/presentation/cubit/komentar_cubit.dart';
import '../../komentar/presentation/widgets/komentar_list.dart';
import '../../komentar/presentation/widgets/komentar_input.dart';
import '../../lampiran/widgets/lampiran_list.dart';
import '../../lampiran/widgets/lampiran_upload.dart';
import '../cubits/tiket_cubit.dart';
import '../models/tiket_model.dart';

class TiketDetailPage extends StatefulWidget {
  final String tiketId;

  const TiketDetailPage({
    super.key,
    required this.tiketId,
  });

  @override
  State<TiketDetailPage> createState() => _TiketDetailPageState();
}

class _TiketDetailPageState extends State<TiketDetailPage> {
  late final TiketCubit _tiketCubit;
  late final KomentarCubit _komentarCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tiketCubit = getIt<TiketCubit>();
    _komentarCubit = getIt<KomentarCubit>();
    _tiketCubit.getTiketDetail(widget.tiketId);
    _komentarCubit.loadKomentar(widget.tiketId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy - HH:mm', 'id_ID').format(date);
  }

  TiketStatus _getStatusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return TiketStatus.terbuka;
      case 'DIPROSES':
        return TiketStatus.diproses;
      case 'SELESAI':
        return TiketStatus.selesai;
      default:
        return TiketStatus.terbuka;
    }
  }

  void _onStatusChanged(String? newStatus) {
    if (newStatus == null) return;

    AppModal.showConfirmation(
      context: context,
      title: 'Ubah Status Tiket',
      message: 'Apakah Anda yakin ingin mengubah status tiket menjadi ${newStatus.toLowerCase()}?',
    ).then((confirmed) {
      if (confirmed == true) {
        _tiketCubit.updateTiketStatus(widget.tiketId, newStatus);
      }
    });
  }

  void _onKomentarSubmitted(String message) {
    _komentarCubit.addKomentar(
      tiketId: widget.tiketId,
      isiPesan: message,
    );
  }

  void _showUploadLampiran(String tiketId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Upload Lampiran',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 16),
                LampiranUpload(
                  tiketId: tiketId,
                  onUploaded: (lampiran) {
                    Navigator.pop(context);
                    AppSnackbar.success(context, 'File berhasil diupload');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tiketCubit),
        BlocProvider.value(value: _komentarCubit),
      ],
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Detail Tiket',
        ),
        body: BlocConsumer<TiketCubit, TiketState>(
          bloc: _tiketCubit,
          listenWhen: (previous, current) =>
              current is CreateTiketSuccess || current is TiketError,
          listener: (context, state) {
            if (state is TiketError) {
              AppSnackbar.error(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is TiketLoading) {
              return const ListSkeleton(itemCount: 3);
            }

            if (state is TiketError) {
              return ErrorState.server(
                onRetry: () => _tiketCubit.getTiketDetail(widget.tiketId),
              );
            }

            if (state is TiketDetailLoaded) {
              return _buildDetailContent(state.tiket);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(TiketModel tiket) {
    return Column(
      children: [
        Expanded(
          child: AppRefreshWrapper(
            onRefresh: () async {
              await _tiketCubit.getTiketDetail(widget.tiketId);
              await _komentarCubit.loadKomentar(widget.tiketId);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(tiket),
                ),
                SliverToBoxAdapter(
                  child: _buildInfoSection(tiket),
                ),
                SliverToBoxAdapter(
                  child: _buildStatusControl(tiket),
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                // Lampiran Section (10.15)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.default_),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Lampiran',
                              style: AppTextStyles.subtitle,
                            ),
                            const Spacer(),
                            if (tiket.isTerbuka)
                              TextButton.icon(
                                onPressed: () => _showUploadLampiran(tiket.id),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Tambah'),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.default_),
                        LampiranList(
                          tiketId: widget.tiketId,
                          canDelete: tiket.isTerbuka,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.default_),
                    child: Text(
                      'Komentar',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KomentarList(
                    tiketId: widget.tiketId,
                    currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 100),
                ),
              ],
            ),
          ),
        ),
        KomentarInput(
          tiketId: widget.tiketId,
          onKomentarSubmitted: (komentar) => _onKomentarSubmitted(komentar.isiPesan),
        ),
      ],
    );
  }

  Widget _buildHeader(TiketModel tiket) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                status: _getStatusFromString(tiket.status),
                isLarge: true,
              ),
              const Spacer(),
              Text(
                _formatDate(tiket.dibuatPada),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.default_),
          Text(
            tiket.judul,
            style: AppTextStyles.headline,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(TiketModel tiket) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Dibuat Oleh',
            value: tiket.pembuatNama ?? 'Unknown',
          ),
          const SizedBox(height: AppSpacing.default_),
          if (tiket.penanggungJawabNama != null)
            _buildInfoRow(
              icon: Icons.support_agent,
              label: 'Penanggung Jawab',
              value: tiket.penanggungJawabNama!,
              valueColor: AppColors.primary,
            ),
          const SizedBox(height: AppSpacing.default_),
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Deskripsi',
            value: tiket.deskripsi,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusControl(TiketModel tiket) {
    return FutureBuilder<bool>(
      future: RoleUtils.canChangeTiketStatus(),
      builder: (context, snapshot) {
        // Don't show anything while loading or if user can't change status
        if (snapshot.connectionState == ConnectionState.waiting ||
            !(snapshot.data ?? false)) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.default_,
            vertical: AppSpacing.sm,
          ),
          child: AppStatusDropdown(
            label: 'Status Tiket',
            value: tiket.status,
            onChanged: _onStatusChanged,
          ),
        );
      },
    );
  }
}
