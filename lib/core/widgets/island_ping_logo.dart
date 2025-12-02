import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom Island Ping logo widget - fully vector, animatable
class IslandPingLogo extends StatelessWidget {
  final double size;
  final Color? pingColor;
  final bool animated;
  final bool adaptToBackground;

  const IslandPingLogo({
    super.key,
    this.size = 80,
    this.pingColor,
    this.animated = false,
    this.adaptToBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // On light backgrounds, use teal for waves to be visible
    final waveColor = adaptToBackground && !isDark ? const Color(0xFF1A6B7C) : null;

    if (animated) {
      return _AnimatedLogo(size: size, pingColor: pingColor, waveColor: waveColor);
    }
    return CustomPaint(
      size: Size(size, size),
      painter: _IslandPingLogoPainter(pingColor: pingColor, waveColor: waveColor),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double size;
  final Color? pingColor;
  final Color? waveColor;

  const _AnimatedLogo({required this.size, this.pingColor, this.waveColor});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _IslandPingLogoPainter(
            pingColor: widget.pingColor,
            waveColor: widget.waveColor,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class _IslandPingLogoPainter extends CustomPainter {
  final Color? pingColor;
  final Color? waveColor;
  final double animationValue;
  final bool useNewBranding;

  // Brand colors - New branding (golden island, white waves)
  static const Color tealBackground = Color(0xFF1A6B7C);
  static const Color goldenYellow = Color(0xFFF5B041);
  static const Color goldenOrange = Color(0xFFE89B2D);
  static const Color waveWhite = Color(0xFFFFFFFF);

  // Legacy colors (teal island)
  static const Color tealDark = Color(0xFF1A5C6B);
  static const Color tealLight = Color(0xFF4ECDC4);
  static const Color coral = Color(0xFFE8927C);

  _IslandPingLogoPainter({
    this.pingColor,
    this.waveColor,
    this.animationValue = 1.0,
    this.useNewBranding = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.65);
    final scale = size.width / 100;

    // Draw island (gradient hill)
    _drawIsland(canvas, center, scale);

    // Draw signal waves
    _drawSignalWaves(canvas, center, scale);

    // Draw ping dot
    _drawPingDot(canvas, center, scale);
  }

  void _drawIsland(Canvas canvas, Offset center, double scale) {
    // Use golden colors for new branding, teal for legacy
    final startColor = useNewBranding ? goldenYellow : tealLight;
    final endColor = useNewBranding ? goldenOrange : tealDark;

    final islandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ).createShader(Rect.fromCenter(
        center: center + Offset(0, 15 * scale),
        width: 70 * scale,
        height: 30 * scale,
      ));

    // Create a more natural island shape like in the new logo
    final path = Path();
    path.moveTo(center.dx - 35 * scale, center.dy + 18 * scale);

    // Left slope going up to peak
    path.quadraticBezierTo(
      center.dx - 15 * scale,
      center.dy + 5 * scale,
      center.dx - 5 * scale,
      center.dy - 8 * scale,
    );

    // Peak to right slope
    path.quadraticBezierTo(
      center.dx + 5 * scale,
      center.dy - 5 * scale,
      center.dx + 35 * scale,
      center.dy + 18 * scale,
    );

    path.close();

    canvas.drawPath(path, islandPaint);
  }

  void _drawSignalWaves(Canvas canvas, Offset center, double scale) {
    // Use custom wave color if provided, otherwise default based on branding
    final effectiveWaveColor = waveColor ?? (useNewBranding ? waveWhite : tealLight);

    final wavePaint = Paint()
      ..color = effectiveWaveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;

    // Position waves above the island peak
    final waveCenter = center - Offset(0, 15 * scale);

    for (int i = 0; i < 3; i++) {
      final radius = (12 + i * 10) * scale;
      final opacity = animationValue < 1.0
          ? (1.0 - ((animationValue + i * 0.33) % 1.0)).clamp(0.3, 1.0)
          : 1.0;

      wavePaint.color = effectiveWaveColor.withOpacity(opacity);

      final rect = Rect.fromCenter(
        center: waveCenter,
        width: radius * 2,
        height: radius * 2,
      );

      // Wider arc to match the new logo style
      canvas.drawArc(
        rect,
        -math.pi * 0.8,
        math.pi * 0.6,
        false,
        wavePaint,
      );
    }
  }

  void _drawPingDot(Canvas canvas, Offset center, double scale) {
    // New branding doesn't have the ping dot - skip if using new branding
    if (useNewBranding && pingColor == null) {
      return;
    }

    final dotPaint = Paint()
      ..color = pingColor ?? coral
      ..style = PaintingStyle.fill;

    final dotCenter = center - Offset(0, 15 * scale);
    final dotRadius = 5 * scale;

    // Glow effect
    final glowPaint = Paint()
      ..color = (pingColor ?? coral).withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale);

    canvas.drawCircle(dotCenter, dotRadius * 1.5, glowPaint);
    canvas.drawCircle(dotCenter, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _IslandPingLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pingColor != pingColor;
  }
}

/// Signal wave animation widget for status display
class SignalWaves extends StatefulWidget {
  final double size;
  final Color color;
  final bool active;

  const SignalWaves({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF4ECDC4),
    this.active = true,
  });

  @override
  State<SignalWaves> createState() => _SignalWavesState();
}

class _SignalWavesState extends State<SignalWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SignalWaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SignalWavesPainter(
            color: widget.color,
            animationValue: widget.active ? _controller.value : 1.0,
          ),
        );
      },
    );
  }
}

class _SignalWavesPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _SignalWavesPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 60;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final baseRadius = (12 + i * 10) * scale;
      final waveOffset = (animationValue + i * 0.33) % 1.0;
      final opacity = (1.0 - waveOffset).clamp(0.2, 1.0);

      paint.color = color.withOpacity(opacity);

      final rect = Rect.fromCenter(
        center: center,
        width: baseRadius * 2,
        height: baseRadius * 2,
      );

      canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignalWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
