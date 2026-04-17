import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../shared/widgets/success_animation.dart';
import '../cubits/tiket_cubit.dart';

/// Create Tiket Page - Redesigned with shadcn_ui
/// Form for creating new tickets
class CreateTiketPage extends StatefulWidget {
  const CreateTiketPage({super.key});

  @override
  State<CreateTiketPage> createState() => _CreateTiketPageState();
}

class _CreateTiketPageState extends State<CreateTiketPage> {
  late final TiketCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;
  final List<PlatformFile> _selectedFiles = [];
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxFiles = 5;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TiketCubit>();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    _cubit.createTiket(
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      lampiranFiles: _selectedFiles.isNotEmpty ? _selectedFiles : null,
    );
  }

  void _onCancel() {
    if (_judulController.text.isNotEmpty ||
        _deskripsiController.text.isNotEmpty ||
        _selectedFiles.isNotEmpty) {
      showShadDialog(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Batalkan Pembuatan Tiket'),
          description: const Text(
            'Perubahan yang Anda buat akan hilang. Yakin ingin membatalkan?',
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjutkan'),
            ),
            ShadButton.destructive(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _isAllowedFileType(String fileName) {
    final lower = fileName.toLowerCase();
    final allowedExtensions = [
      // Images
      '.jpg', '.jpeg', '.png',
      // Documents
      '.pdf',
      '.doc', '.docx',
      '.xls', '.xlsx',
      '.ppt', '.pptx',
    ];
    return allowedExtensions.any((ext) => lower.endsWith(ext));
  }

  Future<void> _pickFiles() async {
    if (!mounted) return;

    if (_selectedFiles.length >= _maxFiles) {
      _showMaxFilesToast();
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        // Images
        'jpg', 'jpeg', 'png',
        // Documents
        'pdf',
        'doc', 'docx',
        'xls', 'xlsx',
        'ppt', 'pptx',
      ],
      allowMultiple: true,
      withData: true,
      withReadStream: true,
    );

    if (result != null && result.files.isNotEmpty && mounted) {
      final validFiles = result.files.where((file) {
        if (file.size > _maxFileSize) return false;
        if (!_isAllowedFileType(file.name)) return false;
        return true;
      }).toList();

      final rejectedCount = result.files.length - validFiles.length;

      if (rejectedCount > 0) {
        _showRejectedFilesToast();
      } else if (validFiles.length < result.files.length) {
        _showOversizedFilesToast();
      }

      if (mounted) {
        setState(() {
          for (final file in validFiles) {
            if (_selectedFiles.length < _maxFiles) {
              _selectedFiles.add(file);
            }
          }
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (!mounted) return;

    if (_selectedFiles.length >= _maxFiles) {
      _showMaxFilesToast();
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    // Check if image type is allowed (JPG, PNG only)
    final fileName = pickedFile.name.toLowerCase();
    if (!(fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.png'))) {
      _showInvalidFileTypeToast();
      return;
    }

    final file = File(pickedFile.path);
    final fileSize = await file.length();

    if (fileSize > _maxFileSize) {
      _showOversizedFileToast();
      return;
    }

    final bytes = await file.readAsBytes();
    final platformFile = PlatformFile(
      name: pickedFile.name,
      size: bytes.length,
      bytes: bytes,
      path: pickedFile.path,
    );

    if (mounted) {
      setState(() {
        _selectedFiles.add(platformFile);
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;

    if (_selectedFiles.length >= _maxFiles) {
      _showMaxFilesToast();
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile == null || !mounted) return;

    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final platformFile = PlatformFile(
      name: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
      size: bytes.length,
      bytes: bytes,
      path: pickedFile.path,
    );

    if (mounted) {
      setState(() {
        _selectedFiles.add(platformFile);
      });
    }
  }

  void _showMaxFilesToast() {
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Maksimal file tercapai'),
        description: Text('Anda hanya dapat memilih maksimal $_maxFiles file'),
      ),
    );
  }

  void _showOversizedFileToast() {
    ShadToaster.of(context).show(
      const ShadToast(
        title: Text('File terlalu besar'),
        description: Text('Ukuran file maksimal 10MB'),
      ),
    );
  }

  void _showOversizedFilesToast() {
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Beberapa file dilewati'),
        description: const Text('File lebih dari 10MB tidak dapat diunggah'),
      ),
    );
  }

  void _showRejectedFilesToast() {
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Tipe file tidak didukung'),
        description: const Text(
          'Hanya file JPG, PNG, PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX yang diizinkan',
        ),
      ),
    );
  }

  void _showInvalidFileTypeToast() {
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Tipe file tidak didukung'),
        description: const Text(
          'Hanya file JPG dan PNG yang diizinkan untuk gambar',
        ),
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return BlocProvider(
      create: (_) => _cubit,
      child: BlocConsumer<TiketCubit, TiketState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is CreateTiketSuccess) {
            // Reset loading state and show success animation
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Show success animation (will navigate after animation completes)
              showSuccessAnimationAndNavigate(
                context,
                title: 'Tiket Berhasil Dibuat',
                message: 'Anda akan dialihkan ke halaman tiket',
              );
            }
          } else if (state is TiketError) {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          // Don't show loading if we're in success state
          final isLoading = _isLoading && state is! CreateTiketSuccess;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Buat Tiket Baru',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              leading: ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: _onCancel,
                child: const Icon(Icons.close, size: 24),
              ),
              leadingWidth: 64,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ShadButton(
                    size: ShadButtonSize.sm,
                    onPressed: isLoading ? null : _onSubmit,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
            body: isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Membuat tiket...',
                          style: TextStyle(
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          _buildHeaderCard(context, isTablet),
                          SizedBox(height: isTablet ? 24 : 16),

                          // Form Card
                          _buildFormCard(context, isTablet),
                          SizedBox(height: isTablet ? 24 : 16),

                          // Tips Card
                          _buildTipsCard(context, isTablet),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ShadButton(
                              size: isTablet ? ShadButtonSize.lg : null,
                              onPressed: _onSubmit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buat Tiket',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isTablet) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
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
              Icons.confirmation_number_outlined,
              color: ShadcnTheme.accent,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiket Baru',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi formulir berikut untuk membuat tiket',
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
    );
  }

  Widget _buildFormCard(BuildContext context, bool isTablet) {
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
          // Judul
          _buildInputLabel('Judul Tiket', isRequired: true, isTablet: isTablet),
          const SizedBox(height: 8),
          ShadInput(
            controller: _judulController,
            placeholder: const Text('Masukkan judul tiket...'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          if (_judulController.text.isNotEmpty &&
              _judulController.text.length < 5) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ShadcnTheme.destructive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ShadcnTheme.destructive.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: ShadcnTheme.destructive,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Judul minimal 5 karakter',
                      style: TextStyle(
                        fontSize: 13,
                        color: ShadcnTheme.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: isTablet ? 20 : 16),

          // Deskripsi
          _buildInputLabel('Deskripsi', isRequired: true, isTablet: isTablet),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deskripsiController,
            maxLines: 8,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Jelaskan masalah atau permintaan Anda secara detail...',
              hintStyle: TextStyle(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              filled: true,
              fillColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ShadcnTheme.accent,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Lampiran section
          _buildLampiranSection(context, isTablet, isDark),
        ],
      ),
    );
  }

  Widget _buildLampiranSection(BuildContext context, bool isTablet, bool isDark) {
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
          // Header with icon and count
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
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              const Spacer(),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ShadcnTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_selectedFiles.length/$_maxFiles',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Upload buttons
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 400) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildUploadButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Kamera',
                        onPressed: _takePhoto,
                        isTablet: isTablet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildUploadButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Galeri',
                        onPressed: _pickFromGallery,
                        isTablet: isTablet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildUploadButton(
                        icon: Icons.insert_drive_file_rounded,
                        label: 'Pilih File',
                        onPressed: _pickFiles,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildUploadButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Ambil Foto',
                      onPressed: _takePhoto,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildUploadButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Dari Galeri',
                      onPressed: _pickFromGallery,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildUploadButton(
                      icon: Icons.insert_drive_file_rounded,
                      label: 'Pilih File (PDF, DOC, XLS, PPT)',
                      onPressed: _pickFiles,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Selected files list or empty state
          if (_selectedFiles.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'File Terpilih',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _selectedFiles.length,
                (index) => _buildFileItem(
                  _selectedFiles[index],
                  index,
                  isTablet,
                  isDark,
                ),
              ),
            ),
          ] else
            _buildEmptyState(isTablet, isDark),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return ShadButton.outline(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTablet ? 20 : 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(
    PlatformFile file,
    int index,
    bool isTablet,
    bool isDark,
  ) {
    final sizeInMB = (file.size / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          Icon(
            _getFileIcon(file.name),
            size: isTablet ? 20 : 18,
            color: ShadcnTheme.accent,
          ),
          const SizedBox(width: 8),
          // File info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: isTablet ? 140 : 100,
                child: Text(
                  file.name,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$sizeInMB MB',
                style: TextStyle(
                  fontSize: isTablet ? 11 : 10,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Remove button
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () {
              setState(() {
                _selectedFiles.removeAt(index);
              });
            },
            child: const Icon(Icons.close_rounded, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDark) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: ShadcnTheme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ShadcnTheme.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: isTablet ? 48 : 40,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada file dipilih',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Maksimal $_maxFiles file, 10MB per file',
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  IconData _getFileIcon(String fileName) {
    final lower = fileName.toLowerCase();

    if (_isImageFile(lower)) {
      return Icons.image_rounded;
    }

    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }

    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_rounded;
    }

    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_view_rounded;
    }

    if (lower.endsWith('.ppt') || lower.endsWith('.pptx')) {
      return Icons.slideshow_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  Widget _buildInputLabel(String label, {required bool isRequired, required bool isTablet}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w500,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: ShadcnTheme.destructive,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
            ShadcnTheme.statusInProgress.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ShadcnTheme.statusInProgress.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: ShadcnTheme.statusInProgress.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: isTablet ? 22 : 20,
                  color: ShadcnTheme.statusInProgress,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Text(
                'Tips Membuat Tiket',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: ShadcnTheme.statusInProgress,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildTipItem('Berikan judul yang jelas dan singkat', isTablet),
          _buildTipItem('Jelaskan masalah secara detail', isTablet),
          _buildTipItem('Sertakan langkah-langkah yang sudah dicoba', isTablet),
          _buildTipItem('Lampirkan screenshot jika diperlukan', isTablet),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 8 : 6,
            height: isTablet ? 8 : 6,
            margin: EdgeInsets.only(top: isTablet ? 8 : 7),
            decoration: BoxDecoration(
              color: ShadcnTheme.statusInProgress.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}