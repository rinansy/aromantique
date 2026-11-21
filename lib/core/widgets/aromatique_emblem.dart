import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Ornate perfume-drop emblem matching the brand mark in the AppBar.
class AromatiqueEmblem extends StatelessWidget {
  const AromatiqueEmblem({
    super.key,
    this.size = 28,
    this.color = AppColors.inkPrimary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AromatiqueEmblemPainter(color: color),
    );
  }
}

class _AromatiqueEmblemPainter extends CustomPainter {
  const _AromatiqueEmblemPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Top stopper dot
    canvas.drawCircle(Offset(cx, h * 0.14), w * 0.055, fill);

    // Neck ring
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.25),
          width: w * 0.24,
          height: h * 0.08,
        ),
        Radius.circular(w * 0.04),
      ),
      stroke,
    );

    // Outer petal / bottle silhouette
    final outer = Path()
      ..moveTo(cx, h * 0.30)
      ..cubicTo(w * 0.86, h * 0.36, w * 0.90, h * 0.72, cx, h * 0.90)
      ..cubicTo(w * 0.10, h * 0.72, w * 0.14, h * 0.36, cx, h * 0.30)
      ..close();
    canvas.drawPath(outer, stroke);

    // Inner lotus drop
    final inner = Path()
      ..moveTo(cx, h * 0.42)
      ..cubicTo(w * 0.68, h * 0.50, w * 0.70, h * 0.72, cx, h * 0.84)
      ..cubicTo(w * 0.30, h * 0.72, w * 0.32, h * 0.50, cx, h * 0.42)
      ..close();
    canvas.drawPath(inner, stroke);

    // Left & right side leaf arcs
    final leftArc = Path()
      ..moveTo(cx, h * 0.86)
      ..quadraticBezierTo(w * 0.24, h * 0.74, w * 0.26, h * 0.56);
    canvas.drawPath(leftArc, stroke);

    final rightArc = Path()
      ..moveTo(cx, h * 0.86)
      ..quadraticBezierTo(w * 0.76, h * 0.74, w * 0.74, h * 0.56);
    canvas.drawPath(rightArc, stroke);
  }

  @override
  bool shouldRepaint(covariant _AromatiqueEmblemPainter oldDelegate) =>
      oldDelegate.color != color;
}
