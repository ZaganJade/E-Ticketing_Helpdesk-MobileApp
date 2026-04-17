import 'package:flutter/material.dart';

import '../../../../core/theme/shadcn_theme.dart';

class UserStatsCardSkeleton extends StatelessWidget {
  final bool isDark;

  const UserStatsCardSkeleton({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.6),
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 13,
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
          const SizedBox(height: 20),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? 6 : 0,
                    left: index > 0 ? 6 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                              .withValues(alpha: 0.15),
                          (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                              .withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ShadcnTheme.darkBorder
                                : ShadcnTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class HelpdeskPerformanceCardSkeleton extends StatelessWidget {
  final bool isDark;

  const HelpdeskPerformanceCardSkeleton({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.6),
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(2, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == 0 ? 12 : 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.15),
                      (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border)
                          .withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? ShadcnTheme.darkBorder
                            : ShadcnTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 15,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? ShadcnTheme.darkBorder
                                  : ShadcnTheme.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(2, (i) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i == 0 ? 12 : 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? ShadcnTheme.darkBorder
                                              : ShadcnTheme.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 16,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? ShadcnTheme.darkBorder
                                              : ShadcnTheme.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
