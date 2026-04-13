import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.retryLabel,
    this.onRetry,
  });

  factory ErrorState.network({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Koneksi terputus',
      subtitle: 'Periksa koneksi internet Anda dan coba lagi',
      retryLabel: 'Coba Lagi',
      onRetry: onRetry,
    );
  }

  factory ErrorState.server({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Terjadi kesalahan',
      subtitle: 'Server sedang mengalami masalah. Silakan coba lagi nanti',
      retryLabel: 'Muat Ulang',
      onRetry: onRetry,
    );
  }

  factory ErrorState.notFound({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Data tidak ditemukan',
      subtitle: 'Data yang Anda cari mungkin telah dihapus atau tidak tersedia',
      retryLabel: 'Kembali',
      onRetry: onRetry,
    );
  }

  factory ErrorState.unauthorized({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Akses ditolak',
      subtitle: 'Anda tidak memiliki izin untuk mengakses halaman ini',
      retryLabel: 'Login Ulang',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title ?? 'Terjadi kesalahan',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: retryLabel ?? 'Coba Lagi',
                variant: AppButtonVariant.outline,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.default_),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppBorderRadius.buttonRadius,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 20,
                color: AppColors.error,
              ),
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
