import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';

class EditNamaPage extends StatefulWidget {
  final String namaSaatIni;
  final Function(String) onSave;

  const EditNamaPage({
    super.key,
    required this.namaSaatIni,
    required this.onSave,
  });

  @override
  State<EditNamaPage> createState() => _EditNamaPageState();
}

class _EditNamaPageState extends State<EditNamaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.namaSaatIni;
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    widget.onSave(_namaController.text.trim());

    // Simulate async operation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Menyimpan...',
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Edit Nama',
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.default_),
              child: AppButton(
                label: 'Simpan',
                size: AppButtonSize.small,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.default_),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInput(
                  label: 'Nama',
                  hint: 'Masukkan nama lengkap Anda',
                  controller: _namaController,
                  isRequired: true,
                  onChanged: (_) => setState(() {}),
                  onClear: () {
                    _namaController.clear();
                    setState(() {});
                  },
                  onSubmitted: () => _onSave(),
                  errorText: _namaController.text.isNotEmpty &&
                          _namaController.text.length < 3
                      ? 'Nama minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: AppSpacing.default_),
                Text(
                  'Nama ini akan ditampilkan di profil Anda dan digunakan dalam komunikasi di aplikasi.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
