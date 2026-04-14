import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/shadcn_theme.dart';

/// Quick Actions with modern, clean design - Fully Responsive
class QuickActions extends StatelessWidget {
  final VoidCallback? onBuatTiket;
  final VoidCallback? onLihatSemuaTiket;

  const QuickActions({
    super.key,
    this.onBuatTiket,
    this.onLihatSemuaTiket,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flash_on_rounded,
                    color: ShadcnTheme.accent,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            // Action buttons row - responsive
            LayoutBuilder(
              builder: (context, constraints) {
                // For wider screens, buttons side by side
                if (constraints.maxWidth >= 400) {
                  return Row(
                    children: [
                      Expanded(
                        flex: isTablet ? 2 : 1,
                        child: ShadButton(
                          backgroundColor: ShadcnTheme.accent,
                          onPressed: onBuatTiket,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_rounded,
                                size: isTablet ? 20 : 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Buat Tiket',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton.outline(
                          onPressed: onLihatSemuaTiket,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: isTablet ? 20 : 18,
                                color: ShadTheme.of(context).colorScheme.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isTablet ? 'Semua' : 'Daftar',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: ShadTheme.of(context).colorScheme.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // For narrow screens, stack buttons vertically
                return Column(
                  children: [
                    ShadButton(
                      width: double.infinity,
                      backgroundColor: ShadcnTheme.accent,
                      onPressed: onBuatTiket,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Buat Tiket',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShadButton.outline(
                      width: double.infinity,
                      onPressed: onLihatSemuaTiket,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 18,
                            color: ShadTheme.of(context).colorScheme.foreground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Semua Tiket',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ShadTheme.of(context).colorScheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading state - Responsive
class QuickActionsSkeleton extends StatelessWidget {
  final bool isDark;
  const QuickActionsSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ShadCard(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isTablet ? 44 : 40,
                  height: isTablet ? 44 : 40,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: isTablet ? 24 : 20,
                  decoration: BoxDecoration(
                    color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              children: [
                Expanded(
                  flex: isTablet ? 2 : 1,
                  child: Container(
                    height: isTablet ? 48 : 44,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: isTablet ? 48 : 44,
                    decoration: BoxDecoration(
                      color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
