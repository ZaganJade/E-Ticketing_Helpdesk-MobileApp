import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../cubits/lampiran_cubit.dart';
import '../models/lampiran_model.dart';
import '../utils/download_helper.dart';
import '../utils/permission_handler.dart';
import 'lampiran_preview.dart';

/// Lampiran (Attachment) List Widget - Redesigned with shadcn_ui
/// Displays attachments in a responsive grid layout with download/preview capabilities
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
      showShadDialog(
        context: context,
        builder: (_) => LampiranPreview(lampiran: lampiran),
      );
    } else {
      _showDownloadDialog(lampiran);
    }
  }

  Future<void> _downloadFile(LampiranModel lampiran) async {
    setState(() {
      _isDownloading[lampiran.id] = true;
      _downloadProgress[lampiran.id] = 0;
    });

    try {
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
        _showDownloadSuccess(lampiran, path);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading[lampiran.id] = false;
        });
        _showErrorSnackBar('Gagal mengunduh: $e');
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Izin Diperlukan'),
        description: const Text(
          'Aplikasi memerlukan izin penyimpanan untuk mengunduh file. Buka pengaturan aplikasi?',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              LampiranPermissionHandler.openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(LampiranModel lampiran) {
    final isDownloading = _isDownloading[lampiran.id] ?? false;
    final progress = _downloadProgress[lampiran.id] ?? 0;

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(lampiran.namaFile),
        description: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ukuran: ${lampiran.formattedSize}'),
            const SizedBox(height: 16),
            if (isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: ShadcnTheme.muted,
                  valueColor: const AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (!isDownloading)
            ShadButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadFile(lampiran);
              },
              child: const Text('Unduh'),
            ),
        ],
      ),
    );
  }

  void _showDownloadSuccess(LampiranModel lampiran, String path) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Download Selesai'),
        description: Text('File "${lampiran.namaFile}" berhasil diunduh.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              if (Platform.isAndroid || Platform.isIOS) {
                Share.shareXFiles([XFile(path)], text: lampiran.namaFile);
              }
            },
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }

  void _onDeleteLampiran(LampiranModel lampiran) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Hapus Lampiran'),
        description: Text('Yakin ingin menghapus lampiran "${lampiran.namaFile}"?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deleteLampiran(lampiran.id, widget.tiketId);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShadcnTheme.destructive,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: ShadcnTheme.accent,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Text(
                  'Lampiran',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            // Content
            BlocBuilder<LampiranCubit, LampiranState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is LampiranLoading) {
                  return _buildSkeletonGrid(context, isDark, isTablet);
                }

                if (state is LampiranError) {
                  return ErrorState.server(
                    onRetry: () => _cubit.loadLampiran(widget.tiketId),
                  );
                }

                if (state is LampiranListLoaded) {
                  if (state.lampiranList.isEmpty) {
                    return const EmptyState.attachments();
                  }

                  return _LampiranGrid(
                    lampiranList: state.lampiranList,
                    onTap: _onLampiranTap,
                    onDelete: widget.canDelete ? _onDeleteLampiran : null,
                    isTablet: isTablet,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(BuildContext context, bool isDark, bool isTablet) {
    final crossAxisCount = isTablet ? 4 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: isDark ? ShadcnTheme.darkMutedForeground : ShadcnTheme.mutedForeground,
                    size: isTablet ? 32 : 24,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 10,
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
      ),
    );
  }

  }
}

/// Grid view for lampiran items
class _LampiranGrid extends StatelessWidget {
  final List<LampiranModel> lampiranList;
  final Function(LampiranModel) onTap;
  final Function(LampiranModel)? onDelete;
  final bool isTablet;

  const _LampiranGrid({
    required this.lampiranList,
    required this.onTap,
    this.onDelete,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isTablet ? 4 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: 0.8,
      ),
      itemCount: lampiranList.length,
      itemBuilder: (context, index) {
        final lampiran = lampiranList[index];
        return _LampiranGridItem(
          lampiran: lampiran,
          onTap: () => onTap(lampiran),
          onDelete: onDelete != null ? () => onDelete!(lampiran) : null,
          isTablet: isTablet,
        );
      },
    );
  }
}

/// Individual lampiran grid item
class _LampiranGridItem extends StatelessWidget {
  final LampiranModel lampiran;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isTablet;

  const _LampiranGridItem({
    required this.lampiran,
    required this.onTap,
    this.onDelete,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileColor = _getFileColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: lampiran.isImage
                        ? _buildImageThumbnail()
                        : _buildFileIcon(fileColor),
                  ),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lampiran.namaFile,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            fontWeight: FontWeight.w500,
                            color: ShadTheme.of(context).colorScheme.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lampiran.formattedSize,
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w400,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onDelete != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: isTablet ? 28 : 24,
                      height: isTablet ? 28 : 24,
                      decoration: BoxDecoration(
                        color: ShadcnTheme.destructive.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: isTablet ? 16 : 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFileColor() {
    if (lampiran.isImage) return ShadcnTheme.accent;
    if (lampiran.isPdf) return ShadcnTheme.statusOpen;
    if (lampiran.isDoc) return ShadcnTheme.statusInProgress;
    return ShadcnTheme.statusDone;
  }

  Widget _buildImageThumbnail() {
    return Image.network(
      lampiran.pathFile,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildFileIcon(_getFileColor()),
    );
  }

  Widget _buildFileIcon(Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              lampiran.iconData,
              size: isTablet ? 32 : 24,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lampiran.tipeFile.toUpperCase(),
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// List view for lampiran items (alternative layout)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lampiranList.length,
      separatorBuilder: (context, index) => SizedBox(height: isTablet ? 12 : 8),
      itemBuilder: (context, index) {
        final lampiran = lampiranList[index];
        final fileColor = _getFileColor(lampiran);

        return GestureDetector(
          onTap: () => onTap(lampiran),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: fileColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet ? 48 : 40,
                            height: isTablet ? 48 : 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  fileColor.withValues(alpha: 0.2),
                                  fileColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              lampiran.iconData,
                              color: fileColor,
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lampiran.namaFile,
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: ShadTheme.of(context).colorScheme.foreground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${lampiran.formattedSize} • ${lampiran.tipeFile.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w400,
                                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onDelete != null)
                            ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              onPressed: () => onDelete!(lampiran),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: ShadcnTheme.destructive,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFileColor(LampiranModel lampiran) {
    if (lampiran.isImage) return ShadcnTheme.accent;
    if (lampiran.isPdf) return ShadcnTheme.statusOpen;
    if (lampiran.isDoc) return ShadcnTheme.statusInProgress;
    return ShadcnTheme.statusDone;
  }
}
