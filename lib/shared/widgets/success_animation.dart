import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/shadcn_theme.dart';

/// Premium Success Animation Dialog
/// Features:
/// - Spring-bounce circle entrance with gradient fill
/// - Smooth checkmark stroke drawing with inner glow
/// - Concentric ripple rings expanding outward
/// - Confetti particles with gravity physics & rotation
/// - Silky text fade-in via flutter_animate
/// - Haptic feedback at each animation phase
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
    this.autoCloseDelay = const Duration(milliseconds: 3000),
  });

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──────────────────────────────────────────
  late final AnimationController _circleController;
  late final AnimationController _checkController;
  late final AnimationController _rippleController;
  late final AnimationController _confettiController;
  late final AnimationController _bgController;

  // ── Derived Animations ─────────────────────────────────────────────
  late final Animation<double> _circleScale;
  late final Animation<double> _circleOpacity;
  late final Animation<double> _checkProgress;
  late final Animation<double> _glowIntensity;
  late final Animation<double> _bgOpacity;

  // ── State ──────────────────────────────────────────────────────────
  final List<_ConfettiParticle> _confetti = [];
  final Random _rng = Random();
  bool _hasClosed = false;
  bool _showContent = false;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateConfetti();
    _startSequence();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _rippleController.dispose();
    _confettiController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  // ── Animation Setup ────────────────────────────────────────────────

  void _initAnimations() {
    // Background fade-in
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bgOpacity = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOut,
    );

    // Circle entrance — spring-like overshoot
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const _SpringOvershootCurve(1.6),
      ),
    );
    _circleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _glowIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_circleController);

    // Checkmark stroke reveal
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _checkProgress = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    // Ripple rings expansion
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Confetti burst
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  // ── Confetti Generation ────────────────────────────────────────────

  void _generateConfetti() {
    final colors = [
      ShadcnTheme.statusDone,
      ShadcnTheme.accent,
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF14B8A6), // Teal
      Colors.white,
    ];

    for (int i = 0; i < 55; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 1.8 + _rng.nextDouble() * 3.5;

      _confetti.add(_ConfettiParticle(
        vx: cos(angle) * speed * (0.5 + _rng.nextDouble() * 0.8),
        vy: sin(angle) * speed * (0.5 + _rng.nextDouble() * 0.8) - 1.5,
        size: 3.0 + _rng.nextDouble() * 5.0,
        color: colors[_rng.nextInt(colors.length)],
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 6,
        shape: _ConfettiShape.values[_rng.nextInt(_ConfettiShape.values.length)],
        gravity: 0.06 + _rng.nextDouble() * 0.05,
        delay: _rng.nextDouble() * 0.12,
      ));
    }
  }

  // ── Sequenced Animation Playback ───────────────────────────────────

  Future<void> _startSequence() async {
    // Phase 0: Background fades in
    _bgController.forward();
    HapticFeedback.mediumImpact();

    // Phase 1: Circle pops in with spring
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _circleController.forward();

    // Phase 2: Checkmark draws after circle lands
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _checkController.forward();
    HapticFeedback.lightImpact();

    // Phase 3: Ripples + confetti burst
    await Future.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    _rippleController.forward();
    _confettiController.forward();
    HapticFeedback.heavyImpact();

    // Phase 4: Text content slides in
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _showContent = true);

    // Schedule auto-close
    _scheduleAutoClose();
  }

  void _scheduleAutoClose() {
    Future.delayed(widget.autoCloseDelay, () {
      if (mounted && !_hasClosed) {
        _hasClosed = true;
        Navigator.pop(context);
        widget.onNavigate?.call();
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final circleRadius = isTablet ? 68.0 : 54.0;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _bgOpacity,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.88 * _bgOpacity.value),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle radial gradient wash
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _circleController,
                builder: (context, _) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7,
                        colors: [
                          ShadcnTheme.statusDone.withValues(
                            alpha: 0.06 * _circleScale.value,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Ripple rings (3 staggered)
            ...List.generate(
              3,
              (i) => _buildRippleRing(i, circleRadius),
            ),

            // Confetti canvas
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _ConfettiPainter(
                    particles: _confetti,
                    progress: _confettiController.value,
                    center: Offset(size.width / 2, size.height / 2),
                  ),
                );
              },
            ),

            // Center content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Success circle + checkmark
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _circleController,
                      _checkController,
                    ]),
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _circleScale.value,
                        child: Opacity(
                          opacity: _circleOpacity.value,
                          child: _buildSuccessIcon(circleRadius),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 48 : 40),

                  // ── Title & subtitle with flutter_animate
                  if (_showContent) ...[
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    if (widget.message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.message!,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(
                            delay: 180.ms,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          )
                          .slideY(
                            begin: 0.25,
                            end: 0,
                            delay: 180.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ───────────────────────────────────────────────────

  /// The main green circle with an animated checkmark drawn on top.
  Widget _buildSuccessIcon(double radius) {
    final diameter = radius * 2;
    final totalSize = diameter + 44;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft glow
          AnimatedBuilder(
            animation: _glowIntensity,
            builder: (context, _) {
              final glow = _glowIntensity.value;
              return Container(
                width: totalSize,
                height: totalSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ShadcnTheme.statusDone
                          .withValues(alpha: 0.35 * glow),
                      blurRadius: 50,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: ShadcnTheme.statusDone
                          .withValues(alpha: 0.15 * glow),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              );
            },
          ),

          // Filled gradient circle
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF34D399), // Emerald-400
                  Color(0xFF10B981), // Emerald-500
                  Color(0xFF059669), // Emerald-600
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: ShadcnTheme.statusDone.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Checkmark via CustomPaint
          SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(
              painter: _SmoothCheckmarkPainter(
                progress: _checkProgress.value,
                strokeWidth: radius * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// An expanding, fading ring emanating from the circle center.
  Widget _buildRippleRing(int index, double baseRadius) {
    final stagger = index * 0.18;

    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, _) {
        final raw = (_rippleController.value - stagger).clamp(0.0, 1.0);
        if (raw <= 0) return const SizedBox.shrink();

        final eased = Curves.easeOutCubic.transform(raw);
        final ringRadius = baseRadius + 25 + (eased * 110);
        final opacity = (1.0 - eased) * 0.5;
        final strokeWidth = (2.0 - eased * 1.6).clamp(0.4, 2.0);

        return Container(
          width: ringRadius * 2,
          height: ringRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ShadcnTheme.statusDone.withValues(alpha: opacity),
              width: strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// CUSTOM PAINTING
// ═══════════════════════════════════════════════════════════════════════

/// A curve that overshoots 1.0 then settles back, like a spring.
class _SpringOvershootCurve extends Curve {
  final double tension;
  const _SpringOvershootCurve(this.tension);

  @override
  double transformInternal(double t) {
    t -= 1.0;
    return t * t * ((tension + 1) * t + tension) + 1.0;
  }
}

/// Draws an animated checkmark with a white glow.
class _SmoothCheckmarkPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _SmoothCheckmarkPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.28;

    // Three vertices of the check-mark
    final p1 = Offset(cx - s * 0.7, cy + s * 0.05);
    final p2 = Offset(cx - s * 0.15, cy + s * 0.55);
    final p3 = Offset(cx + s * 0.75, cy - s * 0.45);

    final leg1 = (p2 - p1).distance;
    final leg2 = (p3 - p2).distance;
    final total = leg1 + leg2;
    final drawn = total * progress;

    final path = Path()..moveTo(p1.dx, p1.dy);

    if (drawn <= leg1) {
      final t = drawn / leg1;
      final pt = Offset.lerp(p1, p2, t)!;
      path.lineTo(pt.dx, pt.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = ((drawn - leg1) / leg2).clamp(0.0, 1.0);
      final pt = Offset.lerp(p2, p3, t)!;
      path.lineTo(pt.dx, pt.dy);
    }

    // Glow layer
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = strokeWidth * 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Crisp stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SmoothCheckmarkPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════
// CONFETTI SYSTEM
// ═══════════════════════════════════════════════════════════════════════

enum _ConfettiShape { circle, square, strip, star }

class _ConfettiParticle {
  final double vx, vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final _ConfettiShape shape;
  final double gravity;
  final double delay;

  _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
    required this.gravity,
    required this.delay,
  });
}

/// Paints all confetti particles with gravity, rotation and fade-out.
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final Offset center;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final adj = ((progress - p.delay) / (1.0 - p.delay)).clamp(0.0, 1.0);
      if (adj <= 0) continue;

      final eased = Curves.easeOutQuart.transform(adj);
      const travel = 110.0;

      final x = center.dx + p.vx * eased * travel;
      final y = center.dy +
          p.vy * eased * travel +
          p.gravity * eased * eased * travel * 3.5;

      // Fade out in last 35%
      final opacity =
          adj > 0.65 ? ((1.0 - adj) / 0.35).clamp(0.0, 1.0) : 1.0;
      final rot = p.rotation + p.rotationSpeed * eased;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      switch (p.shape) {
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
        case _ConfettiShape.square:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size,
              ),
              Radius.circular(p.size * 0.15),
            ),
            paint,
          );
        case _ConfettiShape.strip:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 2.4,
                height: p.size * 0.5,
              ),
              Radius.circular(p.size * 0.2),
            ),
            paint,
          );
        case _ConfettiShape.star:
          _drawStar(canvas, paint, p.size);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final r = size / 2;
    for (int i = 0; i < 5; i++) {
      final a = (i * 4 * pi / 5) - pi / 2;
      final pt = Offset(cos(a) * r, sin(a) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════
// PUBLIC HELPER
// ═══════════════════════════════════════════════════════════════════════

/// Helper function to show success animation
Future<void> showSuccessAnimationAndNavigate(
  BuildContext context, {
  required String title,
  String? message,
  Duration delay = const Duration(milliseconds: 3000),
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
