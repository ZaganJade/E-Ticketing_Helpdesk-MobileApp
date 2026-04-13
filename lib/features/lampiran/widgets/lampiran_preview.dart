import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/lampiran_model.dart';

class LampiranPreview extends StatelessWidget {
  final LampiranModel lampiran;

  const LampiranPreview({
    super.key,
    required this.lampiran,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
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
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat gambar',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: AppColors.overlay.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          // File info at bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.overlay.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lampiran.namaFile,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lampiran.formattedSize} • ${lampiran.tipeFile.toUpperCase()}',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
