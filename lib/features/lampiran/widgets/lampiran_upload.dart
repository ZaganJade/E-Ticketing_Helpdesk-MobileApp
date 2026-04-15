import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../cubits/lampiran_cubit.dart';
import '../models/lampiran_model.dart';
import '../utils/image_compressor.dart';
import '../utils/permission_handler.dart';

/// Lampiran (Attachment) Upload Widget
/// Layout: Kamera & Galeri (small, side by side), separator with "atau", File (full width with cloud)
class LampiranUpload extends StatefulWidget {
  final String tiketId;
  final Function(LampiranModel)? onUploaded;
  final bool enabled;

  const LampiranUpload({
    super.key,
    required this.tiketId,
    this.onUploaded,
    this.enabled = true,
  });

  @override
  State<LampiranUpload> createState() => _LampiranUploadState();
}

class _LampiranUploadState extends State<LampiranUpload> {
  final LampiranCubit _cubit = LampiranCubit();
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      File file = File(_selectedFile!.path!);

      final ext = _selectedFile!.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        file = await ImageCompressor.compressImage(file);

        if (file.path != _selectedFile!.path) {
          final compressedSize = await file.length();
          final originalSize = _selectedFile!.size;
          final savings = originalSize - compressedSize;
          final savingsPercent = (savings / originalSize * 100).toStringAsFixed(1);

          if (mounted) {
            _showSuccessSnackBar('Gambar dikompres: $savingsPercent% lebih kecil');
          }
        }
      }

      await _cubit.uploadLampiran(
        tiketId: widget.tiketId,
        file: file,
        fileName: _selectedFile!.name,
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showError('Gagal mengupload: $e');
    }
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFile = null;
      _isUploading = false;
      _uploadProgress = 0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShadcnTheme.destructive,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShadcnTheme.statusDone,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return LucideIcons.image;
    if (ext == 'pdf') return LucideIcons.fileText;
    if (['doc', 'docx'].contains(ext)) return LucideIcons.fileType;
    return LucideIcons.file;
  }

  Color _getFileColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return const Color(0xFF10B981); // Green
    if (ext == 'pdf') return const Color(0xFFEF4444); // Red
    if (['doc', 'docx'].contains(ext)) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF64748B); // Gray
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocConsumer<LampiranCubit, LampiranState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is LampiranUploaded) {
          setState(() {
            _isUploading = false;
            _selectedFile = null;
            _uploadProgress = 0;
          });
          widget.onUploaded?.call(state.lampiran);
        } else if (state is LampiranError) {
          setState(() {
            _isUploading = false;
          });
          _showError(state.message);
        } else if (state is LampiranUploading) {
          setState(() {
            _uploadProgress = state.progress;
          });
        }
      },
      builder: (context, state) {
        if (_selectedFile == null) {
          return _buildUploadArea(context, isDark, isTablet);
        } else {
          return _buildSelectedFile(context, isDark, isTablet);
        }
      },
    );
  }

  /// Build upload area with separator
  Widget _buildUploadArea(BuildContext context, bool isDark, bool isTablet) {
    return Column(
      children: [
        // Top row: Kamera (left) & Galeri (right) - smaller cards
        Row(
          children: [
            Expanded(
              child: _buildSmallOptionCard(
                context: context,
                icon: LucideIcons.camera,
                label: 'Kamera',
                onTap: widget.enabled ? () => _pickImageFromCamera() : null,
                isDark: isDark,
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _buildSmallOptionCard(
                context: context,
                icon: LucideIcons.images,
                label: 'Galeri',
                onTap: widget.enabled ? () => _pickImageFromGallery() : null,
                isDark: isDark,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        // Separator with "atau"
        Padding(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
                child: Text(
                  'atau',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
        // Bottom: File card with cloud icon and info - full width
        _buildWideOptionCard(
          context: context,
          icon: LucideIcons.cloudUpload,
          label: 'Pilih File dari Perangkat',
          subtitle: 'Maksimal 10MB. Format: JPG, PNG, PDF, DOC, DOCX',
          onTap: widget.enabled ? () => _pickFileFromDevice() : null,
          isDark: isDark,
          isTablet: isTablet,
        ),
      ],
    );
  }

  /// Small option card for Kamera & Galeri - compact size with white outline
  Widget _buildSmallOptionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
    required bool isTablet,
  }) {
    final isEnabled = onTap != null;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 20 : 16,
          horizontal: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in rounded square with light blue background
            Container(
              width: isTablet ? 40 : 36,
              height: isTablet ? 40 : 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: isTablet ? 20 : 18,
                color: isEnabled ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: isEnabled
                    ? (isDark ? Colors.white : const Color(0xFF1E293B))
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Wide option card for File - spans full width
  Widget _buildWideOptionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
    required bool isTablet,
  }) {
    final isEnabled = onTap != null;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 32 : 28,
          horizontal: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cloud icon in rounded square with light blue background
            Container(
              width: isTablet ? 56 : 52,
              height: isTablet ? 56 : 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: isTablet ? 30 : 28,
                color: isEnabled ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: isTablet ? 16 : 14),
            // Main label
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? (isDark ? Colors.white : const Color(0xFF1E293B))
                    : const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: isTablet ? 12 : 10),
            // Info subtitle with icon
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.info,
                  size: isTablet ? 16 : 14,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final cameraGranted = await LampiranPermissionHandler.requestCameraPermission();
      if (!cameraGranted) {
        _showError('Izin akses kamera diperlukan untuk mengambil foto');
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        final error = _cubit.validateFile(pickedFile.name, fileSize);
        if (error != null) {
          _showError(error);
          return;
        }

        setState(() {
          _selectedFile = PlatformFile(
            name: pickedFile.name,
            path: pickedFile.path,
            size: fileSize,
          );
        });
      }
    } catch (e) {
      _showError('Gagal mengambil foto: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final photosGranted = await LampiranPermissionHandler.requestPhotosPermission();
      if (!photosGranted) {
        _showError('Izin akses galeri diperlukan untuk memilih foto');
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        final error = _cubit.validateFile(pickedFile.name, fileSize);
        if (error != null) {
          _showError(error);
          return;
        }

        setState(() {
          _selectedFile = PlatformFile(
            name: pickedFile.name,
            path: pickedFile.path,
            size: fileSize,
          );
        });
      }
    } catch (e) {
      _showError('Gagal memilih gambar: $e');
    }
  }

  Future<void> _pickFileFromDevice() async {
    try {
      final canPick = await LampiranPermissionHandler.canPickFiles();
      if (!canPick) {
        final granted = await LampiranPermissionHandler.requestPhotosPermission();
        if (!granted) {
          _showError('Izin akses file diperlukan untuk memilih file');
          return;
        }
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileSize = file.size;
        final error = _cubit.validateFile(file.name, fileSize);
        if (error != null) {
          _showError(error);
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      _showError('Gagal memilih file: $e');
    }
  }

  /// Selected file UI
  Widget _buildSelectedFile(BuildContext context, bool isDark, bool isTablet) {
    final fileColor = _getFileColor(_selectedFile!.name);
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info row
          Row(
            children: [
              Container(
                width: isTablet ? 52 : 48,
                height: isTablet ? 52 : 48,
                decoration: BoxDecoration(
                  color: fileColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(_selectedFile!.name),
                  color: fileColor,
                  size: isTablet ? 26 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile!.name,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(_selectedFile!.size),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isUploading)
                GestureDetector(
                  onTap: _removeSelectedFile,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ShadcnTheme.destructive.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: ShadcnTheme.destructive,
                    ),
                  ),
                ),
            ],
          ),
          if (_isUploading) ...[
            SizedBox(height: isTablet ? 20 : 16),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mengupload...',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: isTablet ? 24 : 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: _removeSelectedFile,
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ShadButton(
                    onPressed: _uploadFile,
                    child: const Text('Upload'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
