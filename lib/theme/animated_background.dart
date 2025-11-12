import 'package:flutter/material.dart';
import 'dart:math';
import 'app_theme.dart';
import 'particle_painters.dart';

class AnimatedBackground extends StatefulWidget {
  final SeasonTheme theme;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _initializeParticles();
  }

  void _initializeParticles() {
    final particleCount = widget.theme == SeasonTheme.winter ? 60 : 40;
    
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble() - 1.0,
        speed: 0.5 + _random.nextDouble() * 1.5,
        size: widget.theme == SeasonTheme.winter
            ? 2.0 + _random.nextDouble() * 4.0
            : 8.0 + _random.nextDouble() * 12.0,
        delay: _random.nextDouble() * 5.0,
        opacity: 0.3 + _random.nextDouble() * 0.7,
        swayAmount: _random.nextDouble() * 30 - 15,
        rotationSpeed: _random.nextDouble() * 2 - 1,
        color: _getParticleColor(),
      ));
    }
  }

  Color _getParticleColor() {
    switch (widget.theme) {
      case SeasonTheme.summer:
        return const Color(0xFFFFD54F);
      case SeasonTheme.autumn:
        return [
          const Color(0xFFFF8A65),
          const Color(0xFFFFAB91),
          const Color(0xFFFFCCBC),
          const Color(0xFFD7CCC8),
        ][_random.nextInt(4)];
      case SeasonTheme.winter:
        return Colors.white;
      case SeasonTheme.spring:
        return const Color(0xFF81C784);
    }
  }

  Widget _buildParticle(Particle particle) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value * particle.speed + particle.delay) % 2.0;
        final y = particle.y + progress * 2.0;
        final x = particle.x + sin(progress * pi * 2 + particle.delay) * particle.swayAmount / 100;

        if (y > 1.0) return const SizedBox.shrink();

        return Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          child: Transform.rotate(
            angle: _controller.value * particle.rotationSpeed * 2 * pi,
            child: Opacity(
              opacity: particle.opacity * (1.0 - progress / 2.0),
              child: _buildParticleShape(particle),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleShape(Particle particle) {
    switch (widget.theme) {
      case SeasonTheme.summer:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: particle.color.withValues(alpha: 0.6),
                blurRadius: particle.size / 2,
              ),
            ],
          ),
        );
      case SeasonTheme.autumn:
        return CustomPaint(
          size: Size(particle.size, particle.size),
          painter: LeafPainter(particle.color),
        );
      case SeasonTheme.winter:
        return CustomPaint(
          size: Size(particle.size, particle.size),
          painter: SnowflakePainter(particle.color),
        );
      case SeasonTheme.spring:
        return CustomPaint(
          size: Size(particle.size, particle.size),
          painter: RaindropPainter(particle.color),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.getBackgroundColor(widget.theme),
                AppTheme.getBackgroundColor(widget.theme).withValues(alpha: 0.8),
                AppTheme.getSurfaceColor(widget.theme).withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        ..._particles.map(_buildParticle),
        widget.child,
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double delay;
  final double opacity;
  final double swayAmount;
  final double rotationSpeed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.opacity,
    required this.swayAmount,
    required this.rotationSpeed,
    required this.color,
  });
}