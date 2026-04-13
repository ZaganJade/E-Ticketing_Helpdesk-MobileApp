import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../cubits/profil_cubit.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final ProfilCubit _cubit = ProfilCubit();
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cubit.close();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackbar.error(context, 'Password baru dan konfirmasi tidak cocok');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _cubit.updatePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilCubit, ProfilState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is PasswordUpdated) {
          setState(() {
            _isLoading = false;
          });
          AppSnackbar.success(context, 'Password berhasil diubah');
          Navigator.pop(context);
        } else if (state is ProfilError) {
          setState(() {
            _isLoading = false;
          });
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: _isLoading,
          message: 'Mengupdate password...',
          child: Scaffold(
            appBar: AppAppBar(
              title: 'Ubah Password',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.default_),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info box
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.default_),
                      decoration: BoxDecoration(
                        color: AppColors.statusDiproses.withOpacity(0.1),
                        borderRadius: AppBorderRadius.buttonRadius,
                        border: Border.all(
                          color: AppColors.statusDiproses.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.statusDiproses,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Password minimal 8 karakter dan harus mengandung huruf serta angka.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.statusDiproses,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Old Password
                    AppPasswordInput(
                      label: 'Password Lama',
                      hint: 'Masukkan password lama Anda',
                      controller: _oldPasswordController,
                      isRequired: true,
                    ),
                    const SizedBox(height: AppSpacing.default_),

                    // New Password
                    AppPasswordInput(
                      label: 'Password Baru',
                      hint: 'Masukkan password baru',
                      controller: _newPasswordController,
                      isRequired: true,
                    ),
                    const SizedBox(height: AppSpacing.default_),

                    // Confirm Password
                    AppPasswordInput(
                      label: 'Konfirmasi Password Baru',
                      hint: 'Ulangi password baru',
                      controller: _confirmPasswordController,
                      isRequired: true,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Submit button
                    AppButton(
                      label: 'Simpan Password',
                      width: double.infinity,
                      onPressed: _onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
