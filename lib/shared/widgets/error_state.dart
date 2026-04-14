import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// Error State - Redesigned with shadcn_ui
/// A reusable component for displaying error states
class ErrorState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final Color? iconColor;

  const ErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.retryLabel,
    this.onRetry,
    this.iconColor,
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final color = iconColor ?? ShadcnTheme.destructive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 40 : 32),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: isTablet ? 56 : 48,
                  color: color,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              Text(
                title ?? 'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                SizedBox(height: isTablet ? 24 : 20),
                ShadButton.outline(
                  onPressed: onRetry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 18),
                      const SizedBox(width: 8),
                      Text(retryLabel ?? 'Coba Lagi'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline Error - For displaying inline error messages
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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
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
            size: isTablet ? 24 : 20,
            color: ShadcnTheme.destructive,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: ShadcnTheme.destructive,
              ),
            ),
          ),
          if (onRetry != null)
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: onRetry,
              child: const Icon(Icons.refresh, size: 20),
            ),
        ],
      ),
    );
  }
}
