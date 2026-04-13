import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../../lampiran/widgets/lampiran_upload.dart';
import '../cubits/tiket_cubit.dart';
import '../../../core/theme/app_border_radius.dart';

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

    _cubit.createTiket(
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
    );
  }

  void _onCancel() {
    if (_judulController.text.isNotEmpty ||
        _deskripsiController.text.isNotEmpty) {
      AppModal.showConfirmation(
        context: context,
        title: 'Batalkan Pembuatan Tiket',
        message: 'Perubahan yang Anda buat akan hilang. Yakin ingin membatalkan?',
        confirmText: 'Ya, Batalkan',
        cancelText: 'Lanjutkan',
        confirmVariant: AppButtonVariant.destructive,
      ).then((confirmed) {
        if (confirmed == true) {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: BlocConsumer<TiketCubit, TiketState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is CreateTiketSuccess) {
            Navigator.pop(context, true);
          } else if (state is TiketError) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is TiketLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Membuat tiket...',
            child: Scaffold(
              appBar: AppAppBar(
                title: 'Buat Tiket Baru',
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _onCancel,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.default_),
                    child: AppButton(
                      label: 'Simpan',
                      size: AppButtonSize.small,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
              body: _buildForm(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.default_),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            AppInput(
              label: 'Judul Tiket',
              hint: 'Masukkan judul tiket...',
              controller: _judulController,
              isRequired: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              onClear: () {
                _judulController.clear();
                setState(() {});
              },
              errorText: _judulController.text.isNotEmpty &&
                      _judulController.text.length < 5
                  ? 'Judul minimal 5 karakter'
                  : null,
            ),
            const SizedBox(height: AppSpacing.default_),

            // Deskripsi
            AppInput(
              label: 'Deskripsi',
              hint: 'Jelaskan masalah atau permintaan Anda secara detail...',
              controller: _deskripsiController,
              type: AppInputType.multiline,
              isRequired: true,
              maxLines: 8,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              onClear: () {
                _deskripsiController.clear();
                setState(() {});
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Lampiran Upload Section (10.25)
            Text(
              'Lampiran (Opsional)',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSpacing.xs),
            LampiranUpload(
              tiketId: 'temp', // Will be replaced with actual tiketId after creation
              enabled: false, // Disabled until tiket is created
              onUploaded: (lampiran) {
                AppSnackbar.success(context, 'Lampiran berhasil diupload');
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tips
            Container(
              padding: const EdgeInsets.all(AppSpacing.default_),
              decoration: BoxDecoration(
                color: AppColors.statusDiproses.withOpacity(0.1),
                borderRadius: AppBorderRadius.buttonRadius,
                border: Border.all(
                  color: AppColors.statusDiproses.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.statusDiproses,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Tips Membuat Tiket',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.statusDiproses,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '• Berikan judul yang jelas dan singkat\n'
                    '• Jelaskan masalah secara detail\n'
                    '• Sertakan langkah-langkah yang sudah dicoba\n'
                    '• Lampirkan screenshot jika diperlukan',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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
