import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Circular stamp badge ("Find the Luxurious scents") with a 4-point star center.
class CircularScentBadge extends StatelessWidget {
  const CircularScentBadge({
    super.key,
    this.size = 56,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _CircularScentBadgePainter(),
    );
  }
}

class _CircularScentBadgePainter extends CustomPainter {
  const _CircularScentBadgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.46;

    // Soft inner circle tint
    final bgPaint = Paint()
      ..color = AppColors.sageHighlight.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.28, bgPaint);

    // 4-point star in the center
    final starRadius = size.width * 0.16;
    final innerRadius = size.width * 0.045;
    final starPath = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final r = i.isEven ? starRadius : innerRadius;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        starPath.moveTo(pt.dx, pt.dy);
      } else {
        starPath.lineTo(pt.dx, pt.dy);
      }
    }
    starPath.close();
    canvas.drawPath(
      starPath,
      Paint()
        ..color = AppColors.inkSecondary.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // Circular text around the perimeter
    const label = 'Find the Luxurious scents  •  ';
    final textStyle = TextStyle(
      fontFamily: AppTheme.contentFont,
      fontSize: size.width * 0.115,
      fontWeight: FontWeight.w500,
      color: AppColors.inkSecondary,
      letterSpacing: 0.4,
    );

    final angleStep = (2 * math.pi) / label.length;
    for (int i = 0; i < label.length; i++) {
      final char = label[i];
      final angle = -math.pi / 2 + i * angleStep;

      canvas.save();
      canvas.translate(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.rotate(angle + math.pi / 2);

      final tp = TextPainter(
        text: TextSpan(text: char, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
