import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../cubits/profil_cubit.dart';

/// Ubah Password Page - Redesigned with shadcn_ui
/// Allows users to change their account password
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
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
      _showErrorSnackBar('Password baru dan konfirmasi tidak cocok');
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

    return BlocConsumer<ProfilCubit, ProfilState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is PasswordUpdated) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password berhasil diubah'),
              backgroundColor: ShadcnTheme.statusDone,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfilError) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Ubah Password',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            leading: ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 24),
            ),
            leadingWidth: 64,
          ),
          body: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mengupdate password...',
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
                        // Info Card
                        _buildInfoCard(context, isTablet),
                        SizedBox(height: isTablet ? 24 : 16),

                        // Form Card
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          decoration: BoxDecoration(
                            color: _isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Old Password
                              _buildPasswordField(
                                label: 'Password Lama',
                                hint: 'Masukkan password lama Anda',
                                controller: _oldPasswordController,
                                obscureText: _obscureOldPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureOldPassword = !_obscureOldPassword;
                                  });
                                },
                                isTablet: isTablet,
                              ),
                              SizedBox(height: isTablet ? 20 : 16),

                              // Divider
                              Divider(
                                height: 1,
                                color: _isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                              ),
                              SizedBox(height: isTablet ? 20 : 16),

                              // New Password
                              _buildPasswordField(
                                label: 'Password Baru',
                                hint: 'Masukkan password baru',
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                                isTablet: isTablet,
                              ),
                              SizedBox(height: isTablet ? 20 : 16),

                              // Confirm Password
                              _buildPasswordField(
                                label: 'Konfirmasi Password Baru',
                                hint: 'Ulangi password baru',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi password tidak boleh kosong';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Password tidak cocok';
                                  }
                                  return null;
                                },
                                isTablet: isTablet,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ShadButton(
                            size: isTablet ? ShadButtonSize.lg : null,
                            onPressed: _onSubmit,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Simpan Password',
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
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShadcnTheme.statusInProgress.withValues(alpha: 0.15),
            ShadcnTheme.statusInProgress.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ShadcnTheme.statusInProgress.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ShadcnTheme.statusInProgress.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.security,
              size: isTablet ? 24 : 20,
              color: ShadcnTheme.statusInProgress,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan Password',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Password minimal 8 karakter dan harus mengandung huruf serta angka untuk keamanan yang lebih baik.',
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

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w500,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setLocalState) {
            return TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: TextInputType.visiblePassword,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                filled: true,
                fillColor: _isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
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
                suffixIcon: GestureDetector(
                  onTap: onToggleVisibility,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
}
