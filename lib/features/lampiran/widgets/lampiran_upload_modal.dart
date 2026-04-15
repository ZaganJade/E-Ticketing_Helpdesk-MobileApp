import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import 'lampiran_upload.dart';

/// Modal wrapper for LampiranUpload with backdrop blur
/// UI exactly matching the screenshot design
class LampiranUploadModal extends StatelessWidget {
  final String tiketId;
  final Function(dynamic)? onUploaded;
  final VoidCallback? onClose;

  const LampiranUploadModal({
    super.key,
    required this.tiketId,
    this.onUploaded,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop blur background with blur sigma
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        // Main content - centered modal
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? 48 : 24,
              vertical: isTablet ? 40 : 20,
            ),
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : size.width - 48,
              maxHeight: isTablet ? size.height * 0.75 : size.height - 80,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Matching screenshot exactly
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Upload icon in rounded square - exactly like screenshot
                        Container(
                          width: isTablet ? 48 : 44,
                          height: isTablet ? 48 : 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            color: const Color(0xFF0EA5E9),
                            size: isTablet ? 26 : 24,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload Lampiran',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pilih file untuk diupload',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button - X icon
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: isTablet ? 36 : 32,
                            height: isTablet ? 36 : 32,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content - scrollable
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      child: LampiranUpload(
                        tiketId: tiketId,
                        onUploaded: onUploaded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
