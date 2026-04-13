import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubits/profil_cubit.dart';
import '../models/profil_model.dart';
import 'edit_nama_page.dart';
import 'ubah_password_page.dart';

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
    AppModal.showConfirmation(
      context: context,
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Keluar',
      confirmVariant: AppButtonVariant.destructive,
    ).then((confirmed) {
      if (confirmed == true) {
        // Logout via ProfilCubit - AuthCubit will be notified via state change
        _cubit.logout();
      }
    });
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
        AppSnackbar.success(context, 'Nama berhasil diperbarui');
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
    showAboutDialog(
      context: context,
      applicationName: 'E-Ticketing Helpdesk',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.confirmation_number,
          color: AppColors.white,
          size: 32,
        ),
      ),
      children: [
        Text(
          'Aplikasi sistem pelaporan dan manajemen tiket untuk masalah IT atau layanan.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilCubit, ProfilState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is LoggedOut) {
          // Navigate to login - AuthCubit state already updated by repository
          context.go('/login');
        } else if (state is ProfilError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppAppBar(
            title: 'Profil',
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _onLogout,
              ),
            ],
          ),
          body: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(ProfilState state) {
    if (state is ProfilLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfilError) {
      return ErrorState.server(
        onRetry: () => _cubit.loadProfil(),
      );
    }

    if (state is ProfilLoaded || state is ProfilUpdated) {
      final profil = state is ProfilLoaded
          ? state.profil
          : (state as ProfilUpdated).profil;

      return RefreshIndicator(
        onRefresh: () => _cubit.loadProfil(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.default_),
          children: [
            // Header Section
            _buildHeader(profil),
            const SizedBox(height: AppSpacing.lg),

            // Menu List
            _buildMenu(profil),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader(ProfilModel profil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                profil.inisial,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.default_),

          // Greeting
          Text(
            '${profil.greeting},',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Nama
          Text(
            profil.nama,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Peran Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(profil.peran).withOpacity(0.1),
              borderRadius: AppBorderRadius.badgeRadius,
            ),
            child: Text(
              profil.peranLabel,
              style: AppTextStyles.caption.copyWith(
                color: _getRoleColor(profil.peran),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.default_),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                profil.email,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Tanggal Bergabung
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Bergabung ${_formatDate(profil.dibuatPada)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(ProfilModel profil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppBorderRadius.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.edit,
            title: 'Edit Profil',
            subtitle: 'Ubah nama profil Anda',
            onTap: () => _navigateToEditNama(profil),
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun Anda',
            onTap: _navigateToUbahPassword,
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: _showTentangAplikasi,
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Keluar dari akun',
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: _onLogout,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String peran) {
    switch (peran.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'helpdesk':
        return AppColors.primary;
      case 'pengguna':
      default:
        return AppColors.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.default_),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: AppBorderRadius.buttonRadius,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.default_),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
