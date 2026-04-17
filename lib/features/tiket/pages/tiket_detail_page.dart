import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../../core/services/date_service.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../komentar/presentation/cubit/komentar_cubit.dart';
import '../../komentar/presentation/widgets/komentar_input.dart';
import '../../komentar/presentation/widgets/komentar_list.dart';
import '../../lampiran/widgets/lampiran_list.dart';
import '../../lampiran/widgets/lampiran_upload_modal.dart';
import '../cubits/tiket_cubit.dart';
import '../models/tiket_model.dart';

/// Tiket Detail Page - Redesigned with shadcn_ui
/// Displays detailed ticket information with comments and attachments
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
  final GlobalKey<LampiranListState> _lampiranListKey = GlobalKey<LampiranListState>();

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
    final dateService = getIt<DateService>();
    return dateService.formatAbsoluteTime(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return ShadcnTheme.statusOpen;
      case 'DIPROSES':
        return ShadcnTheme.statusInProgress;
      case 'SELESAI':
        return ShadcnTheme.statusDone;
      default:
        return ShadcnTheme.zinc500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return Icons.radio_button_unchecked_rounded;
      case 'DIPROSES':
        return Icons.sync_rounded;
      case 'SELESAI':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return 'Terbuka';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  void _onStatusChanged(String newStatus) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Ubah Status Tiket'),
        description: Text(
          'Apakah Anda yakin ingin mengubah status tiket menjadi ${newStatus.toLowerCase()}?',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              _tiketCubit.updateTiketStatus(widget.tiketId, newStatus);
            },
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );
  }

  void _onKomentarSubmitted(String message) {
    _komentarCubit.refresh();
  }

  void _showUploadLampiran(String tiketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LampiranUploadModal(
        tiketId: tiketId,
        onUploaded: (lampiran) {
          Navigator.pop(context);
          // Refresh lampiran list to show the newly uploaded file
          _lampiranListKey.currentState?.refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('File berhasil diupload'),
              backgroundColor: ShadcnTheme.statusDone,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tiketCubit),
        BlocProvider.value(value: _komentarCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Tiket',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<TiketCubit, TiketState>(
          bloc: _tiketCubit,
          listenWhen: (previous, current) =>
              current is CreateTiketSuccess || current is TiketError,
          listener: (context, state) {
            if (state is TiketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ShadcnTheme.destructive,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TiketLoading || state is TiketInitial) {
              return _buildSkeleton(isTablet);
            }

            if (state is TiketError) {
              return ErrorState.server(
                onRetry: () => _tiketCubit.getTiketDetail(widget.tiketId),
              );
            }

            if (state is TiketDetailLoaded) {
              return _buildDetailContent(state.tiket, isTablet);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return ListView(
      padding: EdgeInsets.all(horizontalPadding),
      children: [
        // Header skeleton
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 32 : 28,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 16 : 14,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Container(
                width: double.infinity,
                height: isTablet ? 28 : 24,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        // Info skeleton
        ...List.generate(3, (index) => Container(
          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 16 : 14,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: isTablet ? 18 : 16,
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
        )),
      ],
    );
  }

  Widget _buildDetailContent(TiketModel tiket, bool isTablet) {
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _tiketCubit.getTiketDetail(widget.tiketId);
              await _komentarCubit.loadKomentar(widget.tiketId);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      children: [
                        _buildHeader(tiket, isTablet),
                        SizedBox(height: isTablet ? 16 : 12),
                        _buildInfoSection(tiket, isTablet),
                        SizedBox(height: isTablet ? 16 : 12),
                        _buildStatusControl(tiket, isTablet),
                      ],
                    ),
                  ),
                ),
                // Lampiran Section
                SliverToBoxAdapter(
                  child: _buildLampiranSection(tiket, isTablet),
                ),
                // Comments Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isTablet ? 24 : 20,
                      horizontalPadding,
                      isTablet ? 16 : 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 12 : 10),
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
                            Icons.chat_outlined,
                            color: ShadcnTheme.accent,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: ShadTheme.of(context).colorScheme.foreground,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Komentar list as proper sliver
                KomentarList(
                  tiketId: widget.tiketId,
                  currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
                ),
                // Small padding at bottom to prevent content being hidden behind input
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 8),
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

  Widget _buildHeader(TiketModel tiket, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(tiket.status);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor.withValues(alpha: 0.15),
                      statusColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(tiket.status),
                      size: isTablet ? 18 : 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusLabel(tiket.status),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Date
              Icon(
                Icons.schedule,
                size: isTablet ? 16 : 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(tiket.dibuatPada),
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w400,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // Title
          Text(
            tiket.judul,
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: ShadTheme.of(context).colorScheme.foreground,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(TiketModel tiket, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Dibuat Oleh',
            value: tiket.pembuatNama ?? 'Unknown',
            isTablet: isTablet,
          ),
          Divider(
            height: isTablet ? 24 : 20,
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
          if (tiket.penanggungJawabNama != null)
            Column(
              children: [
                _buildInfoRow(
                  icon: Icons.support_agent,
                  label: 'Penanggung Jawab',
                  value: tiket.penanggungJawabNama!,
                  valueColor: ShadcnTheme.accent,
                  isTablet: isTablet,
                ),
                Divider(
                  height: isTablet ? 24 : 20,
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                ),
              ],
            ),
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Deskripsi',
            value: tiket.deskripsi,
            isMultiLine: true,
            isTablet: isTablet,
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
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ShadcnTheme.accent.withValues(alpha: 0.15),
                ShadcnTheme.accent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isTablet ? 24 : 20,
            color: ShadcnTheme.accent,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ??
                      ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusControl(TiketModel tiket, bool isTablet) {
    return FutureBuilder<bool>(
      future: RoleUtils.canChangeTiketStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final canChangeStatus = snapshot.data ?? false;

        // Jika user tidak bisa ubah status (bukan helpdesk/admin), sembunyikan UI
        if (!canChangeStatus) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ShadcnTheme.statusInProgress.withValues(alpha: 0.2),
                          ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.update,
                      size: isTablet ? 24 : 20,
                      color: ShadcnTheme.statusInProgress,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Tiket',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            fontWeight: FontWeight.w600,
                            color: ShadTheme.of(context).colorScheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih status untuk mengubah status tiket',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              _buildStatusDropdown(tiket, isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown(TiketModel tiket, bool isTablet) {
    final statuses = [
      ('TERBUKA', 'Terbuka', ShadcnTheme.statusOpen, Icons.radio_button_unchecked_rounded),
      ('DIPROSES', 'Diproses', ShadcnTheme.statusInProgress, Icons.sync_rounded),
      ('SELESAI', 'Selesai', ShadcnTheme.statusDone, Icons.check_circle_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = tiket.status.toUpperCase() == status.$1;
        return GestureDetector(
          onTap: () => _onStatusChanged(status.$1),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        status.$3.withValues(alpha: 0.2),
                        status.$3.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? status.$3 : ShadTheme.of(context).colorScheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.$4,
                  size: isTablet ? 20 : 18,
                  color: status.$3,
                ),
                const SizedBox(width: 8),
                Text(
                  status.$2,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: status.$3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLampiranSection(TiketModel tiket, bool isTablet) {
    return LampiranList(
      key: _lampiranListKey,
      tiketId: widget.tiketId,
      canDelete: tiket.isTerbuka,
      onAdd: tiket.isTerbuka ? () => _showUploadLampiran(tiket.id) : null,
    );
  }
}
