import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../cubits/lampiran_cubit.dart';
import '../models/lampiran_model.dart';
import '../utils/image_compressor.dart';
import '../utils/permission_handler.dart';

/// Lampiran (Attachment) Upload Widget - Redesigned with shadcn_ui
/// Handles file selection, image compression, and upload with progress
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

  Future<void> _pickFile() async {
    try {
      final canPick = await LampiranPermissionHandler.canPickFiles();
      if (!canPick) {
        final granted = await LampiranPermissionHandler.requestPhotosPermission();
        if (!granted) {
          _showError('Izin akses file diperlukan untuk memilih file');
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
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
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return Icons.image;
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return ShadcnTheme.accent;
    if (ext == 'pdf') return ShadcnTheme.statusOpen;
    if (['doc', 'docx'].contains(ext)) return ShadcnTheme.statusInProgress;
    return ShadcnTheme.statusDone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

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
                        Icons.cloud_upload_outlined,
                        color: ShadcnTheme.accent,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Text(
                      'Upload Lampiran',
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
                if (_selectedFile == null)
                  _buildUploadArea(context, isDark, isTablet)
                else
                  _buildSelectedFile(context, isDark, isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadArea(BuildContext context, bool isDark, bool isTablet) {
    return GestureDetector(
      onTap: widget.enabled ? _pickFile : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: widget.enabled
              ? (isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted)
              : (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.enabled
                ? (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                : (isDark ? ShadcnTheme.darkBorder.withValues(alpha: 0.5) : ShadcnTheme.border.withValues(alpha: 0.5)),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ShadcnTheme.accent.withValues(alpha: 0.15),
                    ShadcnTheme.accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: isTablet ? 40 : 32,
                color: widget.enabled ? ShadcnTheme.accent : ShadcnTheme.mutedForeground,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Klik untuk memilih file',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: widget.enabled
                    ? ShadTheme.of(context).colorScheme.foreground
                    : ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Maksimal 10MB. Format: JPG, PNG, PDF, DOC, DOCX',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w400,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(BuildContext context, bool isDark, bool isTablet) {
    final fileColor = _getFileColor(_selectedFile!.name);

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
          Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      fileColor.withValues(alpha: 0.2),
                      fileColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(_selectedFile!.name),
                  color: fileColor,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile!.name,
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
                      _formatFileSize(_selectedFile!.size),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w400,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isUploading)
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: _removeSelectedFile,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: ShadcnTheme.destructive,
                  ),
                ),
            ],
          ),
          if (_isUploading) ...[
            SizedBox(height: isTablet ? 16 : 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                valueColor: const AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mengupload... ${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ] else ...[
            SizedBox(height: isTablet ? 20 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 400) {
                  return Row(
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
                  );
                }
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton(
                        onPressed: _uploadFile,
                        child: const Text('Upload'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton.outline(
                        onPressed: _removeSelectedFile,
                        child: const Text('Batal'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
