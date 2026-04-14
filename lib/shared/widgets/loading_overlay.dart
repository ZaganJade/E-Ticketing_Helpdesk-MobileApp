import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// Loading Overlay - Redesigned with shadcn_ui
/// A reusable loading overlay component
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  color: ShadcnTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ShadcnTheme.accent,
                      ),
                    ),
                    if (message != null) ...[
                      SizedBox(height: isTablet ? 20 : 16),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          color: ShadTheme.of(context).colorScheme.foreground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Full Screen Loading - A full screen loading indicator
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
            ),
            if (message != null) ...[
              SizedBox(height: isTablet ? 24 : 20),
              Text(
                message!,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline Loading - A small inline loading indicator
class InlineLoading extends StatelessWidget {
  final String? message;
  final double size;

  const InlineLoading({
    super.key,
    this.message,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
          ),
        ),
        if (message != null) ...[
          SizedBox(width: isTablet ? 12 : 8),
          Text(
            message!,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}
