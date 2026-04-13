import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../cubits/lampiran_cubit.dart';
import '../models/lampiran_model.dart';
import '../utils/image_compressor.dart';
import '../utils/permission_handler.dart';

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
      // Check permission first
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
        withData: false, // Use path for compression
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file
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

      // Compress image if applicable
      final ext = _selectedFile!.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        file = await ImageCompressor.compressImage(file);

        // Update file info after compression
        if (file.path != _selectedFile!.path) {
          final compressedSize = await file.length();
          final originalSize = _selectedFile!.size;
          final savings = originalSize - compressedSize;
          final savingsPercent = (savings / originalSize * 100).toStringAsFixed(1);

          // Show compression info
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gambar dikompres: $savingsPercent% lebih kecil'),
                backgroundColor: AppColors.statusSelesai,
                duration: const Duration(seconds: 2),
              ),
            );
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
        backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedFile == null) ...[
              // Upload area
              InkWell(
                onTap: widget.enabled ? _pickFile : null,
                borderRadius: AppBorderRadius.cardRadius,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.surface,
                    borderRadius: AppBorderRadius.cardRadius,
                    border: Border.all(
                      color: widget.enabled
                          ? AppColors.border
                          : AppColors.border.withOpacity(0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: widget.enabled
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.default_),
                      Text(
                        'Klik untuk memilih file',
                        style: AppTextStyles.body.copyWith(
                          color: widget.enabled
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Maksimal 10MB. Format: JPG, PNG, PDF, DOC, DOCX',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Selected file preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.default_),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  borderRadius: AppBorderRadius.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: AppBorderRadius.buttonRadius,
                          ),
                          child: Icon(
                            _getFileIcon(_selectedFile!.name),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.default_),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFile!.name,
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _formatFileSize(_selectedFile!.size),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_isUploading)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _removeSelectedFile,
                            color: AppColors.error,
                          ),
                      ],
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: AppSpacing.default_),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Mengupload... ${(_uploadProgress * 100).toInt()}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.default_),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Batal',
                              variant: AppButtonVariant.ghost,
                              onPressed: _removeSelectedFile,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.default_),
                          Expanded(
                            child: AppButton(
                              label: 'Upload',
                              onPressed: _uploadFile,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
