import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
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
    );
  }

  void _onCancel() {
    if (_judulController.text.isNotEmpty ||
        _deskripsiController.text.isNotEmpty) {
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
            Navigator.pop(context, true);
          } else if (state is TiketError) {
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
                    onPressed: _isLoading ? null : _onSubmit,
                    child: _isLoading
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

          // Lampiran section note
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ShadcnTheme.statusInProgress.withValues(alpha: 0.1),
                  ShadcnTheme.statusInProgress.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ShadcnTheme.statusInProgress.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: isTablet ? 20 : 18,
                  color: ShadcnTheme.statusInProgress,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    'Anda dapat menambahkan lampiran setelah tiket dibuat',
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
    );
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
