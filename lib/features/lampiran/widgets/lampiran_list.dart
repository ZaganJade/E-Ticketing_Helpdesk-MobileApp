import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/app_modal.dart';
import '../cubits/lampiran_cubit.dart';
import '../models/lampiran_model.dart';
import '../utils/download_helper.dart';
import '../utils/permission_handler.dart';
import 'lampiran_preview.dart';

class LampiranList extends StatefulWidget {
  final String tiketId;
  final bool canDelete;

  const LampiranList({
    super.key,
    required this.tiketId,
    this.canDelete = true,
  });

  @override
  State<LampiranList> createState() => _LampiranListState();
}

class _LampiranListState extends State<LampiranList> {
  late final LampiranCubit _cubit;
  final DownloadHelper _downloadHelper = DownloadHelper();
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};

  @override
  void initState() {
    super.initState();
    _cubit = LampiranCubit();
    _cubit.loadLampiran(widget.tiketId);
  }

  @override
  void dispose() {
    _cubit.close();
    _downloadHelper.cancelDownload();
    super.dispose();
  }

  void _onLampiranTap(LampiranModel lampiran) {
    if (lampiran.isImage) {
      showDialog(
        context: context,
        builder: (_) => LampiranPreview(lampiran: lampiran),
      );
    } else {
      // For non-images, show download dialog
      _showDownloadDialog(lampiran);
    }
  }

  Future<void> _downloadFile(LampiranModel lampiran) async {
    setState(() {
      _isDownloading[lampiran.id] = true;
      _downloadProgress[lampiran.id] = 0;
    });

    try {
      // Check permission first
      final hasPermission = await LampiranPermissionHandler.requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }

      final path = await _downloadHelper.downloadFile(
        lampiran,
        onProgress: (received, total) {
          setState(() {
            _downloadProgress[lampiran.id] = received / total;
          });
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading[lampiran.id] = false;
        });

        // Show success and option to share
        _showDownloadSuccess(lampiran, path);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading[lampiran.id] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    AppModal.showConfirmation(
      context: context,
      title: 'Izin Diperlukan',
      message: 'Aplikasi memerlukan izin penyimpanan untuk mengunduh file. Buka pengaturan aplikasi?',
      confirmText: 'Buka Pengaturan',
    ).then((confirmed) {
      if (confirmed == true) {
        LampiranPermissionHandler.openAppSettings();
      }
    });
  }

  void _showDownloadDialog(LampiranModel lampiran) {
    final isDownloading = _isDownloading[lampiran.id] ?? false;
    final progress = _downloadProgress[lampiran.id] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lampiran.namaFile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ukuran: ${lampiran.formattedSize}'),
            const SizedBox(height: AppSpacing.default_),
            if (isDownloading) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: AppSpacing.xs),
              Text('${(progress * 100).toInt()}%'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (!isDownloading)
            AppButton(
              label: 'Unduh',
              onPressed: () {
                Navigator.pop(context);
                _downloadFile(lampiran);
              },
            ),
        ],
      ),
    );
  }

  void _showDownloadSuccess(LampiranModel lampiran, String path) {
    AppModal.showInfo(
      context: context,
      title: 'Download Selesai',
      message: 'File "${lampiran.namaFile}" berhasil diunduh.',
      buttonText: 'Bagikan',
    );

    // Optionally share the file
    if (Platform.isAndroid || Platform.isIOS) {
      Share.shareXFiles([XFile(path)], text: lampiran.namaFile);
    }
  }

  void _onDeleteLampiran(LampiranModel lampiran) {
    AppModal.showConfirmation(
      context: context,
      title: 'Hapus Lampiran',
      message: 'Yakin ingin menghapus lampiran "${lampiran.namaFile}"?',
      confirmText: 'Hapus',
      confirmVariant: AppButtonVariant.destructive,
    ).then((confirmed) {
      if (confirmed == true) {
        _cubit.deleteLampiran(lampiran.id, widget.tiketId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LampiranCubit, LampiranState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is LampiranLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.default_),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is LampiranError) {
          return Center(
            child: Text(
              'Gagal memuat lampiran',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
              ),
            ),
          );
        }

        if (state is LampiranListLoaded) {
          if (state.lampiranList.isEmpty) {
            return EmptyState(
              icon: Icons.attach_file,
              title: 'Belum ada lampiran',
              subtitle: 'File yang dilampirkan akan muncul di sini',
            );
          }

          return _LampiranGrid(
            lampiranList: state.lampiranList,
            onTap: _onLampiranTap,
            onDelete: widget.canDelete ? _onDeleteLampiran : null,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _LampiranGrid extends StatelessWidget {
  final List<LampiranModel> lampiranList;
  final Function(LampiranModel) onTap;
  final Function(LampiranModel)? onDelete;

  const _LampiranGrid({
    required this.lampiranList,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.default_),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.default_,
        mainAxisSpacing: AppSpacing.default_,
        childAspectRatio: 0.8,
      ),
      itemCount: lampiranList.length,
      itemBuilder: (context, index) {
        final lampiran = lampiranList[index];
        return _LampiranGridItem(
          lampiran: lampiran,
          onTap: () => onTap(lampiran),
          onDelete: onDelete != null ? () => onDelete!(lampiran) : null,
        );
      },
    );
  }
}

class _LampiranGridItem extends StatelessWidget {
  final LampiranModel lampiran;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _LampiranGridItem({
    required this.lampiran,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.buttonRadius,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: AppBorderRadius.buttonRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Expanded(
                  child: lampiran.isImage
                      ? _buildImageThumbnail()
                      : _buildFileIcon(),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lampiran.namaFile,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lampiran.formattedSize,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: AppColors.error.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppBorderRadius.buttonRadius.topLeft.x),
      ),
      child: Image.network(
        lampiran.pathFile,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFileIcon(),
      ),
    );
  }

  Widget _buildFileIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lampiran.iconData,
            size: 40,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            lampiran.tipeFile.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class LampiranListView extends StatelessWidget {
  final List<LampiranModel> lampiranList;
  final Function(LampiranModel) onTap;
  final Function(LampiranModel)? onDelete;

  const LampiranListView({
    super.key,
    required this.lampiranList,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lampiranList.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.default_),
      itemBuilder: (context, index) {
        final lampiran = lampiranList[index];
        return _LampiranListItem(
          lampiran: lampiran,
          onTap: () => onTap(lampiran),
          onDelete: onDelete != null ? () => onDelete!(lampiran) : null,
        );
      },
    );
  }
}

class _LampiranListItem extends StatelessWidget {
  final LampiranModel lampiran;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _LampiranListItem({
    required this.lampiran,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.default_),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppBorderRadius.buttonRadius,
            ),
            child: Icon(
              lampiran.iconData,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.default_),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lampiran.namaFile,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${lampiran.formattedSize} • ${lampiran.tipeFile.toUpperCase()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
