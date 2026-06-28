import 'dart:math';
import 'package:flutter/material.dart';

class GlintPoint {
  final double dx;
  final double dy;
  final double size;
  final double maxOpacity;

  const GlintPoint({
    required this.dx,
    required this.dy,
    this.size = 14,
    this.maxOpacity = 0.9,
  });
}

const List<GlintPoint> kMainMenuGlints = [
  GlintPoint(dx: 0.78, dy: 0.30, size: 10, maxOpacity: 0.85),
  GlintPoint(dx: 0.86, dy: 0.42, size: 18, maxOpacity: 0.95),
  GlintPoint(dx: 0.30, dy: 0.50, size: 8, maxOpacity: 0.7),
  GlintPoint(dx: 0.18, dy: 0.62, size: 14, maxOpacity: 0.85),
  GlintPoint(dx: 0.62, dy: 0.58, size: 9, maxOpacity: 0.75),
  GlintPoint(dx: 0.10, dy: 0.78, size: 16, maxOpacity: 0.9),
  GlintPoint(dx: 0.45, dy: 0.72, size: 7, maxOpacity: 0.6),
  GlintPoint(dx: 0.08, dy: 0.40, size: 6, maxOpacity: 0.6),
];

class SparkleOverlay extends StatefulWidget {
  final Widget child;
  final List<GlintPoint> glints;
  
  final Color glintColor;

  final Widget? foreground;

  const SparkleOverlay({
    super.key, 
    required this.child,
    this.glints = kMainMenuGlints,
    this.glintColor = const Color(0xFFEAF4FF),
    this.foreground,
  });

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay> with TickerProviderStateMixin {
  late final List<_GlintController> _controllers;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _controllers = widget.glints.map((g) {
      return _GlintController(vsync: this, point: g, rng: rng);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            ..._controllers.map((c) => c.build(size, widget.glintColor)),
            if (widget.foreground != null) widget.foreground!,
          ],
        );
      },
    );
  }
}

class _GlintController {
  final TickerProvider vsync;
  final GlintPoint point;
  final Random rng;

  late AnimationController _controller;
  late Animation<double> _opacity;

  _GlintController({
    required this.vsync,
    required this.point,
    required this.rng,
  }) {
    _controller = AnimationController(
      vsync: vsync,
      duration: _randomPulseDuration(),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: point.maxOpacity)
        .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween(point.maxOpacity),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: point.maxOpacity, end: 0.0)
        .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _scheduleNextPulse(initial: true);
  }

  Duration _randomPulseDuration() {
    final ms = 900 + rng.nextInt(1300);
    return Duration(milliseconds: ms);
  }

  void _scheduleNextPulse({bool initial = false}) {
    final delayMs = initial
      ? rng.nextInt(4000)
      : 1500 + rng.nextInt(5500);

      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!_controller.isAnimating) {
          _controller.duration = _randomPulseDuration();
          _controller.forward(from: 0).whenComplete(() {
            _controller.reset();
            _scheduleNextPulse();
          });
        }
      });
  }

  Widget build(Size size, Color color) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        if (_opacity.value <= 0.01) return const SizedBox.shrink();
        return Positioned(
          left: size.width * point.dx - point.size / 2,
          top: size.height * point.dy - point.size / 2,
          child: IgnorePointer(
            child: Container(
              width: point.size,
              height: point.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _opacity.value),
                    blurRadius: point.size * 1.4,
                    spreadRadius: point.size * 0.15,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: _opacity.value),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void dispose() {
    _controller.dispose();
  }
}