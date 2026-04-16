import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/widgets.dart';
import '../cubits/profil_cubit.dart';
import '../models/profil_model.dart';
import 'edit_nama_page.dart';
import 'ubah_password_page.dart';

/// Profil Page - Redesigned with shadcn_ui
/// Displays user profile information and settings menu
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ProfilCubit _cubit = ProfilCubit();

  @override
  void initState() {
    super.initState();
    _cubit.loadProfil();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _onLogout() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Konfirmasi Logout'),
        description: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              _cubit.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditNama(ProfilModel profil) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditNamaPage(
          namaSaatIni: profil.nama,
          onSave: (namaBaru) => _cubit.updateNama(namaBaru),
        ),
      ),
    ).then((success) {
      if (success == true) {
        _cubit.loadProfil();
        _showSuccessSnackBar('Nama berhasil diperbarui');
      }
    });
  }

  void _navigateToUbahPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UbahPasswordPage(),
      ),
    );
  }

  void _showTentangAplikasi() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: Row(
          children: [
            Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ShadcnTheme.accent,
                    ShadcnTheme.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.confirmation_number,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Tentang Aplikasi'),
          ],
        ),
        description: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-Ticketing Helpdesk v1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi sistem pelaporan dan manajemen tiket untuk masalah IT atau layanan.',
            ),
          ],
        ),
        actions: [
          ShadButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShadcnTheme.statusDone,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocConsumer<ProfilCubit, ProfilState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is LoggedOut) {
          context.go('/login');
        } else if (state is ProfilError) {
          _showErrorSnackBar(state.message);
        } else if (state is FotoProfilUpdated) {
          _showSuccessSnackBar('Foto profil berhasil diperbarui');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profil',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: _onLogout,
                child: const Icon(Icons.logout, size: 20),
              ),
            ],
          ),
          body: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(ProfilState state) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    if (state is ProfilLoading) {
      return _buildSkeleton(context, isTablet, horizontalPadding);
    }

    if (state is ProfilError && state is! ProfilLoaded && state is! ProfilUpdated) {
      return ErrorState.server(
        onRetry: () => _cubit.loadProfil(),
      );
    }

    if (state is ProfilLoaded || state is ProfilUpdated || state is FotoProfilUpdated || state is FotoProfilUploading) {
      final ProfilModel profil;
      if (state is ProfilLoaded) {
        profil = state.profil;
      } else if (state is ProfilUpdated) {
        profil = state.profil;
      } else if (state is FotoProfilUpdated) {
        profil = state.profil;
      } else if (state is FotoProfilUploading) {
        profil = state.profil;
      } else {
        return const SizedBox.shrink();
      }

      return RefreshIndicator(
        onRefresh: () => _cubit.loadProfil(),
        child: ListView(
          padding: EdgeInsets.all(horizontalPadding),
          children: [
            if (state is FotoProfilUploading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: ShadTheme.of(context).colorScheme.muted,
                  valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                ),
              ),
            _buildHeader(profil, isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            _buildMenu(profil, isTablet),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkeleton(BuildContext context, bool isTablet, double horizontalPadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: EdgeInsets.all(horizontalPadding),
      children: [
        // Header Skeleton
        Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            ),
          ),
          child: Column(
            children: [
              // Avatar skeleton
              Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 100 : 80,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              // Name skeleton
              Container(
                width: isTablet ? 200 : 150,
                height: isTablet ? 28 : 24,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              // Badge skeleton
              Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 28 : 24,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 16),
        // Menu skeleton
        Container(
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            ),
          ),
          child: Column(
            children: List.generate(4, (index) => Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 48 : 40,
                    height: isTablet ? 48 : 40,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: isTablet ? 140 : 100,
                          height: isTablet ? 18 : 16,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 14 : 12,
                          decoration: BoxDecoration(
                            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(ProfilModel profil) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Foto Profil'),
        description: const Text('Pilih aksi untuk foto profil Anda'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            if (profil.fotoProfil != null) ...[
              ShadButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDeletePhotoConfirmation(profil);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus Foto'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            ShadButton.outline(
              onPressed: () {
                Navigator.pop(context);
                _showPhotoFormatInfo();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Info Format'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePhotoConfirmation(ProfilModel profil) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Hapus Foto Profil'),
        description: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deleteFotoProfil();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showPhotoFormatInfo() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, size: 24),
            SizedBox(width: 8),
            Text('Format Foto'),
          ],
        ),
        description: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Format yang diizinkan:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('• JPG / JPEG'),
            Text('• PNG'),
            SizedBox(height: 12),
            Text('Batasan:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('• Ukuran maksimal: 5MB'),
            Text('• Resolusi maksimal: 1024x1024 px'),
          ],
        ),
        actions: [
          ShadButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ProfilModel profil, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleColor = _getRoleColor(profil.peran);
    final hasPhoto = profil.fotoProfil != null && profil.fotoProfil!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
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
          // Avatar with tap gesture untuk upload
          GestureDetector(
            onTap: () => _cubit.uploadFotoProfil(),
            onLongPress: () => _showPhotoOptions(profil),
            child: Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                gradient: hasPhoto
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          roleColor.withValues(alpha: 0.9),
                          roleColor.withValues(alpha: 0.7),
                        ],
                      ),
                color: hasPhoto ? null : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: roleColor.withValues(alpha: 0.3),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: roleColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: hasPhoto
                    ? DecorationImage(
                        image: NetworkImage(profil.fotoProfil!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
              ),
              child: !hasPhoto
                  ? Center(
                      child: Text(
                        profil.inisial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          // Upload hint text
          GestureDetector(
            onTap: () => _cubit.uploadFotoProfil(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 14,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  hasPhoto ? 'Tap untuk ganti, tahan untuk opsi' : 'Tap untuk tambah foto (JPG/PNG)',
                  style: TextStyle(
                    fontSize: 12,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Greeting
          Text(
            profil.greeting,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w400,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),

          // Nama
          Text(
            profil.nama,
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: ShadTheme.of(context).colorScheme.foreground,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Peran Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 6 : 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  roleColor.withValues(alpha: 0.15),
                  roleColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: roleColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              profil.peranLabel,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Email
          _buildInfoRow(
            Icons.email_outlined,
            profil.email,
            isTablet,
          ),
          const SizedBox(height: 8),

          // Tanggal Bergabung
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Bergabung ${_formatDate(profil.dibuatPada)}',
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: isTablet ? 18 : 16,
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w400,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(ProfilModel profil, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          _MenuItem(
            icon: Icons.edit,
            title: 'Edit Profil',
            subtitle: 'Ubah nama profil Anda',
            onTap: () => _navigateToEditNama(profil),
            isTablet: isTablet,
          ),
          Divider(
            height: 1,
            indent: isTablet ? 80 : 72,
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
          _MenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun Anda',
            onTap: _navigateToUbahPassword,
            isTablet: isTablet,
          ),
          Divider(
            height: 1,
            indent: isTablet ? 80 : 72,
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
          _buildThemeMenuItem(isTablet),
          Divider(
            height: 1,
            indent: isTablet ? 80 : 72,
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: _showTentangAplikasi,
            isTablet: isTablet,
          ),
          Divider(
            height: 1,
            indent: isTablet ? 80 : 72,
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
          _MenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Keluar dari akun',
            iconColor: ShadcnTheme.destructive,
            textColor: ShadcnTheme.destructive,
            onTap: _onLogout,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeMenuItem(bool isTablet) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: getIt<ThemeCubit>(),
      builder: (context, state) {
        final themeCubit = getIt<ThemeCubit>();
        final icon = themeCubit.getThemeIcon();
        final displayName = themeCubit.getThemeDisplayName();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showThemeSelector(context, themeCubit),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 48 : 40,
                    height: isTablet ? 48 : 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ShadcnTheme.accent.withValues(alpha: 0.2),
                          ShadcnTheme.accent.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: ShadcnTheme.accent,
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            fontWeight: FontWeight.w600,
                            color: ShadTheme.of(context).colorScheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w400,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                    size: isTablet ? 24 : 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, ThemeCubit themeCubit) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    showShadDialog(
      context: context,
      builder: (dialogContext) => ShadDialog(
        title: Row(
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: ShadcnTheme.accent,
                size: isTablet ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Pilih Tema'),
          ],
        ),
        description: const Text(
          'Pilih tampilan tema yang nyaman untuk Anda',
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Mode Terang',
              subtitle: 'Tampilan cerah dengan warna terang',
              isSelected: themeCubit.state.isLightMode,
              onTap: () {
                Navigator.pop(dialogContext);
                themeCubit.setLightMode();
              },
              isTablet: isTablet,
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Mode Gelap',
              subtitle: 'Tampilan gelap untuk kenyamanan mata',
              isSelected: themeCubit.state.isDarkMode,
              onTap: () {
                Navigator.pop(dialogContext);
                themeCubit.setDarkMode();
              },
              isTablet: isTablet,
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.brightness_auto,
              title: 'Sistem Default',
              subtitle: 'Ikuti pengaturan sistem perangkat',
              isSelected: themeCubit.state.isSystemMode,
              onTap: () {
                Navigator.pop(dialogContext);
                themeCubit.setSystemMode();
              },
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String peran) {
    switch (peran.toLowerCase()) {
      case 'admin':
        return ShadcnTheme.statusOpen;
      case 'helpdesk':
        return ShadcnTheme.accent;
      case 'pengguna':
      default:
        return ShadcnTheme.statusDone;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
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
}

/// Theme option widget
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: ShadcnTheme.accent.withValues(alpha: 0.1),
        highlightColor: ShadcnTheme.accent.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ShadcnTheme.accent.withValues(alpha: 0.1)
                : (isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? ShadcnTheme.accent : (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ShadcnTheme.accent.withValues(alpha: 0.2)
                      : (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? ShadcnTheme.accent : ShadTheme.of(context).colorScheme.mutedForeground,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w400,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 24 : 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu item widget for profile page
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool isTablet;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? ShadcnTheme.accent;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w400,
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
                size: isTablet ? 24 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
