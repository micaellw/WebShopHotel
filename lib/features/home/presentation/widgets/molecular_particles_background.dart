import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle3D {
  double x;
  double y;
  double z; // 0.2 (far) to 1.8 (near)
  double vx;
  double vy;
  double vz;
  double radius;
  Color color;
  double pulseOffset;

  Particle3D({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.radius,
    required this.color,
    required this.pulseOffset,
  });
}

class MolecularParticlesBackground extends StatefulWidget {
  final Widget? child;
  final int particleCount;

  const MolecularParticlesBackground({
    super.key,
    this.child,
    this.particleCount = 55,
  });

  @override
  State<MolecularParticlesBackground> createState() =>
      _MolecularParticlesBackgroundState();
}

class _MolecularParticlesBackgroundState
    extends State<MolecularParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle3D> _particles = [];
  final math.Random _random = math.Random();
  Offset? _mousePosition;
  Size _lastSize = Size.zero;

  static const List<Color> _palette = [
    Color(0xFF10B981), // Emerald
    Color(0xFF34D399), // Light Emerald
    Color(0xFF0F766E), // Deep Teal
    Color(0xFF22D3EE), // Cyan glow
    Color(0xFFF59E0B), // Warm Gold
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      });
    _controller.repeat();
  }

  void _initParticles(Size size) {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        Particle3D(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          z: 0.3 + _random.nextDouble() * 1.2, // depth
          vx: (_random.nextDouble() - 0.5) * 0.7,
          vy: (_random.nextDouble() - 0.5) * 0.7,
          vz: (_random.nextDouble() - 0.5) * 0.005,
          radius: 2.0 + _random.nextDouble() * 3.5,
          color: _palette[_random.nextInt(_palette.length)],
          pulseOffset: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _updateParticles() {
    if (_lastSize == Size.zero) return;

    for (final p in _particles) {
      p.x += p.vx * p.z;
      p.y += p.vy * p.z;
      p.z += p.vz;

      // Depth bounce
      if (p.z < 0.3 || p.z > 1.5) {
        p.vz = -p.vz;
      }

      // Screen edge wrap / bounce
      if (p.x < 0) {
        p.x = _lastSize.width;
      } else if (p.x > _lastSize.width) {
        p.x = 0;
      }

      if (p.y < 0) {
        p.y = _lastSize.height;
      } else if (p.y > _lastSize.height) {
        p.y = 0;
      }

      // Mouse repulsion / interaction
      if (_mousePosition != null) {
        final dx = p.x - _mousePosition!.dx;
        final dy = p.y - _mousePosition!.dy;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 140 && dist > 0.1) {
          final force = (140 - dist) / 140;
          p.x += (dx / dist) * force * 2.5;
          p.y += (dy / dist) * force * 2.5;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastSize != currentSize && currentSize.width > 0) {
          _lastSize = currentSize;
          _initParticles(currentSize);
        }

        return MouseRegion(
          onHover: (event) {
            _mousePosition = event.localPosition;
          },
          onExit: (_) {
            _mousePosition = null;
          },
          child: Stack(
            children: [
              // Deep space gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.4,
                    colors: [
                      Color(0xFF16231C), // Deep botanical dark green
                      Color(0xFF0F1813),
                      Color(0xFF0A0F0C), // Obsidian void
                    ],
                  ),
                ),
              ),

              // Canvas with 3D molecular bonds and glowing nodes
              CustomPaint(
                size: Size.infinite,
                painter: _MolecularPainter(
                  particles: _particles,
                  mousePosition: _mousePosition,
                  time: _controller.value * math.pi * 2,
                ),
              ),

              // Content overlay
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _MolecularPainter extends CustomPainter {
  final List<Particle3D> particles;
  final Offset? mousePosition;
  final double time;

  _MolecularPainter({
    required this.particles,
    required this.mousePosition,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    const double bondThreshold = 120.0;

    // 1. Draw connecting bonds (molecular lines)
    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];

      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];

        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dist = math.sqrt(dx * dx + dy * dy);

        if (dist < bondThreshold) {
          final depthAvg = (p1.z + p2.z) / 2.0;
          final proximity = 1.0 - (dist / bondThreshold);
          final opacity = (proximity * 0.45 * (depthAvg / 1.5)).clamp(0.03, 0.7);

          linePaint.strokeWidth = (1.0 + (depthAvg - 0.5) * 0.8).clamp(0.5, 2.2);
          linePaint.color = const Color(0xFF10B981).withValues(alpha: opacity);

          canvas.drawLine(
            Offset(p1.x, p1.y),
            Offset(p2.x, p2.y),
            linePaint,
          );
        }
      }

      // Draw connection to mouse cursor
      if (mousePosition != null) {
        final mdx = p1.x - mousePosition!.dx;
        final mdy = p1.y - mousePosition!.dy;
        final mdist = math.sqrt(mdx * mdx + mdy * mdy);
        if (mdist < 140) {
          final mProximity = 1.0 - (mdist / 140);
          linePaint.strokeWidth = 1.2;
          linePaint.color =
              const Color(0xFF34D399).withValues(alpha: mProximity * 0.6);
          canvas.drawLine(
            Offset(p1.x, p1.y),
            mousePosition!,
            linePaint,
          );
        }
      }
    }

    // 2. Draw 3D nodes with depth scaling and pulsing aura
    for (final p in particles) {
      final effectiveRadius = p.radius * p.z;
      final pulse = math.sin(time + p.pulseOffset) * 0.2 + 1.0;
      final currentRadius = effectiveRadius * pulse;
      final alpha = (0.4 + (p.z / 1.8) * 0.6).clamp(0.3, 1.0);

      // Outer glow aura
      glowPaint.color = p.color.withValues(alpha: alpha * 0.25);
      canvas.drawCircle(
        Offset(p.x, p.y),
        currentRadius * 2.8,
        glowPaint,
      );

      // Mid aura
      glowPaint.color = p.color.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(
        Offset(p.x, p.y),
        currentRadius * 1.6,
        glowPaint,
      );

      // Core particle
      nodePaint.color = p.color.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(p.x, p.y),
        currentRadius,
        nodePaint,
      );

      // Center bright core
      nodePaint.color = Colors.white.withValues(alpha: alpha * 0.85);
      canvas.drawCircle(
        Offset(p.x, p.y),
        currentRadius * 0.45,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MolecularPainter oldDelegate) => true;
}
