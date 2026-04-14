import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/shadcn_theme.dart';

/// Edit Nama Page - Redesigned with shadcn_ui
/// Allows users to update their profile name
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Nama',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: ShadButton.ghost(
          size: ShadButtonSize.sm,
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.close, size: 24),
        ),
        leadingWidth: 64,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ShadButton(
              size: ShadButtonSize.sm,
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading
                  ? SizedBox(
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
                    'Menyimpan...',
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
                    Container(
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
                              Icons.person_outline,
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
                                  'Nama Profil',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: ShadTheme.of(context).colorScheme.foreground,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Perbarui nama yang ditampilkan di aplikasi',
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
                    ),
                    SizedBox(height: isTablet ? 24 : 16),

                    // Form Card
                    Container(
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
                          Text(
                            'Nama Lengkap',
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: FontWeight.w500,
                              color: ShadTheme.of(context).colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShadInput(
                            controller: _namaController,
                            placeholder: const Text('Masukkan nama lengkap Anda'),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _onSave(),
                          ),
                          if (_namaController.text.isNotEmpty &&
                              _namaController.text.length < 3) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                                      'Nama minimal 3 karakter',
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
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),

                    // Info Card
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShadcnTheme.accent.withValues(alpha: 0.1),
                            ShadcnTheme.accent.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ShadcnTheme.accent.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ShadcnTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: isTablet ? 20 : 18,
                              color: ShadcnTheme.accent,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Text(
                              'Nama ini akan ditampilkan di profil Anda dan digunakan dalam komunikasi di aplikasi.',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
