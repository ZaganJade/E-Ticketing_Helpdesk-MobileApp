import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../models/lampiran_model.dart';

/// Lampiran (Attachment) Preview Widget - Redesigned with shadcn_ui
/// Displays images with zoom/pan capabilities and file information
class LampiranPreview extends StatelessWidget {
  final LampiranModel lampiran;

  const LampiranPreview({
    super.key,
    required this.lampiran,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return ShadDialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 800 : size.width - 32,
          maxHeight: isTablet ? 600 : size.height - 100,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with zoom and pan
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lampiran.pathFile,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memuat gambar...',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ShadcnTheme.destructive.withValues(alpha: 0.2),
                                ShadcnTheme.destructive.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: isTablet ? 56 : 48,
                            color: ShadcnTheme.destructive,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: ShadTheme.of(context).colorScheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Periksa koneksi internet Anda',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: isTablet ? 16 : 12,
              right: isTablet ? 16 : 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: isTablet ? 44 : 40,
                  height: isTablet ? 44 : 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // File info at bottom
            Positioned(
              bottom: isTablet ? 16 : 12,
              left: isTablet ? 16 : 12,
              right: isTablet ? 16 : 12,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
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
                            ShadcnTheme.accent.withValues(alpha: 0.4),
                            ShadcnTheme.accent.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.image,
                        size: isTablet ? 24 : 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lampiran.namaFile,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${lampiran.formattedSize} • ${lampiran.tipeFile.toUpperCase()}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ShadButton.ghost(
                      size: ShadButtonSize.sm,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Non-image file preview dialog
class LampiranFilePreview extends StatelessWidget {
  final LampiranModel lampiran;
  final VoidCallback? onDownload;

  const LampiranFilePreview({
    super.key,
    required this.lampiran,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final fileColor = _getFileColor();

    return ShadDialog.alert(
      title: Text(lampiran.namaFile),
      description: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  fileColor.withValues(alpha: 0.2),
                  fileColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              lampiran.iconData,
              size: isTablet ? 64 : 48,
              color: fileColor,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          _buildInfoRow('Nama File', lampiran.namaFile, isTablet),
          const SizedBox(height: 8),
          _buildInfoRow('Ukuran', lampiran.formattedSize, isTablet),
          const SizedBox(height: 8),
          _buildInfoRow('Format', lampiran.tipeFile.toUpperCase(), isTablet),
        ],
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (onDownload != null)
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              onDownload!();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 8),
                Text('Unduh'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getFileColor() {
    if (lampiran.isImage) return ShadcnTheme.accent;
    if (lampiran.isPdf) return ShadcnTheme.statusOpen;
    if (lampiran.isDoc) return ShadcnTheme.statusInProgress;
    return ShadcnTheme.statusDone;
  }
}
