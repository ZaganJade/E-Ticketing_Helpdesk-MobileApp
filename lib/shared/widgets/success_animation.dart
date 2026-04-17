import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/shadcn_theme.dart';

/// Enhanced Success Animation Dialog
/// Features:
/// - Particle explosion effect with physics
/// - Animated checkmark with stroke drawing
/// - Glowing elements and particle trails
/// - Interactive confetti with realistic physics
class SuccessAnimationDialog extends StatefulWidget {
  final String title;
  final String? message;
  final VoidCallback? onNavigate;
  final Duration autoCloseDelay;

  const SuccessAnimationDialog({
    super.key,
    required this.title,
    this.message,
    this.onNavigate,
    this.autoCloseDelay = const Duration(milliseconds: 2500),
  });

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _checkmarkController;
  late AnimationController _pulseController;
  late AnimationController _particlesController;
  late AnimationController _orbitController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitAnimation;
  late Animation<double> _fadeAnimation;

  final List<SuccessParticle> _particles = [];
  final Random _random = Random();
  bool _hasClosed = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _orbitAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _orbitController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _generateParticles();
    _mainController.forward();
    _checkmarkController.forward();
    _pulseController.forward();
    _orbitController.forward();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _particlesController.forward();
      _scheduleAutoClose();
    });
  }

  void _scheduleAutoClose() {
    Future.delayed(widget.autoCloseDelay, () {
      if (mounted && !_hasClosed) {
        _hasClosed = true;
        Navigator.pop(context);
        if (widget.onNavigate != null) {
          widget.onNavigate!();
        }
      }
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 80; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 0.5 + _random.nextDouble() * 1.5;
      final delay = _random.nextDouble() * 800;

      _particles.add(SuccessParticle(
        angle: angle,
        distance: 50 + _random.nextDouble() * 100,
        size: 4 + _random.nextDouble() * 8,
        speed: speed,
        delay: delay,
        color: _particleColor(i),
        type: _particleType(i),
      ));
    }
  }

  Color _particleColor(int index) {
    final colors = [
      ShadcnTheme.statusDone,
      ShadcnTheme.accent,
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      Colors.white,
    ];
    return colors[index % colors.length];
  }

  ParticleType _particleType(int index) {
    final types = [
      ParticleType.circle,
      ParticleType.square,
      ParticleType.triangle,
      ParticleType.star,
      ParticleType.diamond,
    ];
    return types[index % types.length];
  }

  @override
  void dispose() {
    _mainController.dispose();
    _checkmarkController.dispose();
    _pulseController.dispose();
    _particlesController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: Stack(
        children: [
          // Background gradient mesh
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f0f23),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Orbiting particles
          ...List.generate(12, (index) {
            return AnimatedBuilder(
              animation: _orbitAnimation,
              builder: (context, child) {
                final angle = _orbitAnimation.value + (index * pi / 6);
                final orbitRadius = 150 + index * 10;
                return Positioned(
                  left: (size.width / 2) + cos(angle) * orbitRadius - 6,
                  top: (size.height / 2) + sin(angle) * orbitRadius - 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1 + index * 0.02),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),

          // Explosion particles
          ...List.generate(_particles.length, (index) {
            final particle = _particles[index];
            return AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                final progress = _particlesController.value;
                final progressWithDelay = (progress * 1000 - particle.delay).clamp(0.0, 1.0);

                if (progress < particle.delay / 1000) {
                  return const SizedBox.shrink();
                }

                final easedProgress = Curves.easeOut.transform(progressWithDelay);
                final distance = particle.distance * easedProgress;
                final x = cos(particle.angle) * distance;
                final y = sin(particle.angle) * distance;
                final opacity = (1 - easedProgress).clamp(0.0, 1.0);
                final scale = 1 + easedProgress * 0.5;

                return Positioned(
                  left: size.width / 2 + x,
                  top: size.height / 2 + y,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: easedProgress * 4 * pi,
                      child: Opacity(
                        opacity: opacity,
                        child: _buildParticle(particle),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main success content
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final pulseScale = _pulseAnimation.value;

                      return Transform.scale(
                        scale: pulseScale,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glowing circle background
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    ShadcnTheme.statusDone.withValues(alpha: 0.0),
                                    ShadcnTheme.statusDone.withValues(alpha: 0.15),
                                    ShadcnTheme.statusDone.withValues(alpha: 0.3),
                                  ],
                                  stops: const [0.3, 0.6, 1.0],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ShadcnTheme.statusDone.withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: ShadcnTheme.statusDone.withValues(alpha: 0.2),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),

                            // Checkmark with custom drawing animation
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: AnimatedBuilder(
                                animation: _checkmarkAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: const Size(160, 160),
                                    painter: CheckmarkPainter(
                                      progress: _checkmarkAnimation.value,
                                      color: ShadcnTheme.statusDone,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Title and message with fade-in
          Positioned(
            bottom: size.height * 0.25,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                final opacity = _fadeAnimation.value;
                final yOffset = (1 - _fadeAnimation.value) * 20;

                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.message!,
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(SuccessParticle particle) {
    switch (particle.type) {
      case ParticleType.circle:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.circle,
          ),
        );
      case ParticleType.square:
        return Transform.rotate(
          angle: particle.angle * 2,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
            ),
          ),
        );
      case ParticleType.triangle:
        return CustomPaint(
          size: Size(particle.size, particle.size),
          painter: TrianglePainter(color: particle.color),
        );
      case ParticleType.star:
        return Icon(
          Icons.star_rounded,
          color: particle.color,
          size: particle.size,
        );
      case ParticleType.diamond:
        return Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
            ),
          ),
        );
    }
  }
}

enum ParticleType { circle, square, triangle, star, diamond }

class SuccessParticle {
  final double angle;
  final double distance;
  final double size;
  final double speed;
  final double delay;
  final Color color;
  final ParticleType type;

  SuccessParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
    required this.delay,
    required this.color,
    required this.type,
  });
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 8.0;
    final checkSize = 50.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final halfSize = checkSize / 2;

    // Calculate the checkmark based on progress
    if (progress < 0.5) {
      // Draw stem (first half of animation)
      final stemProgress = (progress / 0.5).clamp(0.0, 1.0);
      final stemLength = checkSize * stemProgress;

      path.moveTo(center.dx - halfSize / 2, center.dy);
      path.lineTo(center.dx - halfSize / 2, center.dy + stemLength);
    } else {
      // Full checkmark with animation on the tick
      final tickProgress = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

      path.moveTo(center.dx - halfSize / 2, center.dy);
      path.lineTo(center.dx - halfSize / 2, center.dy + checkSize);

      final tickEndX = center.dx + halfSize * 2;
      final tickEndY = center.dy - checkSize / 2;
      final currentX = center.dx - halfSize / 2 + (tickEndX - (center.dx - halfSize / 2)) * tickProgress;
      final currentY = center.dy + checkSize + (tickEndY - (center.dy + checkSize)) * tickProgress;

      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Helper function to show success animation
Future<void> showSuccessAnimationAndNavigate(
  BuildContext context, {
  required String title,
  String? message,
  Duration delay = const Duration(milliseconds: 2500),
}) async {
  if (!context.mounted) return;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) => SuccessAnimationDialog(
      title: title,
      message: message,
      autoCloseDelay: delay,
      onNavigate: () {
        if (context.mounted) {
          context.go('/tiket');
        }
      },
    ),
  );
}
