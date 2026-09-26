import 'dart:math';

import 'package:flutter/material.dart';

/// A decorative Poké Ball drawn with the theme colors: a primary top half,
/// a light bottom half and a dark band with a center button.
class PokeBallWidget extends StatelessWidget {
  const PokeBallWidget({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size.square(size),
      painter: PokeBallPainter(
        topColor: colorScheme.primary,
        bottomColor: colorScheme.surfaceContainerHighest,
        bandColor: colorScheme.onSurface,
      ),
    );
  }
}

/// Paints a Poké Ball that fills the smaller side of the canvas.
class PokeBallPainter extends CustomPainter {
  PokeBallPainter({
    required this.topColor,
    required this.bottomColor,
    required this.bandColor,
  });

  final Color topColor;
  final Color bottomColor;
  final Color bandColor;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = diameter / 2;
    final band = diameter / 13;
    final ball = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(ball, pi, pi, true, Paint()..color = topColor);
    canvas.drawArc(ball, 0, pi, true, Paint()..color = bottomColor);

    final bandPaint = Paint()..color = bandColor;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: diameter, height: band),
      bandPaint,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bandColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = band / 2,
    );
    canvas.drawCircle(center, diameter / 6, bandPaint);
    canvas.drawCircle(center, diameter / 10, Paint()..color = bottomColor);
  }

  @override
  bool shouldRepaint(PokeBallPainter oldDelegate) =>
      oldDelegate.topColor != topColor ||
      oldDelegate.bottomColor != bottomColor ||
      oldDelegate.bandColor != bandColor;
}
