import 'package:flutter/material.dart';
import 'dart:math';

class LeafPainter extends CustomPainter {
  final Color color;

  LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width, size.height / 3, size.width / 2, size.height);
    path.quadraticBezierTo(0, size.height / 3, size.width / 2, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SnowflakePainter extends CustomPainter {
  final Color color;

  SnowflakePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, end, paint);

      final branch1 = Offset(
        center.dx + cos(angle - pi / 6) * radius * 0.6,
        center.dy + sin(angle - pi / 6) * radius * 0.6,
      );
      final branch2 = Offset(
        center.dx + cos(angle + pi / 6) * radius * 0.6,
        center.dy + sin(angle + pi / 6) * radius * 0.6,
      );

      canvas.drawLine(center, branch1, paint);
      canvas.drawLine(center, branch2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RaindropPainter extends CustomPainter {
  final Color color;

  RaindropPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(0, size.height / 2, size.width / 2, size.height);
    path.quadraticBezierTo(size.width, size.height / 2, size.width / 2, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}