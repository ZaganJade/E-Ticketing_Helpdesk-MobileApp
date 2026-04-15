import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../models/lampiran_model.dart';
import 'dart:ui';

/// Lampiran (Attachment) Preview Widget - Redesigned with shadcn_ui
/// Displays images with zoom/pan capabilities and file information
class LampiranPreview extends StatelessWidget {
  final LampiranModel lampiran;
  final VoidCallback? onDownload;

  const LampiranPreview({
    super.key,
    required this.lampiran,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('LampiranPreview: Loading image from ${lampiran.fullUrl}');
    debugPrint('LampiranPreview: isImage=${lampiran.isImage}, tipeFile=${lampiran.tipeFile}');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop blur background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        // Main content
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
              vertical: isTablet ? 40 : 20,
            ),
            constraints: BoxConstraints(
              maxWidth: isTablet ? size.width * 0.9 : size.width - 32,
              maxHeight: isTablet ? size.height * 0.85 : size.height - 80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image container - responsive
                    Flexible(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(20),
                        child: Image.network(
                          lampiran.fullUrl,
                          fit: BoxFit.contain,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return child;
                            }
                            return Container(
                              color: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
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
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('LampiranPreview error: $error');
                            debugPrint('LampiranPreview URL: ${lampiran.fullUrl}');
                            return Container(
                              color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                            );
                          },
                        ),
                      ),
                    ),
                    // File info bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 10 : 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ShadcnTheme.accent.withValues(alpha: 0.3),
                                  ShadcnTheme.accent.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.image,
                              size: isTablet ? 22 : 18,
                              color: ShadcnTheme.accent,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: onDownload,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          lampiran.namaFile,
                                          style: TextStyle(
                                            fontSize: isTablet ? 15 : 13,
                                            fontWeight: FontWeight.w600,
                                            color: ShadcnTheme.accent,
                                            decoration: TextDecoration.underline,
                                            decorationColor: ShadcnTheme.accent,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.download,
                                        size: isTablet ? 18 : 16,
                                        color: ShadcnTheme.accent,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${lampiran.formattedSize} • ${lampiran.tipeFile.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 11,
                                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ShadButton.ghost(
                            size: ShadButtonSize.sm,
                            onPressed: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Close button (top right)
        Positioned(
          top: isTablet ? 16 : 8,
          right: isTablet ? 16 : 8,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: isTablet ? 44 : 40,
              height: isTablet ? 44 : 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
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
      ],
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
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getFileColor() {
    if (lampiran.isImage) return const Color(0xFF10B981); // Green
    if (lampiran.isPdf) return const Color(0xFFEF4444); // Red
    if (lampiran.isDoc) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF64748B); // Gray
  }
}
